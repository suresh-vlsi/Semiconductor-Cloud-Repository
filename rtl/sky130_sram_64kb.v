// ============================================================
// Module: sky130_sram_64kb
// Description:
//   64 KiB SRAM using 32 x SKY130 2 KiB SRAM macros.
//
//   Port 1: Instruction read
//   Port 0: Data read/write
//
// Addressing:
//   Byte address [15:11] = SRAM bank
//   Byte address [10:2]  = word within bank
//   Byte address [1:0]   = byte offset
//
// Protocol:
//   Request is accepted when req && req_ready.
//   Response arrives later with resp_valid.
//   Requester must deassert req after acceptance.
// ============================================================

module sky130_sram_64kb (
    input  wire        clk,
    input  wire        rst_n,

    // Instruction read interface
    input  wire        if_req,
    output wire        if_req_ready,
    input  wire [31:0] if_addr,
    output reg         if_resp_valid,
    output reg  [31:0] if_rdata,

    // Data read/write interface
    input  wire        data_req,
    output wire        data_req_ready,
    input  wire        data_we,
    input  wire [31:0] data_addr,
    input  wire [31:0] data_wdata,
    input  wire [3:0]  data_wstrb,
    output reg         data_resp_valid,
    output reg  [31:0] data_rdata
);

    // 32 SRAM banks, each containing 512 x 32-bit words.
    wire [31:0] bank_dout0 [0:31];
    wire [31:0] bank_dout1 [0:31];

    reg if_pending;
    reg data_pending;

    reg [4:0] if_bank_q;
    reg [4:0] data_bank_q;

    wire same_address_write;
    wire if_addr_valid;
    wire data_addr_valid;

    // This wrapper covers byte addresses 0x00000000-0x0000FFFF.
    // Instruction fetches must be word-aligned.
    assign if_addr_valid =
        (if_addr[31:16] == 16'h0000) &&
        (if_addr[1:0] == 2'b00);

    assign data_addr_valid =
        (data_addr[31:16] == 16'h0000);

    // Prevent simultaneous instruction read and data write
    // to the same physical word.
    assign same_address_write =
        if_req && data_req && data_we &&
        (if_addr[15:2] == data_addr[15:2]);

    // Invalid addresses are not accepted.
    assign data_req_ready = ~data_pending && data_addr_valid;

    assign if_req_ready =
        ~if_pending && if_addr_valid && ~same_address_write;

    // Generate all 32 SRAM macros.
    genvar g;
    generate
        for (g = 0; g < 32; g = g + 1) begin : SRAM_BANKS

            wire csb0;
            wire csb1;
            wire [3:0] bank_wmask;


            // Port 0: Data read/write.
            assign csb0 =
                ~(data_req &&
                  data_req_ready &&
                  (data_addr[15:11] == g));

            // Port 1: Instruction read.
            assign csb1 =
                ~(if_req &&
                  if_req_ready &&
                  (if_addr[15:11] == g));

            // Localize write-mask loading to the selected SRAM bank.
            assign bank_wmask = data_wstrb & {4{~csb0}};

            sky130_sram_2kbyte_1rw1r_32x512_8 #(
                .NUM_WMASKS (4),
                .DATA_WIDTH (32),
                .ADDR_WIDTH (9),
                .RAM_DEPTH  (512),
                .VERBOSE    (0)
            ) sram_macro (
                .clk0   (clk),
                .csb0   (csb0),
                .web0   (~data_we),
                .wmask0 (bank_wmask),
                .addr0  (data_addr[10:2]),
                .din0   (data_wdata),
                .dout0  (bank_dout0[g]),

                .clk1   (clk),
                .csb1   (csb1),
                .addr1  (if_addr[10:2]),
                .dout1  (bank_dout1[g])
            );

        end
    endgenerate

    // Request tracking and response generation.
    // The macro captures requests on the rising edge.
    // Its behavioral model produces read data after the
    // falling edge. We capture that result at the next
    // rising edge.

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            if_pending       <= 1'b0;
            data_pending     <= 1'b0;

            if_bank_q        <= 5'd0;
            data_bank_q      <= 5'd0;

            if_resp_valid    <= 1'b0;
            data_resp_valid  <= 1'b0;

            if_rdata         <= 32'd0;
            data_rdata       <= 32'd0;
        end
        else begin
            if_resp_valid   <= 1'b0;
            data_resp_valid <= 1'b0;

            // Complete instruction read.
            if (if_pending) begin
                if_rdata      <= bank_dout1[if_bank_q];
                if_resp_valid <= 1'b1;
                if_pending    <= 1'b0;
            end
            else if (if_req && if_req_ready) begin
                if_pending <= 1'b1;
                if_bank_q  <= if_addr[15:11];
            end

            // Complete data read or write.
            if (data_pending) begin
                data_rdata      <= bank_dout0[data_bank_q];
                data_resp_valid <= 1'b1;
                data_pending    <= 1'b0;
            end
            else if (data_req && data_req_ready) begin
                data_pending <= 1'b1;
                data_bank_q  <= data_addr[15:11];
            end
        end
    end

endmodule
