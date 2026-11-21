// Full-SoC testbench. Usage:
//   vvp sim.vvp +HEX=testbench/programs/hello.hex [+TIMEOUT=200000]
// Prints exactly one of: TEST PASSED / TEST FAILED code=N / TEST TIMEOUT, then cycle statistics.
`timescale 1ns/1ps
`ifndef ACCEL_N
`define ACCEL_N 4
`endif
module tb_soc;
    localparam MEM_AW = 14;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    always #5 clk = ~clk;                       // 100 MHz

    wire        uart_txd;
    wire [31:0] gpio_out;
    wire        sim_done;
    wire [31:0] sim_code;

    soc_top #(.MEM_AW(MEM_AW), .CLKS_PER_BIT(4), .ACCEL_N(`ACCEL_N)) dut (
        .clk(clk), .rst_n(rst_n), .uart_txd(uart_txd), .gpio_out(gpio_out),
        .sim_done(sim_done), .sim_code(sim_code)
    );

    reg [1023:0] hexfile;
    integer timeout_cycles;
    integer cyc;
    integer k;

    initial begin
        cyc = 0;
        if (!$value$plusargs("HEX=%s", hexfile)) begin
            $display("ERROR: +HEX=<program.hex> is required");
            $finish;
        end
        if (!$value$plusargs("TIMEOUT=%d", timeout_cycles)) timeout_cycles = 200000;
        for (k = 0; k < (1 << MEM_AW); k = k + 1) dut.mem[k] = 32'd0;
        $readmemh(hexfile, dut.mem);
`ifdef DUMP
        $dumpfile("simulation_logs/soc.vcd");
        $dumpvars(0, tb_soc);
`endif
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
    end

    always @(posedge clk) if (rst_n) begin
        cyc <= cyc + 1;
        if (sim_done) begin
            $display("");
            if (sim_code == 32'd1) $display("TEST PASSED");
            else                   $display("TEST FAILED code=%0d", sim_code);
            $display("TOTAL_CYCLES=%0d KERNEL_CYCLES=%0d", cyc, gpio_out);
            $finish;
        end else if (cyc >= timeout_cycles) begin
            $display("");
            $display("TEST TIMEOUT after %0d cycles", cyc);
            $finish;
        end
    end
endmodule
