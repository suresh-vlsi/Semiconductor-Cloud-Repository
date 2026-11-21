// Simple 8N1 UART transmitter. 'start' is a one-cycle pulse, ignored while busy.
`timescale 1ns/1ps
module uart_tx #(
    parameter CLKS_PER_BIT = 434          // 50 MHz / 115200
) (
    input            clk,
    input            rst_n,
    input            start,
    input  [7:0]     data,
    output reg       tx,
    output           busy
);
    reg [9:0]  shreg;                     // {stop, data[7:0], start}
    reg [3:0]  bitcnt;
    reg [15:0] cnt;
    reg        active;
    assign busy = active;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx <= 1'b1; active <= 1'b0; cnt <= 16'd0; bitcnt <= 4'd0; shreg <= 10'h3FF;
        end else if (!active) begin
            tx <= 1'b1;
            if (start) begin
                shreg <= {1'b1, data, 1'b0};
                active <= 1'b1; cnt <= 16'd0; bitcnt <= 4'd0;
                tx <= 1'b0;
            end
        end else begin
            if (cnt == CLKS_PER_BIT-1) begin
                cnt <= 16'd0;
                if (bitcnt == 4'd9) begin
                    active <= 1'b0; tx <= 1'b1;
                end else begin
                    bitcnt <= bitcnt + 4'd1;
                    tx <= shreg[bitcnt + 4'd1];
                end
            end else begin
                cnt <= cnt + 16'd1;
            end
        end
    end
endmodule
