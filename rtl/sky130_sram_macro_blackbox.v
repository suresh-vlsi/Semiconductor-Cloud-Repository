// Synthesis-only black-box declaration for the SKY130 2 KiB SRAM macro.
// The behavioral model is used for simulation; this declaration prevents
// Yosys from attempting to synthesize the macro's internal memory array.
// Keep the module name, parameters, and ports aligned with the installed PDK.
(* blackbox *)
module sky130_sram_2kbyte_1rw1r_32x512_8 #(
    parameter NUM_WMASKS = 4,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 9,
    parameter RAM_DEPTH = 512,
    parameter VERBOSE = 0
) (
    input  wire                  clk0,
    input  wire                  csb0,
    input  wire                  web0,
    input  wire [NUM_WMASKS-1:0] wmask0,
    input  wire [ADDR_WIDTH-1:0] addr0,
    input  wire [DATA_WIDTH-1:0] din0,
    output wire [DATA_WIDTH-1:0] dout0,
    input  wire                  clk1,
    input  wire                  csb1,
    input  wire [ADDR_WIDTH-1:0] addr1,
    output wire [DATA_WIDTH-1:0] dout1
);
endmodule
