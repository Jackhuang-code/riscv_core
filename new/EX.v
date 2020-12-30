`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 08:26:46
// Design Name: 
// Module Name: EX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: execute instruction
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module EX(
    input rst,
    input [`RegBus] op1,
    input [`RegBus] op2,
    input op1_rd_en,
    input op2_rd_en,
    input [`RegAddrBus] op1_rd_addr,
    input [`RegAddrBus] op2_rd_addr,
    input [`AluOpBus] aluop,
    input [`AluSelBus] alusel,
    input  wr_bck_en_i,
    input [`RegAddrBus] wr_reg_addr_i,
    input [`InstAddrBus] ex_pc,
    input [`LoadTypeNumlog2-1:0]   id_ex_loadtype,
    input [`StoreTypeNumlog2-1:0] id_ex_storetype,
    input [`RegBus] id_ex_store_data,
    input id_ex_isload, 
    input [`RegBus] id_ex_jump_imm,

    //operator from  mem
    input [`RegBus]    mem_ex_op,
    input [`RegAddrBus]    mem_ex_op_addr,
    input mem_ex_op_en,
    //csr data redirect from mem
    input [`RegBus]    mem_ex_csr_data,
    input [`RegAddrBus]    mem_ex_csr_addr,
    input mem_ex_csr_en,

    output reg [`RegBus] ex_result,
    output reg wr_bck_en_o,
    output reg [`RegAddrBus] wr_reg_addr_o,
    output reg [`InstAddrBus]   mem_pc,
    output reg [`LoadTypeNumlog2-1:0]   ex_mem_loadtype,
    output reg [`StoreTypeNumlog2-1:0] ex_mem_storetype,
    output reg [`RegBus] ex_reg_store_data,
    output reg ex_mem_isload,

    output reg ex_id_isload,

    //jump and branch
    output reg jump_branch_flag,
    output reg [`InstAddrBus] jump_branch_addr,

    //read csr
    output reg [`CSRAddrBus] ex_csr_rd_addr,
    input [`RegBus] csr_ex_rd_data,
    //write csr
    output reg [`RegBus] ex_reg_csr_wr_data,
    output reg [`CSRAddrBus] ex_reg_csr_wr_addr,
    output reg ex_reg_csr_wr_en,
    //propagate csr write signals
    input [`CSRAddrBus] id_ex_csr_wr_addr,
    input id_ex_csr_wr_en,
    input [`RegBus] id_ex_csr_rd_addr
    );


    reg [`RegBus]   logic_result,
                    shift_result,
                    math_result,
                    jump_branch_result,
                    load_store_result,
                    csr_result;
    reg [`RegBus]   alu_result;

    //redirect; operator from memery access
    reg [`RegBus] aluop1, aluop2;
    always @(*) begin
        if (rst == `RstEnable) begin
            aluop1 = `ZeroWord;
            aluop2 = `ZeroWord;
            ex_reg_store_data = `ZeroWord;
            ex_id_isload = `NotLoaded;
        end else begin
            ex_id_isload = id_ex_isload;
            // jump
            if (aluop == `EXE_OP_JUMP_BRANCH_JAL ||
                aluop == `EXE_OP_JUMP_BRANCH_JALR) begin
                aluop1 = ex_pc;
                aluop2 = 4'h4;
            //csr
            end else if (aluop == `EXE_OP_CSR_CSRRW ||
                        aluop == `EXE_OP_CSR_CSRRC || 
                        aluop == `EXE_OP_CSR_CSRRS) begin
                if (op1_rd_en == `ReadEnable && op1_rd_addr == mem_ex_op_addr
                    && mem_ex_op_en == `RedirectEnable) begin
                    aluop1 = mem_ex_op;
                end else begin
                    aluop1 = op1;
                end
                if (id_ex_csr_rd_addr == mem_ex_csr_addr
                    && mem_ex_csr_en == `RedirectEnable) begin
                    aluop2 = mem_ex_csr_data;
                end else begin
                    aluop2 = csr_ex_rd_data;
                end
            end else if (aluop == `EXE_OP_CSR_CSRRWI ||
                        aluop == `EXE_OP_CSR_CSRRCI || 
                        aluop == `EXE_OP_CSR_CSRRSI) begin
                if (id_ex_csr_rd_addr == mem_ex_csr_addr
                    && mem_ex_csr_en == `RedirectEnable) begin
                    aluop1 = mem_ex_csr_data;
                end else begin
                    aluop1 = csr_ex_rd_data;
                end
                aluop2 = op2;
            end else begin

            //redirect
                if (op1_rd_en == `ReadEnable && op1_rd_addr == mem_ex_op_addr
                    && mem_ex_op_en == `RedirectEnable) begin
                    aluop1 = mem_ex_op;
                end else begin
                    aluop1 = op1;
                end
                if (op2_rd_en == `ReadEnable && op2_rd_addr == mem_ex_op_addr
                    && mem_ex_op_en == `RedirectEnable) begin
                    aluop2 = mem_ex_op;
                    ex_reg_store_data = mem_ex_op;
                end else begin
                    aluop2 = op2;
                    ex_reg_store_data = id_ex_store_data;
                end
            end 
        end
    end

    //choose operation by decode result
    always @(*) begin
        if (rst == `RstEnable) begin
            alu_result = `ZeroWord;
        end
        else begin
            case (aluop)
                //nop
                `EXE_OP_NOP_NOP: logic_result = `ZeroWord; 	
                //logic
                `EXE_OP_LOGIC_ORI: logic_result = aluop1 | aluop2;
                `EXE_OP_LOGIC_AND: logic_result = aluop1 & aluop2;
                `EXE_OP_LOGIC_OR: logic_result = aluop1 | aluop2;	
                `EXE_OP_LOGIC_XOR: logic_result = aluop1 ^ aluop2; 
                `EXE_OP_LOGIC_NOR: logic_result = ~(aluop1 ^ aluop2); 
                `EXE_OP_LOGIC_ANDI: logic_result = aluop1 & aluop2;
                `EXE_OP_LOGIC_ORI: logic_result = aluop1 | aluop2;
                `EXE_OP_LOGIC_XORI: logic_result = aluop1 ^ aluop2;
                `EXE_OP_LOGIC_NORI: logic_result = ~(aluop1 ^ aluop2);
                //shift
                `EXE_OP_SHIFT_SLL: shift_result = aluop1 << aluop2[4:0];
                `EXE_OP_SHIFT_SRL: shift_result = aluop1 >> aluop2[4:0];
                `EXE_OP_SHIFT_SRA: shift_result = $signed(aluop1) >>> aluop2[4:0];
                `EXE_OP_SHIFT_SLLI: shift_result = aluop1 << aluop2[4:0];
                `EXE_OP_SHIFT_SRLI: shift_result = aluop1 >> aluop2[4:0];
                `EXE_OP_SHIFT_SRAI: shift_result = $signed(aluop1) >>> aluop2[4:0];
                `EXE_OP_SHIFT_LUI: shift_result = aluop2;

                //math
                `EXE_OP_MATH_ADD: math_result = aluop1 + aluop2;
                `EXE_OP_MATH_ADDI: math_result = aluop1 + aluop2;

                `EXE_OP_MATH_SUB: math_result = aluop1 - aluop2;

                //signed compare
                `EXE_OP_MATH_SLT: begin
                    if ($signed(aluop1) < $signed(aluop2)) begin
                        math_result = 1;
                    end else begin
                        math_result = 0;
                    end
                end
                `EXE_OP_MATH_SLTI: begin
                    if ($signed(aluop1) < $signed(aluop2)) begin
                        math_result = 1;
                    end else begin
                        math_result = 0;
                    end
                end

                //unsigned compare
                `EXE_OP_MATH_SLTU: begin
                    if (aluop1 < aluop2) begin
                        math_result = 32'b1;
                    end else begin
                        math_result = 32'b0;
                    end
                end
                `EXE_OP_MATH_SLTUI: begin
                    if (aluop1 < aluop2) begin
                        math_result = 32'b1;
                    end else begin
                        math_result = 32'b0;
                    end
                end
                `EXE_OP_MATH_AUIPC: math_result = ex_pc + aluop2;

                //jump and branch???????
                `EXE_OP_JUMP_BRANCH_JALR: jump_branch_result = aluop1 + aluop2;
                `EXE_OP_JUMP_BRANCH_JAL: jump_branch_result = aluop1 + aluop2;
                `EXE_OP_JUMP_BRANCH_BEQ: jump_branch_result = aluop1 & aluop2;
                `EXE_OP_JUMP_BRANCH_BNE: jump_branch_result = aluop1 & aluop2;
                `EXE_OP_JUMP_BRANCH_BLTU: jump_branch_result = aluop1 & aluop2;
                `EXE_OP_JUMP_BRANCH_BGE: jump_branch_result = aluop1 & aluop2;
                `EXE_OP_JUMP_BRANCH_BLT: jump_branch_result = aluop1 & aluop2;
                `EXE_OP_JUMP_BRANCH_BGEU: jump_branch_result = aluop1 & aluop2;

                //load and store
                `EXE_OP_LOAD_STORE_LB : load_store_result = aluop1 + aluop2;
                `EXE_OP_LOAD_STORE_LH : load_store_result = aluop1 + aluop2;
                `EXE_OP_LOAD_STORE_LW : load_store_result = aluop1 + aluop2;
                `EXE_OP_LOAD_STORE_LBU: load_store_result = aluop1 + aluop2;
                `EXE_OP_LOAD_STORE_LHU: load_store_result = aluop1 + aluop2;
                `EXE_OP_LOAD_STORE_SB : load_store_result = aluop1 + aluop2;
                `EXE_OP_LOAD_STORE_SH : load_store_result = aluop1 + aluop2;
                `EXE_OP_LOAD_STORE_SW: load_store_result = aluop1 + aluop2;
                
                //csr
                `EXE_OP_CSR_CSRRW:      csr_result = aluop1; 
                `EXE_OP_CSR_CSRRWI:     csr_result = aluop2;
                `EXE_OP_CSR_CSRRC:      csr_result = aluop1 & aluop2; 
                `EXE_OP_CSR_CSRRCI:     csr_result = aluop1 & aluop2;
                `EXE_OP_CSR_CSRRS:      csr_result = aluop1 | aluop2; 
                `EXE_OP_CSR_CSRRSI:     csr_result = aluop1 | aluop2;

                `EXE_OP_CSR_ECALL:      csr_result = aluop1 | aluop2; 
                `EXE_OP_CSR_EBREAK:     csr_result = aluop1 | aluop2;
                default: alu_result = `ZeroWord;
            endcase
        end
    end


    //choose result from five category
    always @(*) begin
        if (rst == `RstEnable) begin
            alu_result = `ZeroWord;
        end else begin
            case (alusel)
            `EXE_RES_NOP: alu_result = `ZeroWord;
            `EXE_RES_LOGIC: alu_result = logic_result;
            `EXE_RES_LOAD_STORE: alu_result = load_store_result;
            `EXE_RES_MATH: alu_result = math_result;
            `EXE_RES_SHIFT: alu_result = shift_result;
            `EXE_RES_JUMP_BRANCH: alu_result = jump_branch_result;
            `EXE_RES_CSR: alu_result = csr_result;
            default: alu_result = `ZeroWord;
            endcase
        end
    end

    //propagate write back signals
    always @(*) begin
        if (rst == `RstEnable) begin
            wr_bck_en_o = `WriteDisable;
            wr_reg_addr_o = `NOPRegAddr;
            mem_pc = `ZeroWord;
            ex_mem_storetype = `nostore;
            ex_mem_loadtype =  `noload;
            ex_mem_isload = `NotLoaded;
            ex_result = `ZeroWord;
            ex_csr_rd_addr = `CSR0;
            ex_reg_csr_wr_data = `ZeroWord;
            ex_reg_csr_wr_addr = `CSR0;
            ex_reg_csr_wr_en = `WriteDisable;
        end else begin
            wr_bck_en_o = wr_bck_en_i;
            wr_reg_addr_o = wr_reg_addr_i;
            mem_pc = ex_pc;
            ex_mem_storetype = id_ex_storetype;
            ex_mem_loadtype =  id_ex_loadtype;
            ex_mem_isload = id_ex_isload;
            if (alusel == `EXE_RES_CSR) begin
                if (id_ex_csr_rd_addr == mem_ex_csr_addr
                    && mem_ex_csr_en == `RedirectEnable) begin
                    ex_result = mem_ex_csr_data;
                end else begin
                    ex_result = csr_ex_rd_data;
                end
            end else begin
                ex_result = alu_result;
            end
            ex_csr_rd_addr = id_ex_csr_rd_addr;
            ex_reg_csr_wr_data = alu_result;
            ex_reg_csr_wr_addr = id_ex_csr_wr_addr;
            ex_reg_csr_wr_en = id_ex_csr_wr_en;
        end
    end
    
    reg [`RegBus] cmpa, cmpb;
    //branch and jump operation
    always @(*) begin
        if (rst == `RstEnable) begin
            jump_branch_addr = `ZeroWord;
            jump_branch_flag = `NotJump_Branch;
        end else begin
            jump_branch_addr = `ZeroWord;
            jump_branch_flag = `NotJump_Branch;
            if (op1_rd_en == `ReadEnable && op1_rd_addr == mem_ex_op_addr
                && mem_ex_op_en == `RedirectEnable) begin
                cmpa = mem_ex_op;
            end else begin
                cmpa = op1;
            end
            if (op2_rd_en == `ReadEnable && op2_rd_addr == mem_ex_op_addr
                && mem_ex_op_en == `RedirectEnable) begin
                cmpb = mem_ex_op;
            end else begin
                cmpb = op2;
            end

            case (aluop)
            `EXE_OP_JUMP_BRANCH_JAL: begin
                jump_branch_flag = `Jump_Branch;
                jump_branch_addr = ex_pc + id_ex_jump_imm;
            end
            `EXE_OP_JUMP_BRANCH_JALR:begin
                jump_branch_flag = `Jump_Branch;
                jump_branch_addr = cmpa + {id_ex_jump_imm[30:0], 1'b0};
            end
            `EXE_OP_JUMP_BRANCH_BEQ:begin
                jump_branch_addr = ex_pc + id_ex_jump_imm;
                if (cmpa == cmpb) begin
                    jump_branch_flag = `Jump_Branch;
                end else begin
                    jump_branch_flag = `NotJump_Branch;
                end
            end
            `EXE_OP_JUMP_BRANCH_BNE:begin
                jump_branch_addr = ex_pc + id_ex_jump_imm;
                if (cmpa != cmpb) begin
                    jump_branch_flag = `Jump_Branch;
                end else begin
                    jump_branch_flag = `NotJump_Branch;
                end
            end
            `EXE_OP_JUMP_BRANCH_BLTU:begin
                jump_branch_addr = ex_pc + id_ex_jump_imm;
                if (cmpa < cmpb) begin
                    jump_branch_flag = `Jump_Branch;
                end else begin
                    jump_branch_flag = `NotJump_Branch;
                end
            end
            `EXE_OP_JUMP_BRANCH_BGE:begin
                jump_branch_addr = ex_pc + id_ex_jump_imm;
                if ($signed(cmpa) >= $signed(cmpb)) begin
                    jump_branch_flag = `Jump_Branch;
                end else begin
                    jump_branch_flag = `NotJump_Branch;
                end
            end
            `EXE_OP_JUMP_BRANCH_BLT:begin
                jump_branch_addr = ex_pc + id_ex_jump_imm;
                if ($signed(cmpa) < $signed(cmpb)) begin
                    jump_branch_flag = `Jump_Branch;
                end else begin
                    jump_branch_flag = `NotJump_Branch;
                end
            end
            `EXE_OP_JUMP_BRANCH_BGEU:begin
                jump_branch_addr = ex_pc + id_ex_jump_imm;
                if (cmpa >= cmpb) begin
                    jump_branch_flag = `Jump_Branch;
                end else begin
                    jump_branch_flag = `NotJump_Branch;
                end
            end
            default: begin
                jump_branch_addr = `ZeroWord;
                jump_branch_flag = `NotJump_Branch;
            end
            endcase
        end
    end

endmodule
