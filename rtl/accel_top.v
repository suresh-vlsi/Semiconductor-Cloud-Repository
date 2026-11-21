// Memory-mapped INT8 matrix-multiply accelerator: C(NxN, int32) = A(NxN, int8) x B(NxN, int8).
//
// Register map (offsets from the accelerator base):
//   0x000  CTRL    W   bit0 = start (ignored while busy)
//   0x004  STATUS  R   bit0 = busy, bit1 = done (cleared on start)
//   0x008  INFO    R   N
//   0x100  A       W   A[i][k] byte at 0x100 + i*N + k   (byte-strobed writes)
//   0x200  B       W   B[k][j] byte at 0x200 + k*N + j
//   0x300  C       R   C[i][j] word at 0x300 + 4*(i*N + j)
// N must be 4 or 8 (A/B windows are 256 B, C window is 256 B -> N*N <= 64).
`timescale 1ns/1ps
module accel_top #(
    parameter N = 4
) (
    input             clk,
    input             rst_n,
    input  [11:0]     addr,
    input  [31:0]     wdata,
    input  [3:0]      wstrb,     // already qualified by the address decoder
    output reg [31:0] rdata
);
    reg [8*N*N-1:0] a_flat, b_flat;

    // ---------------- operand buffers (statically decoded byte writes) ----------------
    genvar byte_idx;
    generate
        for (byte_idx = 0; byte_idx < N*N; byte_idx = byte_idx + 1) begin : OPERAND_BYTE_WRITES

            wire a_byte_we;
            wire b_byte_we;

            assign a_byte_we =
                wstrb[byte_idx % 4] &&
                (addr[11:8] == 4'h1) &&
                (addr[7:2] == (byte_idx / 4));

            assign b_byte_we =
                wstrb[byte_idx % 4] &&
                (addr[11:8] == 4'h2) &&
                (addr[7:2] == (byte_idx / 4));

            always @(posedge clk) begin
                if (a_byte_we)
                    a_flat[8*byte_idx +: 8] <=
                        wdata[8*(byte_idx % 4) +: 8];

                if (b_byte_we)
                    b_flat[8*byte_idx +: 8] <=
                        wdata[8*(byte_idx % 4) +: 8];
            end
        end
    endgenerate

    // ---------------- control FSM ----------------
    localparam S_IDLE = 2'd0, S_CLEAR = 2'd1, S_RUN = 2'd2;
    reg [1:0] state;
    reg [7:0] t;
    reg       done;
    wire      start = (addr == 12'h000) && wstrb[0] && wdata[0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE; t <= 8'd0; done <= 1'b0;
        end else begin
            case (state)
                S_IDLE:  if (start) begin state <= S_CLEAR; done <= 1'b0; end
                S_CLEAR: begin state <= S_RUN; t <= 8'd0; end
                S_RUN:   if (t == 3*N-3) begin state <= S_IDLE; done <= 1'b1; end
                         else t <= t + 8'd1;
                default: state <= S_IDLE;
            endcase
        end
    end

    wire clear = (state == S_CLEAR);
    wire en    = (state == S_RUN);
    wire busy  = (state != S_IDLE);

    // ---------------- skewed edge feeders ----------------
    reg [8*N-1:0] a_edge, b_edge;
    integer ii;
    always @* begin
        for (ii = 0; ii < N; ii = ii + 1) begin
            if (en && t >= ii && (t - ii) < N) begin
                a_edge[8*ii +: 8] = a_flat[8*(ii*N + (t-ii)) +: 8];     // A[ii][t-ii]
                b_edge[8*ii +: 8] = b_flat[8*((t-ii)*N + ii) +: 8];     // B[t-ii][ii]
            end else begin
                a_edge[8*ii +: 8] = 8'd0;
                b_edge[8*ii +: 8] = 8'd0;
            end
        end
    end

    wire [32*N*N-1:0] c_flat;
    systolic_array #(.N(N)) u_array (
        .clk(clk), .rst_n(rst_n), .clear(clear), .en(en),
        .a_edge(a_edge), .b_edge(b_edge), .c_flat(c_flat)
    );

    // ---------------- read mux ----------------
    wire [5:0] cidx = addr[7:2];
    always @* begin
        rdata = 32'd0;
        case (addr[11:8])
            4'h0: begin
                if (addr[7:0] == 8'h04)      rdata = {30'd0, done, busy};
                else if (addr[7:0] == 8'h08) rdata = N;
            end
            4'h3: if (cidx < N*N) rdata = c_flat[32*cidx +: 32];
            default: rdata = 32'd0;
        endcase
    end
endmodule
