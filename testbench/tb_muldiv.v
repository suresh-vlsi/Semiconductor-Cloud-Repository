// Self-checking testbench for rtl/muldiv_unit.v.
// Reference is the behavioural one-cycle formulation that the original core used and that passed
// the full regression. Checks all 8 funct3 values on corner and random operands, verifies that
// `done` is held (result stable) until `ack`, and that operand changes after start are ignored.
//   make muldiv_tb
`timescale 1ns/1ps
module tb_muldiv;
    reg         clk = 1'b0;
    reg         rst_n = 1'b0;
    reg         start = 1'b0;
    reg         ack = 1'b0;
    reg  [2:0]  f3 = 3'd0;
    reg  [31:0] a = 32'd0, b = 32'd0;
    wire        done;
    wire [31:0] result;
    always #5 clk = ~clk;

    muldiv_unit dut (.clk(clk), .rst_n(rst_n), .start(start), .funct3(f3), .a(a), .b(b),
                     .ack(ack), .done(done), .result(result));

    function [31:0] golden;
        input [2:0]  f;
        input [31:0] x, y;
        reg [63:0] uu, ss, su;
        reg signed [31:0] sq, sr;
        begin
            uu = {32'd0, x} * {32'd0, y};
            ss = $signed({{32{x[31]}}, x}) * $signed({{32{y[31]}}, y});
            su = $signed({{32{x[31]}}, x}) * $signed({32'd0, y});
            if (y == 32'd0) begin
                sq = -32'sd1; sr = x;
            end else if (x == 32'h8000_0000 && y == 32'hFFFF_FFFF) begin
                sq = 32'h8000_0000; sr = 32'd0;
            end else begin
                sq = $signed(x) / $signed(y);
                sr = $signed(x) % $signed(y);
            end
            case (f)
                3'd0:    golden = uu[31:0];
                3'd1:    golden = ss[63:32];
                3'd2:    golden = su[63:32];
                3'd3:    golden = uu[63:32];
                3'd4:    golden = sq;
                3'd5:    golden = (y == 32'd0) ? 32'hFFFF_FFFF : (x / y);
                3'd6:    golden = sr;
                default: golden = (y == 32'd0) ? x : (x % y);
            endcase
        end
    endfunction

    integer errors = 0;
    integer total  = 0;
    integer cycles;
    reg [31:0] snap;
    reg [31:0] corners [0:15];

    task run_op;
        input [2:0]  f;
        input [31:0] x, y;
        input        hold_test;      // 1: wait several cycles before ack and scramble the operands
        begin
            @(negedge clk);
            f3 = f; a = x; b = y; start = 1'b1; ack = 1'b0;
            cycles = 0;
            @(posedge clk); #1;                              // latch edge (+1 ns: avoid racing the DUT)
            if (hold_test) begin a = ~x; b = ~y; end         // operands must already be latched
            while (!done && cycles < 100) begin
                @(posedge clk); #1;
                cycles = cycles + 1;
            end
            total = total + 1;
            if (!done) begin
                errors = errors + 1;
                $display("FAIL f3=%0d a=%h b=%h : timeout", f, x, y);
            end else begin
                if (result !== golden(f, x, y)) begin
                    errors = errors + 1;
                    $display("FAIL f3=%0d a=%h b=%h : got %h, expected %h", f, x, y, result, golden(f, x, y));
                end
                if (hold_test) begin
                    snap = result;
                    repeat (5) @(posedge clk);
                    #1;
                    if (!done || result !== snap) begin
                        errors = errors + 1;
                        $display("FAIL f3=%0d a=%h b=%h : done/result not held until ack", f, x, y);
                    end
                end
            end
            @(negedge clk); ack = 1'b1;
            @(negedge clk); ack = 1'b0; start = 1'b0;
        end
    endtask

    integer i, j, k;
    initial begin
        corners[0]  = 32'h0000_0000; corners[1]  = 32'h0000_0001; corners[2]  = 32'h0000_0002;
        corners[3]  = 32'h0000_0003; corners[4]  = 32'h0000_0007; corners[5]  = 32'h0000_00FF;
        corners[6]  = 32'h0000_FFFF; corners[7]  = 32'h7FFF_FFFF; corners[8]  = 32'h8000_0000;
        corners[9]  = 32'h8000_0001; corners[10] = 32'hFFFF_FFFF; corners[11] = 32'hFFFF_FFFE;
        corners[12] = 32'h1234_5678; corners[13] = 32'hDEAD_BEEF; corners[14] = 32'h5555_5555;
        corners[15] = 32'hAAAA_AAAA;
        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        for (k = 0; k < 8; k = k + 1) begin
            for (i = 0; i < 16; i = i + 1)
                for (j = 0; j < 16; j = j + 1)
                    run_op(k[2:0], corners[i], corners[j], (i + j) % 7 == 0);
            for (i = 0; i < 300; i = i + 1)
                run_op(k[2:0], $urandom, $urandom, i % 11 == 0);
            for (i = 0; i < 100; i = i + 1)                  // small divisors / multipliers
                run_op(k[2:0], $urandom, $urandom >> ($urandom % 32), 1'b0);
        end
        $display("");
        if (errors == 0) $display("TEST PASSED (%0d operations)", total);
        else             $display("TEST FAILED errors=%0d of %0d", errors, total);
        $finish;
    end

    initial begin
        #200_000_000;
        $display("TEST TIMEOUT");
        $finish;
    end
endmodule
