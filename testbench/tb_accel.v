// Standalone self-checking testbench for accel_top (systolic array + control FSM).
// Random INT8 matrices (including -128 corners) are multiplied and compared with a behavioural model.
`timescale 1ns/1ps
`ifndef ACCEL_N
`define ACCEL_N 4
`endif
module tb_accel;
    localparam N = `ACCEL_N;
    localparam ITER = 200;

    reg         clk = 1'b0;
    reg         rst_n = 1'b0;
    reg  [11:0] addr = 12'd0;
    reg  [31:0] wdata = 32'd0;
    reg  [3:0]  wstrb = 4'd0;
    wire [31:0] rdata;
    always #5 clk = ~clk;

    accel_top #(.N(N)) dut (.clk(clk), .rst_n(rst_n), .addr(addr), .wdata(wdata), .wstrb(wstrb), .rdata(rdata));

    reg signed [7:0]  A [0:N*N-1];
    reg signed [7:0]  B [0:N*N-1];
    reg signed [31:0] expC [0:N*N-1];
    integer errors = 0;
    integer it, i, j, k, w, polls;
    reg signed [31:0] sum;
    reg [31:0] rd;

    task bus_write(input [11:0] a, input [31:0] d);
        begin
            @(negedge clk); addr = a; wdata = d; wstrb = 4'hF;
            @(negedge clk); wstrb = 4'h0; addr = 12'd0;
        end
    endtask

    task bus_read(input [11:0] a, output [31:0] d);
        begin
            @(negedge clk); addr = a;
            #1 d = rdata;
        end
    endtask

    initial begin
        repeat (4) @(posedge clk);
        rst_n = 1'b1;
        for (it = 0; it < ITER; it = it + 1) begin
            for (i = 0; i < N*N; i = i + 1) begin
                A[i] = (it < 4) ? ((it[0]) ? -8'sd128 : 8'sd127) : $random;
                B[i] = (it < 4) ? ((it[1]) ? -8'sd128 : 8'sd127) : $random;
            end
            for (i = 0; i < N; i = i + 1)
                for (j = 0; j < N; j = j + 1) begin
                    sum = 0;
                    for (k = 0; k < N; k = k + 1) sum = sum + A[i*N+k] * B[k*N+j];
                    expC[i*N+j] = sum;
                end
            for (w = 0; w < N*N/4; w = w + 1) begin
                bus_write(12'h100 + 4*w, {A[4*w+3], A[4*w+2], A[4*w+1], A[4*w]});
                bus_write(12'h200 + 4*w, {B[4*w+3], B[4*w+2], B[4*w+1], B[4*w]});
            end
            bus_write(12'h000, 32'd1);                       // start
            polls = 0;
            rd = 0;
            while (!rd[1] && polls < 1000) begin
                bus_read(12'h004, rd);
                polls = polls + 1;
            end
            if (!rd[1]) begin
                errors = errors + 1;
                $display("iter %0d: timeout waiting for DONE", it);
            end
            for (i = 0; i < N*N; i = i + 1) begin
                bus_read(12'h300 + 4*i, rd);
                if (rd !== expC[i]) begin
                    errors = errors + 1;
                    $display("iter %0d: C[%0d] = %0d, expected %0d", it, i, $signed(rd), expC[i]);
                end
            end
        end
        $display("");
        if (errors == 0) $display("TEST PASSED (%0d random %0dx%0d matmuls)", ITER, N, N);
        else             $display("TEST FAILED errors=%0d", errors);
        $finish;
    end

    initial begin
        #50_000_000;
        $display("TEST TIMEOUT");
        $finish;
    end
endmodule
