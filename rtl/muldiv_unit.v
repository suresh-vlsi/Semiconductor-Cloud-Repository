// Iterative RV32M multiply/divide unit (replaces the single-cycle behavioural * / % that
// produced a ~150 ns combinational path in SKY130 synthesis).
//
//   multiply: 32-cycle shift-and-add on magnitudes, sign fixed afterwards
//   divide  : 32-cycle restoring divider on magnitudes, sign fixed afterwards
//   latency : 1 (latch) + 32 (run) + 1 (sign fix) cycles, then `done` is held until `ack`
//
// Handshake: the core raises `start` (level) while a MUL/DIV instruction sits in EX. The unit
// samples a/b/funct3 only in S_IDLE, so the operands are latched once and later changes on the
// forwarding network are harmless. `done` stays high until `ack`, which makes the unit safe for
// the step_en-gated SRAM pipeline (the pipeline may not advance in the cycle `done` first rises).
//
// RISC-V special cases: x/0 = all ones, x%0 = x, INT_MIN/-1 = INT_MIN, INT_MIN%-1 = 0.
`timescale 1ns/1ps
module muldiv_unit (
    input         clk,
    input         rst_n,
    input         start,
    input  [2:0]  funct3,
    input  [31:0] a,
    input  [31:0] b,
    input         ack,
    output        done,
    output [31:0] result
);
    localparam [1:0] S_IDLE = 2'd0, S_RUN = 2'd1, S_FIX = 2'd2, S_DONE = 2'd3;

    reg [1:0]  state;
    reg [5:0]  cnt;
    reg        is_div, want_rem, want_hi, neg, neg_rem;
    reg [31:0] mcand;          // multiplicand (mul) / divisor (div)
    reg [31:0] rem, quo;       // divider registers
    reg [63:0] acc;            // multiplier: {partial sum, multiplier bits}

    // ---- operand preparation (combinational, used only in S_IDLE) ----
    wire        div_op = funct3[2];
    wire        sgn_a  = div_op ? ~funct3[0] : (funct3[1:0] == 2'b01 || funct3[1:0] == 2'b10);
    wire        sgn_b  = div_op ? ~funct3[0] : (funct3[1:0] == 2'b01);
    wire        a_neg  = sgn_a & a[31];
    wire        b_neg  = sgn_b & b[31];
    wire [31:0] mag_a  = a_neg ? (~a + 32'd1) : a;
    wire [31:0] mag_b  = b_neg ? (~b + 32'd1) : b;

    // ---- per-iteration datapaths ----
    wire [32:0] rem_sh = {rem, quo[31]};
    wire        ge     = (rem_sh >= {1'b0, mcand});
    wire [31:0] rem_nx = rem_sh[31:0] - mcand;
    wire [32:0] sum    = {1'b0, acc[63:32]} + (acc[0] ? {1'b0, mcand} : 33'd0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            cnt   <= 6'd0;
        end else begin
            case (state)
                S_IDLE: if (start) begin
                    cnt      <= 6'd0;
                    is_div   <= div_op;
                    want_rem <= funct3[1];                       // REM/REMU
                    want_hi  <= (funct3[1:0] != 2'b00);          // MULH/MULHSU/MULHU
                    if (div_op) begin
                        mcand   <= mag_b;
                        quo     <= mag_a;
                        rem     <= 32'd0;
                        neg     <= (a_neg ^ b_neg) && (b != 32'd0);   // x/0 must stay all-ones
                        neg_rem <= a_neg;
                    end else begin
                        mcand   <= mag_a;
                        acc     <= {32'd0, mag_b};
                        neg     <= a_neg ^ b_neg;
                        neg_rem <= 1'b0;
                    end
                    state <= S_RUN;
                end

                S_RUN: begin
                    if (is_div) begin
                        if (ge) begin
                            rem <= rem_nx;
                            quo <= {quo[30:0], 1'b1};
                        end else begin
                            rem <= rem_sh[31:0];
                            quo <= {quo[30:0], 1'b0};
                        end
                    end else begin
                        acc <= {sum, acc[31:1]};
                    end
                    cnt <= cnt + 6'd1;
                    if (cnt == 6'd31) state <= S_FIX;
                end

                S_FIX: begin
                    if (is_div) begin
                        if (neg)     quo <= ~quo + 32'd1;
                        if (neg_rem) rem <= ~rem + 32'd1;
                    end else if (neg) begin
                        acc <= ~acc + 64'd1;
                    end
                    state <= S_DONE;
                end

                S_DONE: if (ack) state <= S_IDLE;

                default: state <= S_IDLE;
            endcase
        end
    end

    assign done   = (state == S_DONE);
    assign result = is_div ? (want_rem ? rem : quo) : (want_hi ? acc[63:32] : acc[31:0]);
endmodule
