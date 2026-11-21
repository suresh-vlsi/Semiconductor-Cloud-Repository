// Processing element of the output-stationary systolic array (INT8 x INT8 -> INT32 MAC).
`timescale 1ns/1ps
module pe (
    input                     clk,
    input                     rst_n,
    input                     clear,   // synchronous clear of accumulator and pass-through registers
    input                     en,      // accumulate enable
    input  signed [7:0]       a_in,    // from the left neighbour / row feeder
    input  signed [7:0]       b_in,    // from the upper neighbour / column feeder
    output reg signed [7:0]   a_out,   // to the right neighbour (1-cycle delay)
    output reg signed [7:0]   b_out,   // to the lower neighbour (1-cycle delay)
    output reg signed [31:0]  acc
);
    wire signed [15:0] prod = a_in * b_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out <= 8'sd0;
            b_out <= 8'sd0;
            acc   <= 32'sd0;
        end else if (clear) begin
            a_out <= 8'sd0;
            b_out <= 8'sd0;
            acc   <= 32'sd0;
        end else begin
            a_out <= a_in;
            b_out <= b_in;
            if (en) acc <= acc + prod;
        end
    end
endmodule
