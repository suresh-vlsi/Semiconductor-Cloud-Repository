// SoC: RV32IM core + unified RAM + UART + GPIO + SYSCON + INT8 systolic accelerator.
//
// Memory map
//   0x0000_0000 - 0x0000_FFFF  RAM (MEM_AW=14 -> 64 KiB), program loaded here
//   0x2000_0000  UART      +0 W: tx byte          +4 R: bit0 = busy
//   0x3000_0000  GPIO      R/W 32-bit output register
//   0x4000_0000  SYSCON    W: finish simulation (value 1 = PASS)   +8 R: free-running cycle counter
//   0x5000_0000  ACCEL     see accel_top.v
//
// The RAM has two async read ports (fetch + data) and one byte-strobed write port, so it maps to
// registers/LUT-RAM; for FPGA block RAM or an ASIC SRAM macro, make the reads synchronous and add
// a wait state in the core.
`timescale 1ns/1ps
module soc_top #(
    parameter MEM_AW       = 14,          // RAM words = 2**MEM_AW
    parameter CLKS_PER_BIT = 434,
    parameter ACCEL_N      = 4
) (
    input         clk,
    input         rst_n,
    output        uart_txd,
    output [31:0] gpio_out,
    output reg    sim_done,
    output reg [31:0] sim_code
);
    // ---------------- core ----------------
    wire [31:0] imem_addr, imem_rdata;
    wire [31:0] dmem_addr, dmem_wdata, dmem_rdata;
    wire [3:0]  dmem_wstrb;
    wire        dmem_re;

    rv32im_core u_core (
        .clk(clk), .rst_n(rst_n),
        .imem_addr(imem_addr), .imem_rdata(imem_rdata),
        .dmem_addr(dmem_addr), .dmem_wdata(dmem_wdata), .dmem_wstrb(dmem_wstrb),
        .dmem_re(dmem_re), .dmem_rdata(dmem_rdata)
    );

    // ---------------- RAM ----------------
    reg [31:0] mem [0:(1<<MEM_AW)-1];
    assign imem_rdata = mem[imem_addr[MEM_AW+1:2]];

    wire sel_mem  = (dmem_addr[31:16] == 16'h0000);
    wire sel_uart = (dmem_addr[31:12] == 20'h20000);
    wire sel_gpio = (dmem_addr[31:12] == 20'h30000);
    wire sel_sys  = (dmem_addr[31:12] == 20'h40000);
    wire sel_acc  = (dmem_addr[31:12] == 20'h50000);

    wire [MEM_AW-1:0] daddr_w = dmem_addr[MEM_AW+1:2];
    wire [31:0] mem_rd_word = mem[daddr_w];
    reg  [31:0] mem_word;
    always @(posedge clk) begin
        if (sel_mem && |dmem_wstrb) begin
            mem_word = mem[daddr_w];
            if (dmem_wstrb[0]) mem_word[7:0]   = dmem_wdata[7:0];
            if (dmem_wstrb[1]) mem_word[15:8]  = dmem_wdata[15:8];
            if (dmem_wstrb[2]) mem_word[23:16] = dmem_wdata[23:16];
            if (dmem_wstrb[3]) mem_word[31:24] = dmem_wdata[31:24];
            mem[daddr_w] <= mem_word;
        end
    end

    // ---------------- UART ----------------
    wire uart_busy;
    wire uart_start = sel_uart && (dmem_addr[3:2] == 2'b00) && dmem_wstrb[0] && !uart_busy;
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_uart (
        .clk(clk), .rst_n(rst_n), .start(uart_start), .data(dmem_wdata[7:0]),
        .tx(uart_txd), .busy(uart_busy)
    );
`ifndef SYNTHESIS
    // simulation console: echo characters as they are accepted
    always @(posedge clk) if (uart_start) $write("%c", dmem_wdata[7:0]);
`endif

    // ---------------- GPIO / SYSCON / cycle counter ----------------
    reg [31:0] gpio_r;
    reg [31:0] cycle_cnt;
    assign gpio_out = gpio_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_r <= 32'd0; cycle_cnt <= 32'd0; sim_done <= 1'b0; sim_code <= 32'd0;
        end else begin
            cycle_cnt <= cycle_cnt + 32'd1;
            if (sel_gpio && |dmem_wstrb) gpio_r <= dmem_wdata;
            if (sel_sys && dmem_addr[3:2] == 2'b00 && |dmem_wstrb) begin
                sim_done <= 1'b1;
                sim_code <= dmem_wdata;
            end
        end
    end

    // ---------------- accelerator ----------------
    wire [31:0] acc_rdata;
    accel_top #(.N(ACCEL_N)) u_accel (
        .clk(clk), .rst_n(rst_n), .addr(dmem_addr[11:0]), .wdata(dmem_wdata),
        .wstrb(sel_acc ? dmem_wstrb : 4'b0000), .rdata(acc_rdata)
    );

    // ---------------- read mux ----------------
    reg [31:0] rd;
    always @* begin
        rd = 32'd0;
        if (sel_mem)       rd = mem_rd_word;
        else if (sel_uart) rd = (dmem_addr[3:2] == 2'b01) ? {31'd0, uart_busy} : 32'd0;
        else if (sel_gpio) rd = gpio_r;
        else if (sel_sys)  rd = (dmem_addr[3:2] == 2'b10) ? cycle_cnt : 32'd0;
        else if (sel_acc)  rd = acc_rdata;
    end
    assign dmem_rdata = rd;
endmodule
