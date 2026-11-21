// SRAM-backed RV32IM + UART/GPIO/SYSCON/INT8 accelerator SoC.
// The CPU pipeline advances only when the current instruction fetch and
// current MEM-stage transaction have both completed.
`timescale 1ns/1ps
module soc_top_sram #(
    parameter CLKS_PER_BIT = 434,
    parameter ACCEL_N = 4
) (
    input clk,
    input rst_n,
    output uart_txd,
    output [31:0] gpio_out,
    output reg sim_done,
    output reg [31:0] sim_code
);
    wire [31:0] imem_addr, imem_rdata;
    wire [31:0] dmem_addr, dmem_wdata, dmem_rdata;
    wire [3:0] dmem_wstrb;
    wire dmem_re;
    wire step_en;

    rv32im_core_sram u_core (
        .clk(clk), .rst_n(rst_n), .step_en(step_en),
        .imem_addr(imem_addr), .imem_rdata(imem_rdata),
        .dmem_addr(dmem_addr), .dmem_wdata(dmem_wdata),
        .dmem_wstrb(dmem_wstrb), .dmem_re(dmem_re), .dmem_rdata(dmem_rdata)
    );

    wire sel_ram  = (dmem_addr[31:16] == 16'h0000);
    wire sel_uart = (dmem_addr[31:12] == 20'h20000);
    wire sel_gpio = (dmem_addr[31:12] == 20'h30000);
    wire sel_sys  = (dmem_addr[31:12] == 20'h40000);
    wire sel_acc  = (dmem_addr[31:12] == 20'h50000);
    wire data_need = dmem_re || (|dmem_wstrb);

    reg if_sent, if_done;
    reg data_sent, data_done;
    reg [31:0] if_data_q, data_data_q;
    wire if_req, if_req_ready, if_resp_valid;
    wire [31:0] if_rdata;
    wire data_req, data_req_ready, data_resp_valid;
    wire [31:0] data_rdata_macro;

    // Requests remain asserted until accepted; sent flags prevent duplicates.
    assign if_req = rst_n && !if_sent && !if_done;
    assign data_req = rst_n && data_need && sel_ram && !data_sent && !data_done;

    sky130_sram_64kb u_sram (
        .clk(clk), .rst_n(rst_n),
        .if_req(if_req), .if_req_ready(if_req_ready), .if_addr(imem_addr),
        .if_resp_valid(if_resp_valid), .if_rdata(if_rdata),
        .data_req(data_req), .data_req_ready(data_req_ready),
        .data_we(|dmem_wstrb), .data_addr(dmem_addr),
        .data_wdata(dmem_wdata), .data_wstrb(dmem_wstrb),
        .data_resp_valid(data_resp_valid), .data_rdata(data_rdata_macro)
    );

    // MMIO read data is captured once at acceptance. Writes are one-cycle pulses.
    wire uart_busy;
    wire mmio_need = data_need && !sel_ram;
    wire mmio_accept = mmio_need && !data_done;
    wire uart_start = mmio_accept && sel_uart && (dmem_addr[3:2] == 2'b00) && dmem_wstrb[0] && !uart_busy;
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u_uart (
        .clk(clk), .rst_n(rst_n), .start(uart_start), .data(dmem_wdata[7:0]),
        .tx(uart_txd), .busy(uart_busy)
    );
`ifndef SYNTHESIS
    always @(posedge clk) if (uart_start) $write("%c", dmem_wdata[7:0]);
`endif

    reg [31:0] gpio_r, cycle_cnt;
    wire [31:0] acc_rdata;
    wire [3:0] acc_wstrb = (mmio_accept && sel_acc) ? dmem_wstrb : 4'b0000;
    accel_top #(.N(ACCEL_N)) u_accel (
        .clk(clk), .rst_n(rst_n), .addr(dmem_addr[11:0]),
        .wdata(dmem_wdata), .wstrb(acc_wstrb), .rdata(acc_rdata)
    );
    assign gpio_out = gpio_r;

    reg [31:0] mmio_rdata;
    always @* begin
        mmio_rdata = 32'd0;
        if (sel_uart) mmio_rdata = (dmem_addr[3:2] == 2'b01) ? {31'd0, uart_busy} : 32'd0;
        else if (sel_gpio) mmio_rdata = gpio_r;
        else if (sel_sys) mmio_rdata = (dmem_addr[3:2] == 2'b10) ? cycle_cnt : 32'd0;
        else if (sel_acc) mmio_rdata = acc_rdata;
    end

    assign imem_rdata = if_data_q;
    assign dmem_rdata = data_data_q;
    assign step_en = if_done && (!data_need || data_done);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            if_sent <= 1'b0; if_done <= 1'b0; if_data_q <= 32'd0;
            data_sent <= 1'b0; data_done <= 1'b0; data_data_q <= 32'd0;
            gpio_r <= 32'd0; cycle_cnt <= 32'd0;
            sim_done <= 1'b0; sim_code <= 32'd0;
        end else begin
            cycle_cnt <= cycle_cnt + 32'd1;

            if (step_en) begin
                if_sent <= 1'b0;
                if_done <= 1'b0;
                data_sent <= 1'b0;
                data_done <= 1'b0;
            end else begin
                if (if_req && if_req_ready) if_sent <= 1'b1;
                if (if_resp_valid) begin
                    if_data_q <= if_rdata;
                    if_done <= 1'b1;
                    if_sent <= 1'b0;
                end
                if (data_req && data_req_ready) data_sent <= 1'b1;
                if (data_resp_valid) begin
                    data_data_q <= data_rdata_macro;
                    data_done <= 1'b1;
                    data_sent <= 1'b0;
                end
                if (mmio_accept) begin
                    data_data_q <= mmio_rdata;
                    data_done <= 1'b1;
                end
            end

            if (mmio_accept && sel_gpio && |dmem_wstrb) gpio_r <= dmem_wdata;
            if (mmio_accept && sel_sys && dmem_addr[3:2] == 2'b00 && |dmem_wstrb) begin
                sim_done <= 1'b1;
                sim_code <= dmem_wdata;
            end
        end
    end
endmodule
