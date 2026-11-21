`timescale 1ns/1ps

module tb_sky130_sram_64kb;

    reg clk = 0;
    reg rst_n = 0;

    reg if_req = 0;
    wire if_req_ready;
    reg [31:0] if_addr = 0;
    wire if_resp_valid;
    wire [31:0] if_rdata;

    reg data_req = 0;
    wire data_req_ready;
    reg data_we = 0;
    reg [31:0] data_addr = 0;
    reg [31:0] data_wdata = 0;
    reg [3:0] data_wstrb = 0;
    wire data_resp_valid;
    wire [31:0] data_rdata;

    integer tests = 0;

    always #5 clk = ~clk;

    sky130_sram_64kb dut (
        .clk(clk),
        .rst_n(rst_n),

        .if_req(if_req),
        .if_req_ready(if_req_ready),
        .if_addr(if_addr),
        .if_resp_valid(if_resp_valid),
        .if_rdata(if_rdata),

        .data_req(data_req),
        .data_req_ready(data_req_ready),
        .data_we(data_we),
        .data_addr(data_addr),
        .data_wdata(data_wdata),
        .data_wstrb(data_wstrb),
        .data_resp_valid(data_resp_valid),
        .data_rdata(data_rdata)
    );

    task data_transaction;
        input [31:0] addr;
        input write_enable;
        input [31:0] write_data;
        input [3:0] write_mask;
        input check_read;
        input [31:0] expected;

        begin
            @(negedge clk);
            while (!data_req_ready)
                @(negedge clk);

            data_addr  = addr;
            data_we    = write_enable;
            data_wdata = write_data;
            data_wstrb = write_mask;
            data_req   = 1;

            @(posedge clk);
            #1;
            @(negedge clk);
            data_req = 0;

            @(posedge clk);
            #1;

            if (!data_resp_valid)
                $fatal(1, "DATA RESPONSE TIMEOUT at %h", addr);

            if (check_read && data_rdata !== expected)
                $fatal(1,
                    "DATA MISMATCH addr=%h expected=%h actual=%h",
                    addr, expected, data_rdata);

            tests = tests + 1;
            $display("PASS DATA addr=%h write=%b data=%h",
                     addr, write_enable, data_rdata);
        end
    endtask

    task instruction_read;
        input [31:0] addr;
        input [31:0] expected;

        begin
            @(negedge clk);
            while (!if_req_ready)
                @(negedge clk);

            if_addr = addr;
            if_req  = 1;

            @(posedge clk);
            #1;
            @(negedge clk);
            if_req = 0;

            @(posedge clk);
            #1;

            if (!if_resp_valid)
                $fatal(1, "INSTRUCTION RESPONSE TIMEOUT at %h", addr);

            if (if_rdata !== expected)
                $fatal(1,
                    "INSTRUCTION MISMATCH addr=%h expected=%h actual=%h",
                    addr, expected, if_rdata);

            tests = tests + 1;
            $display("PASS INSTRUCTION addr=%h data=%h",
                     addr, if_rdata);
        end
    endtask

    initial begin
        $display("======================================");
        $display(" SKY130 64 KiB SRAM TEST");
        $display("======================================");

        repeat (3) @(negedge clk);
        rst_n = 1;

        // Initialize one word in four different banks.
        data_transaction(32'h00000000, 1, 32'h11223344, 4'b1111, 0, 0);
        data_transaction(32'h00000800, 1, 32'h55667788, 4'b1111, 0, 0);
        data_transaction(32'h00001000, 1, 32'h99AABBCC, 4'b1111, 0, 0);
        data_transaction(32'h0000F800, 1, 32'hDDEEFF00, 4'b1111, 0, 0);

        // Read back all four banks.
        data_transaction(32'h00000000, 0, 0, 0, 1, 32'h11223344);
        data_transaction(32'h00000800, 0, 0, 0, 1, 32'h55667788);
        data_transaction(32'h00001000, 0, 0, 0, 1, 32'h99AABBCC);
        data_transaction(32'h0000F800, 0, 0, 0, 1, 32'hDDEEFF00);

        // Update bytes 0 and 2 only.
        data_transaction(32'h00000800, 1, 32'hAABBCCDD,
                         4'b0101, 0, 0);

        // Expected: byte 3=55, byte 2=BB, byte 1=77, byte 0=DD.
        data_transaction(32'h00000800, 0, 0, 0, 1, 32'h55BB77DD);

        // Instruction-port reads.
        instruction_read(32'h00000000, 32'h11223344);
        instruction_read(32'h00000800, 32'h55BB77DD);
        instruction_read(32'h0000F800, 32'hDDEEFF00);


        // Test A: simultaneous instruction and data reads
        $display("TEST: simultaneous reads");

        fork
            data_transaction(
                32'h00000000, 0, 0, 0, 1, 32'h11223344
            );
            instruction_read(
                32'h00000800, 32'h55BB77DD
            );
        join

        // Test B: same-address instruction fetch and data write.
        // Instruction request must be deferred until the write
        // has been accepted and completed.
        $display("TEST: same-address read/write collision");

        @(negedge clk);
        while (!data_req_ready || !if_req_ready)
            @(negedge clk);

        data_addr  = 32'h00000800;
        data_wdata = 32'hCAFEBABE;
        data_wstrb = 4'b1111;
        data_we    = 1;
        data_req   = 1;

        if_addr = 32'h00000800;
        if_req  = 1;

        #1;
        if (if_req_ready !== 1'b0)
            $fatal(1, "COLLISION: instruction request was not blocked");

        if (data_req_ready !== 1'b1)
            $fatal(1, "COLLISION: data write was not accepted");

        @(posedge clk);
        #1;

        @(negedge clk);
        data_req = 0;
        data_we  = 0;

        // Wait until the instruction request can be accepted.
        while (!if_req_ready)
            @(negedge clk);

        @(posedge clk);
        #1;

        @(negedge clk);
        if_req = 0;

        @(posedge clk);
        #1;

        if (!if_resp_valid)
            $fatal(1, "COLLISION: instruction response missing");

        if (if_rdata !== 32'hCAFEBABE)
            $fatal(1,
                "COLLISION: expected CAFEBABE, got %h", if_rdata);

        tests = tests + 1;
        $display("PASS COLLISION: instruction sees updated data");


        // Test C: consecutive data reads across banks.
        $display("TEST: consecutive data reads");

        data_transaction(32'h00000000, 0, 0, 0, 1, 32'h11223344);
        data_transaction(32'h00000800, 0, 0, 0, 1, 32'hCAFEBABE);
        data_transaction(32'h00001000, 0, 0, 0, 1, 32'h99AABBCC);

        // Test D: consecutive instruction fetches.
        $display("TEST: consecutive instruction reads");

        instruction_read(32'h00000000, 32'h11223344);
        instruction_read(32'h00000800, 32'hCAFEBABE);
        instruction_read(32'h0000F800, 32'hDDEEFF00);

        // Test E: final valid word of the 64 KiB memory.
        $display("TEST: final valid word address");

        data_transaction(32'h0000FFFC, 1, 32'h12345678,
                         4'b1111, 0, 0);
        data_transaction(32'h0000FFFC, 0, 0, 0, 1,
                         32'h12345678);
        instruction_read(32'h0000FFFC, 32'h12345678);


        // Test F: reject addresses outside the SRAM range
        // and reject misaligned instruction fetches.
        $display("TEST: invalid address rejection");

        @(negedge clk);
        if_addr = 32'h00010000;
        if_req  = 1;
        #1;
        if (if_req_ready !== 1'b0)
            $fatal(1, "Invalid instruction address was accepted");
        if_req = 0;
        tests = tests + 1;
        $display("PASS: instruction address outside SRAM rejected");

        @(negedge clk);
        if_addr = 32'h00000001;
        if_req  = 1;
        #1;
        if (if_req_ready !== 1'b0)
            $fatal(1, "Misaligned instruction address was accepted");
        if_req = 0;
        tests = tests + 1;
        $display("PASS: misaligned instruction address rejected");

        @(negedge clk);
        data_addr = 32'h00010000;
        data_req  = 1;
        #1;
        if (data_req_ready !== 1'b0)
            $fatal(1, "Invalid data address was accepted");
        data_req = 0;
        tests = tests + 1;
        $display("PASS: data address outside SRAM rejected");


        // Test G: instruction read accepted before same-address write.
        $display("TEST: instruction read before data write");

        @(negedge clk);
        if_addr = 32'h00001000;
        if_req = 1;

        @(posedge clk);
        #1;
        @(negedge clk);
        if_req = 0;
        data_addr = 32'h00001000;
        data_wdata = 32'hDEADBEEF;
        data_wstrb = 4'b1111;
        data_we = 1;
        data_req = 1;

        @(posedge clk);
        #1;
        if (!if_resp_valid || if_rdata !== 32'h99AABBCC)
            $fatal(1, "Read-before-write ordering failed: %h", if_rdata);

        @(negedge clk);
        data_req = 0;
        data_we = 0;

        @(posedge clk);
        #1;
        if (!data_resp_valid)
            $fatal(1, "Read-before-write: write response missing");

        tests = tests + 1;
        $display("PASS: earlier instruction read returned old value");

        // Test H: data write accepted before same-address instruction read.
        $display("TEST: data write before instruction read");

        @(negedge clk);
        data_addr = 32'h00001000;
        data_wdata = 32'hFEED1234;
        data_wstrb = 4'b1111;
        data_we = 1;
        data_req = 1;

        @(posedge clk);
        #1;
        @(negedge clk);
        data_req = 0;
        data_we = 0;
        if_addr = 32'h00001000;
        if_req = 1;

        @(posedge clk);
        #1;
        @(negedge clk);
        if_req = 0;

        @(posedge clk);
        #1;
        if (!if_resp_valid || if_rdata !== 32'hFEED1234)
            $fatal(1, "Write-before-read ordering failed: %h", if_rdata);

        tests = tests + 1;
        $display("PASS: later instruction read returned new value");

        $display("--------------------------------------");
        $display("ALL TESTS PASSED: %0d", tests);
        $display("--------------------------------------");
        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "GLOBAL TEST TIMEOUT");
    end

endmodule
