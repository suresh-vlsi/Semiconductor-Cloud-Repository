// SRAM-backed full-SoC testbench. Requires the SKY130 SRAM behavioral model.
`timescale 1ns/1ps
`ifndef ACCEL_N
`define ACCEL_N 4
`endif
module tb_soc_sram;
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    always #5 clk = ~clk;
    wire uart_txd;
    wire [31:0] gpio_out;
    wire sim_done;
    wire [31:0] sim_code;
    soc_top_sram #(.CLKS_PER_BIT(4), .ACCEL_N(`ACCEL_N)) dut (
        .clk(clk), .rst_n(rst_n), .uart_txd(uart_txd), .gpio_out(gpio_out),
        .sim_done(sim_done), .sim_code(sim_code)
    );
    reg [31:0] image [0:16383];
    reg [1023:0] hexfile;
    integer timeout_cycles, cyc, k;
    initial begin
        cyc = 0;
        if (!$value$plusargs("HEX=%s", hexfile)) begin $display("ERROR: +HEX=<program.hex> required"); $finish; end
        if (!$value$plusargs("TIMEOUT=%d", timeout_cycles)) timeout_cycles = 1000000;
        for (k=0; k<16384; k=k+1) image[k] = 32'd0;
        $readmemh(hexfile, image);
        // Load contiguous software image into the 32 interleaved 512-word macros.
        for (k=0; k<16384; k=k+1) begin
            case (k / 512)
                0: dut.u_sram.SRAM_BANKS[0].sram_macro.mem[k % 512] = image[k];
                1: dut.u_sram.SRAM_BANKS[1].sram_macro.mem[k % 512] = image[k];
                2: dut.u_sram.SRAM_BANKS[2].sram_macro.mem[k % 512] = image[k];
                3: dut.u_sram.SRAM_BANKS[3].sram_macro.mem[k % 512] = image[k];
                4: dut.u_sram.SRAM_BANKS[4].sram_macro.mem[k % 512] = image[k];
                5: dut.u_sram.SRAM_BANKS[5].sram_macro.mem[k % 512] = image[k];
                6: dut.u_sram.SRAM_BANKS[6].sram_macro.mem[k % 512] = image[k];
                7: dut.u_sram.SRAM_BANKS[7].sram_macro.mem[k % 512] = image[k];
                8: dut.u_sram.SRAM_BANKS[8].sram_macro.mem[k % 512] = image[k];
                9: dut.u_sram.SRAM_BANKS[9].sram_macro.mem[k % 512] = image[k];
                10: dut.u_sram.SRAM_BANKS[10].sram_macro.mem[k % 512] = image[k];
                11: dut.u_sram.SRAM_BANKS[11].sram_macro.mem[k % 512] = image[k];
                12: dut.u_sram.SRAM_BANKS[12].sram_macro.mem[k % 512] = image[k];
                13: dut.u_sram.SRAM_BANKS[13].sram_macro.mem[k % 512] = image[k];
                14: dut.u_sram.SRAM_BANKS[14].sram_macro.mem[k % 512] = image[k];
                15: dut.u_sram.SRAM_BANKS[15].sram_macro.mem[k % 512] = image[k];
                16: dut.u_sram.SRAM_BANKS[16].sram_macro.mem[k % 512] = image[k];
                17: dut.u_sram.SRAM_BANKS[17].sram_macro.mem[k % 512] = image[k];
                18: dut.u_sram.SRAM_BANKS[18].sram_macro.mem[k % 512] = image[k];
                19: dut.u_sram.SRAM_BANKS[19].sram_macro.mem[k % 512] = image[k];
                20: dut.u_sram.SRAM_BANKS[20].sram_macro.mem[k % 512] = image[k];
                21: dut.u_sram.SRAM_BANKS[21].sram_macro.mem[k % 512] = image[k];
                22: dut.u_sram.SRAM_BANKS[22].sram_macro.mem[k % 512] = image[k];
                23: dut.u_sram.SRAM_BANKS[23].sram_macro.mem[k % 512] = image[k];
                24: dut.u_sram.SRAM_BANKS[24].sram_macro.mem[k % 512] = image[k];
                25: dut.u_sram.SRAM_BANKS[25].sram_macro.mem[k % 512] = image[k];
                26: dut.u_sram.SRAM_BANKS[26].sram_macro.mem[k % 512] = image[k];
                27: dut.u_sram.SRAM_BANKS[27].sram_macro.mem[k % 512] = image[k];
                28: dut.u_sram.SRAM_BANKS[28].sram_macro.mem[k % 512] = image[k];
                29: dut.u_sram.SRAM_BANKS[29].sram_macro.mem[k % 512] = image[k];
                30: dut.u_sram.SRAM_BANKS[30].sram_macro.mem[k % 512] = image[k];
                31: dut.u_sram.SRAM_BANKS[31].sram_macro.mem[k % 512] = image[k];
                default: ;
            endcase
        end
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
    end
    always @(posedge clk) if (rst_n) begin
        cyc <= cyc + 1;
        if (sim_done) begin
            if (sim_code == 1) $display("TEST PASSED");
            else $display("TEST FAILED code=%0d", sim_code);
            $display("TOTAL_CYCLES=%0d KERNEL_CYCLES=%0d", cyc, gpio_out);
            $finish;
        end else if (cyc >= timeout_cycles) begin
            $display("TEST TIMEOUT after %0d cycles", cyc);
            $finish;
        end
    end
endmodule
