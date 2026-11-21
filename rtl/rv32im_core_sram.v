// 5-stage in-order RV32IM core: IF | ID | EX | MEM | WB
//  - full forwarding (EX/MEM -> EX, MEM/WB -> EX), WB->ID bypass in the register file
//  - 1-cycle load-use stall
//  - branches/jumps resolved in EX (predict not-taken, 2-cycle taken penalty)
//  - M extension: iterative muldiv_unit (34 cycles/op); the pipeline stalls in EX until it finishes
//  - memory pipeline advancement is qualified by step_en after synchronous SRAM responses;
//    no exceptions/CSRs; ECALL/EBREAK/FENCE are treated as NOPs.
//    ECALL/EBREAK/FENCE are treated as NOPs.
`timescale 1ns/1ps
module rv32im_core_sram #(
    parameter [31:0] RESET_PC = 32'h0000_0000
) (
    input         clk,
    input         rst_n,
    input         step_en,       // advance all pipeline stages for one completed memory cycle
    // instruction port (async read)
    output [31:0] imem_addr,
    input  [31:0] imem_rdata,
    // data port (async read, byte-strobed write; word-aligned address on the bus)
    output [31:0] dmem_addr,
    output [31:0] dmem_wdata,
    output [3:0]  dmem_wstrb,
    output        dmem_re,
    input  [31:0] dmem_rdata
);
    localparam [31:0] NOP = 32'h0000_0013;

    // ------------------------------------------------------------------ IF
    reg  [31:0] pc;
    wire        stall;
    wire        md_done;       // multiply/divide result ready (from muldiv_unit)
    wire        redirect;
    wire [31:0] redirect_pc;

    assign imem_addr = pc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)        pc <= RESET_PC;
        else if (step_en) begin
            if (redirect) pc <= redirect_pc;
            else if (!stall) pc <= pc + 32'd4;
        end
    end

    reg [31:0] id_pc, id_instr;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_pc <= 32'd0; id_instr <= NOP;
        end else if (step_en) begin
            if (redirect) begin
                id_pc <= 32'd0; id_instr <= NOP;
            end else if (!stall) begin
                id_pc <= pc;    id_instr <= imem_rdata;
            end
        end
    end

    // ------------------------------------------------------------------ ID
    wire [6:0] opcode = id_instr[6:0];
    wire [4:0] id_rd  = id_instr[11:7];
    wire [2:0] funct3 = id_instr[14:12];
    wire [4:0] id_rs1 = id_instr[19:15];
    wire [4:0] id_rs2 = id_instr[24:20];
    wire [6:0] funct7 = id_instr[31:25];

    wire is_lui    = (opcode == 7'b0110111);
    wire is_auipc  = (opcode == 7'b0010111);
    wire is_jal    = (opcode == 7'b1101111);
    wire is_jalr   = (opcode == 7'b1100111);
    wire is_branch = (opcode == 7'b1100011);
    wire is_load   = (opcode == 7'b0000011);
    wire is_store  = (opcode == 7'b0100011);
    wire is_opimm  = (opcode == 7'b0010011);
    wire is_op     = (opcode == 7'b0110011);
    wire is_muldiv = is_op && (funct7 == 7'b0000001);

    reg [31:0] imm;
    always @* begin
        case (opcode)
            7'b0010011, 7'b0000011, 7'b1100111: imm = {{20{id_instr[31]}}, id_instr[31:20]};
            7'b0100011:                         imm = {{20{id_instr[31]}}, id_instr[31:25], id_instr[11:7]};
            7'b1100011:                         imm = {{19{id_instr[31]}}, id_instr[31], id_instr[7],
                                                       id_instr[30:25], id_instr[11:8], 1'b0};
            7'b0110111, 7'b0010111:             imm = {id_instr[31:12], 12'd0};
            7'b1101111:                         imm = {{11{id_instr[31]}}, id_instr[31], id_instr[19:12],
                                                       id_instr[20], id_instr[30:21], 1'b0};
            default:                            imm = 32'd0;
        endcase
    end

    wire id_reg_we = (is_lui | is_auipc | is_jal | is_jalr | is_load | is_opimm | is_op) && (id_rd != 5'd0);
    wire [1:0] id_a_sel = is_auipc ? 2'd1 : (is_lui ? 2'd2 : 2'd0);    // 0: rs1, 1: pc, 2: zero
    wire id_b_imm = ~(is_op | is_branch);
    // ALU function: ADD for everything except OP/OP-IMM; sub/sra select bit only where architecturally defined
    wire [2:0] id_alu_f3  = (is_op | is_opimm) ? funct3 : 3'b000;
    wire       id_alu_alt = (is_op | (is_opimm && funct3 == 3'b101)) ? id_instr[30] : 1'b0;

    wire [31:0] rf_rdata1, rf_rdata2;
    wire        wb_we;
    wire [4:0]  wb_rd;
    wire [31:0] wb_result;

    regfile u_rf (
        .clk(clk), .we(wb_we && step_en), .waddr(wb_rd), .wdata(wb_result),
        .raddr1(id_rs1), .raddr2(id_rs2), .rdata1(rf_rdata1), .rdata2(rf_rdata2)
    );

    // ------------------------------------------------------------------ ID/EX
    reg [31:0] ex_pc, ex_rs1v, ex_rs2v, ex_imm;
    reg [4:0]  ex_rd, ex_rs1, ex_rs2;
    reg [2:0]  ex_f3, ex_alu_f3;
    reg        ex_alt, ex_we, ex_load, ex_store, ex_branch, ex_jal, ex_jalr, ex_muldiv, ex_b_imm;
    reg [1:0]  ex_a_sel;

    // load-use hazard: instruction in EX is a load whose rd is read by the instruction in ID
    wire lu_stall = ex_load && (ex_rd != 5'd0) && (ex_rd == id_rs1 || ex_rd == id_rs2);
    // EX holds a MUL/DIV/REM until the iterative unit finishes: freeze fetch/decode/EX, feed bubbles to MEM
    wire md_stall = ex_muldiv && !md_done;
    assign stall = lu_stall | md_stall;

    // (synchronous reset/flush: reset must be held for >= 1 clock edge)
    always @(posedge clk) begin
        if (!rst_n) begin
            // bubble
            ex_pc <= 32'd0; ex_rs1v <= 32'd0; ex_rs2v <= 32'd0; ex_imm <= 32'd0;
            ex_rd <= 5'd0; ex_rs1 <= 5'd0; ex_rs2 <= 5'd0;
            ex_f3 <= 3'd0; ex_alu_f3 <= 3'd0;
            ex_alt <= 1'b0; ex_we <= 1'b0; ex_load <= 1'b0; ex_store <= 1'b0; ex_branch <= 1'b0;
            ex_jal <= 1'b0; ex_jalr <= 1'b0; ex_muldiv <= 1'b0; ex_b_imm <= 1'b0; ex_a_sel <= 2'd0;
        end else if (step_en) begin
            if (redirect || lu_stall) begin
                ex_pc <= 32'd0; ex_rs1v <= 32'd0; ex_rs2v <= 32'd0; ex_imm <= 32'd0;
                ex_rd <= 5'd0; ex_rs1 <= 5'd0; ex_rs2 <= 5'd0;
                ex_f3 <= 3'd0; ex_alu_f3 <= 3'd0;
                ex_alt <= 1'b0; ex_we <= 1'b0; ex_load <= 1'b0; ex_store <= 1'b0; ex_branch <= 1'b0;
                ex_jal <= 1'b0; ex_jalr <= 1'b0; ex_muldiv <= 1'b0; ex_b_imm <= 1'b0; ex_a_sel <= 2'd0;
            end else if (!md_stall) begin
                ex_pc <= id_pc;  ex_rs1v <= rf_rdata1; ex_rs2v <= rf_rdata2; ex_imm <= imm;
                ex_rd <= id_rd;  ex_rs1 <= id_rs1;     ex_rs2 <= id_rs2;
                ex_f3 <= funct3; ex_alu_f3 <= id_alu_f3;
                ex_alt <= id_alu_alt; ex_we <= id_reg_we; ex_load <= is_load; ex_store <= is_store;
                ex_branch <= is_branch; ex_jal <= is_jal; ex_jalr <= is_jalr; ex_muldiv <= is_muldiv;
                ex_b_imm <= id_b_imm; ex_a_sel <= id_a_sel;
            end
        end
    end

    // ------------------------------------------------------------------ EX
    // MEM-stage state used for forwarding (declared here, assigned below)
    reg [31:0] mem_alu, mem_rs2;
    reg [4:0]  mem_rd;
    reg [2:0]  mem_f3;
    reg        mem_we, mem_load, mem_store;

    wire [31:0] fa = (mem_we && mem_rd != 5'd0 && mem_rd == ex_rs1) ? mem_alu :
                     (wb_we  && wb_rd  != 5'd0 && wb_rd  == ex_rs1) ? wb_result : ex_rs1v;
    wire [31:0] fb = (mem_we && mem_rd != 5'd0 && mem_rd == ex_rs2) ? mem_alu :
                     (wb_we  && wb_rd  != 5'd0 && wb_rd  == ex_rs2) ? wb_result : ex_rs2v;

    wire [31:0] alu_a = (ex_a_sel == 2'd1) ? ex_pc : (ex_a_sel == 2'd2) ? 32'd0 : fa;
    wire [31:0] alu_b = ex_b_imm ? ex_imm : fb;
    wire [4:0]  shamt = alu_b[4:0];

    // arithmetic shift computed in its own signed context (a ternary mixing signed and
    // unsigned operands would make the whole expression unsigned and turn >>> into >>)
    wire signed [31:0] alu_a_s = alu_a;
    wire signed [31:0] sra_res = alu_a_s >>> shamt;

    reg [31:0] alu_out;
    always @* begin
        case (ex_alu_f3)
            3'b000:  alu_out = ex_alt ? (alu_a - alu_b) : (alu_a + alu_b);
            3'b001:  alu_out = alu_a << shamt;
            3'b010:  alu_out = ($signed(alu_a) < $signed(alu_b)) ? 32'd1 : 32'd0;
            3'b011:  alu_out = (alu_a < alu_b) ? 32'd1 : 32'd0;
            3'b100:  alu_out = alu_a ^ alu_b;
            3'b101:  alu_out = ex_alt ? sra_res : (alu_a >> shamt);
            3'b110:  alu_out = alu_a | alu_b;
            default: alu_out = alu_a & alu_b;
        endcase
    end

    // ---- M extension: iterative multiply/divide unit; stalls the pipeline until done ----
    wire [31:0] md_result;
    muldiv_unit u_muldiv (
        .clk(clk), .rst_n(rst_n),
        .start(ex_muldiv), .funct3(ex_f3), .a(fa), .b(fb),
        .ack(md_done && step_en), .done(md_done), .result(md_result)
    );

    wire [31:0] ex_result = ex_muldiv ? md_result :
                            (ex_jal | ex_jalr) ? (ex_pc + 32'd4) : alu_out;

    // ---- branches / jumps ----
    reg br_taken;
    always @* begin
        case (ex_f3)
            3'b000:  br_taken = (fa == fb);
            3'b001:  br_taken = (fa != fb);
            3'b100:  br_taken = ($signed(fa) <  $signed(fb));
            3'b101:  br_taken = ($signed(fa) >= $signed(fb));
            3'b110:  br_taken = (fa <  fb);
            3'b111:  br_taken = (fa >= fb);
            default: br_taken = 1'b0;
        endcase
    end
    assign redirect    = ex_jal | ex_jalr | (ex_branch & br_taken);
    assign redirect_pc = ex_jalr ? {alu_out[31:1], 1'b0} : (ex_pc + ex_imm);

    // ------------------------------------------------------------------ EX/MEM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_alu <= 32'd0; mem_rs2 <= 32'd0; mem_rd <= 5'd0; mem_f3 <= 3'd0;
            mem_we <= 1'b0; mem_load <= 1'b0; mem_store <= 1'b0;
        end else if (step_en) begin
            mem_alu <= ex_result; mem_rs2 <= fb; mem_rd <= ex_rd; mem_f3 <= ex_f3;
            mem_we <= ex_we && !md_stall; mem_load <= ex_load; mem_store <= ex_store;
        end
    end

    // ------------------------------------------------------------------ MEM
    assign dmem_addr  = mem_alu;
    assign dmem_re    = mem_load;
    assign dmem_wdata = (mem_f3[1:0] == 2'b00) ? {4{mem_rs2[7:0]}} :
                        (mem_f3[1:0] == 2'b01) ? {2{mem_rs2[15:0]}} : mem_rs2;
    reg [3:0] wstrb_r;
    always @* begin
        case (mem_f3[1:0])
            2'b00:   wstrb_r = 4'b0001 << mem_alu[1:0];
            2'b01:   wstrb_r = mem_alu[1] ? 4'b1100 : 4'b0011;
            default: wstrb_r = 4'b1111;
        endcase
    end
    assign dmem_wstrb = mem_store ? wstrb_r : 4'b0000;

    wire [31:0] rd_shift = dmem_rdata >> {mem_alu[1:0], 3'b000};
    reg  [31:0] load_data;
    always @* begin
        case (mem_f3)
            3'b000:  load_data = {{24{rd_shift[7]}},  rd_shift[7:0]};    // LB
            3'b001:  load_data = {{16{rd_shift[15]}}, rd_shift[15:0]};   // LH
            3'b100:  load_data = {24'd0, rd_shift[7:0]};                 // LBU
            3'b101:  load_data = {16'd0, rd_shift[15:0]};                // LHU
            default: load_data = dmem_rdata;                             // LW
        endcase
    end

    // ------------------------------------------------------------------ MEM/WB
    reg [31:0] wb_result_r;
    reg [4:0]  wb_rd_r;
    reg        wb_we_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_result_r <= 32'd0; wb_rd_r <= 5'd0; wb_we_r <= 1'b0;
        end else if (step_en) begin
            wb_result_r <= mem_load ? load_data : mem_alu;
            wb_rd_r     <= mem_rd;
            wb_we_r     <= mem_we;
        end
    end
    assign wb_result = wb_result_r;
    assign wb_rd     = wb_rd_r;
    assign wb_we     = wb_we_r;
endmodule