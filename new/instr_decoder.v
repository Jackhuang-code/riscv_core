`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/26 18:04:18
// Design Name: 
// Module Name: instr_decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: decode instruction
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module instr_decoder(
    input rst,
    input [`InstBus]    instr,
    output reg op1_rd_en,
    output reg op2_rd_en,
    output reg wr_en,
    output reg [`Imm_type_num_log2-1:0] imm_choose,         //choose immediate type
    output reg [`AluOpBus] aluop,                          //choose instruction type
    output reg [`AluSelBus] alusel,                       //choose alu operation
    output reg alusrc,                          //choose alu op2 source
    output reg [`LoadTypeNumlog2-1:0]   loadtype,
    output reg [`StoreTypeNumlog2-1:0]  storetype,
    output reg isload
    );      

    //get operator read enable
    always @(*) begin
        if (rst == `RstEnable) begin
            op1_rd_en = `ReadDisable;
            op2_rd_en = `ReadDisable;
            wr_en = `WriteDisable;
            alusel = `EXE_RES_NOP;
            aluop = `EXE_OP_NOP_NOP;      //tmp
            alusrc = `AluSrc_imm;
            imm_choose = `Imm_no;
            loadtype = `noload;
            storetype = `nostore;
            isload = `NotLoaded;
        end else begin
            loadtype = `noload;
            storetype = `nostore;
            isload = `NotLoaded;
            case (instr[6:0]) 
            `R_type:
            begin
                op1_rd_en = `ReadEnable;
                op2_rd_en = `ReadEnable;
                wr_en = `WriteEnable;      //wait 3 cycles to write back
                alusrc = `AluSrc_rs2;
                imm_choose = `Imm_no;
                //choose alu type
                case (instr[14:12])
                `R_add_or_sub_type:
                begin
                    alusel = `EXE_RES_MATH;
                    if (instr[30] == `R_add)begin
                        aluop = `EXE_OP_MATH_ADD;
                    end
                    else begin
                        aluop = `EXE_OP_MATH_SUB;
                    end
                end
                `R_sll:
                begin
                    alusel = `EXE_RES_SHIFT;
                    aluop = `EXE_OP_SHIFT_SLL;
                end            
                `R_slt:     
                begin
                    alusel = `EXE_RES_MATH;
                    aluop = `EXE_OP_MATH_SLT;
                end             
                `R_sltu: 
                begin
                    alusel = `EXE_RES_MATH;
                    aluop = `EXE_OP_MATH_SLTU;
                end                
                `R_xor:  
                begin
                    alusel = `EXE_RES_LOGIC;
                    aluop = `EXE_OP_LOGIC_XOR;
                end                
                `R_srl_or_sra_type:
                begin
                    alusel = `EXE_RES_SHIFT;
                    if (instr[30] == `R_srl)begin
                        aluop = `EXE_OP_SHIFT_SRL;
                    end
                    else begin
                        aluop = `EXE_OP_SHIFT_SRA;
                    end
                end
                `R_or:            
                begin
                    alusel = `EXE_RES_LOGIC;
                    aluop = `EXE_OP_LOGIC_OR;
                end       
                `R_and:         
                begin
                    alusel = `EXE_RES_LOGIC;
                    aluop = `EXE_OP_LOGIC_AND;
                end         
                //miss
                default:
                begin
                    alusel = `EXE_RES_NOP;
                    aluop = `EXE_OP_NOP_NOP;
                end
                endcase
            end
            `B_type:
            begin
                op1_rd_en = `ReadEnable;
                op2_rd_en = `ReadEnable;
                wr_en = `WriteDisable;
                alusrc = `AluSrc_rs2;
                imm_choose = `Imm_B_type;
                case (instr[14:12])
                    `B_beq:begin
                        alusel = `EXE_RES_JUMP_BRANCH;
                        aluop = `EXE_OP_JUMP_BRANCH_BEQ;
                    end
                    `B_bne:begin
                        alusel = `EXE_RES_JUMP_BRANCH;
                        aluop = `EXE_OP_JUMP_BRANCH_BNE;
                    end
                    `B_bltu:begin
                        alusel = `EXE_RES_JUMP_BRANCH;
                        aluop = `EXE_OP_JUMP_BRANCH_BLTU;
                    end
                    `B_bge:begin
                        alusel = `EXE_RES_JUMP_BRANCH;
                        aluop = `EXE_OP_JUMP_BRANCH_BGE;
                    end
                    `B_blt:begin
                        alusel = `EXE_RES_JUMP_BRANCH;
                        aluop = `EXE_OP_JUMP_BRANCH_BLT;
                    end
                    `B_bgeu:begin
                        alusel = `EXE_RES_JUMP_BRANCH;
                        aluop = `EXE_OP_JUMP_BRANCH_BGEU;
                    end
                    default: begin
                        alusel = `EXE_RES_NOP;
                        aluop = `EXE_OP_NOP_NOP;
                    end
                endcase
            end
            `S_type:
            begin
                op1_rd_en = `ReadEnable;
                op2_rd_en = `ReadEnable;
                wr_en = `WriteDisable;
                alusel = `EXE_RES_LOAD_STORE;
                alusrc = `AluSrc_imm;
                imm_choose = `Imm_S_type;
                case (instr[14:12])
                    `S_sb:  begin 
                        aluop = `EXE_OP_LOAD_STORE_SB;
                        storetype = `storebyte;
                    end 
                    `S_sh:  begin 
                        aluop = `EXE_OP_LOAD_STORE_SH;
                        storetype = `storehalfword;
                    end 
                    `S_sw:begin 
                        aluop = `EXE_OP_LOAD_STORE_SW;
                        storetype = `storeword;
                    end 
                    default:begin 
                        aluop = `EXE_OP_LOAD_STORE_SB;
                        storetype = `storeword;
                    end 
                endcase
            end

            `U_lui:
            begin
                op1_rd_en = `ReadDisable;
                op2_rd_en = `ReadDisable;
                wr_en = `WriteEnable;
                alusel = `EXE_RES_SHIFT;
                aluop = `EXE_OP_SHIFT_LUI;      //tmp
                alusrc = `AluSrc_imm;
                imm_choose = `Imm_U_type;
            end

            `U_auipc:
            begin
                op1_rd_en = `ReadDisable;
                op2_rd_en = `ReadDisable;
                wr_en = `WriteEnable;
                alusel = `EXE_RES_MATH;
                aluop = `EXE_OP_MATH_AUIPC;      //tmp
                alusrc = `AluSrc_imm;
                imm_choose = `Imm_U_type;
            end

            `J_jal:
            begin
                op1_rd_en = `ReadDisable;
                op2_rd_en = `ReadDisable;
                wr_en = `WriteEnable;
                alusel = `EXE_RES_JUMP_BRANCH;
                aluop = `EXE_OP_JUMP_BRANCH_JAL;
                alusrc = `AluSrc_imm;
                imm_choose = `Imm_J_type;
            end

            `I_jalr:
            begin
                op1_rd_en = `ReadEnable;
                op2_rd_en = `ReadDisable;
                wr_en = `WriteEnable;      //wait 3 cycles to write back
                alusel = `EXE_RES_JUMP_BRANCH;
                aluop = `EXE_OP_JUMP_BRANCH_JALR;
                alusrc = `AluSrc_imm;
                imm_choose = `Imm_I_type;
            end

            `I_alu_type:
            begin
                op1_rd_en = `ReadEnable;
                op2_rd_en = `ReadDisable;
                wr_en = `WriteEnable;      //wait 3 cycles to write back
                alusrc = `AluSrc_imm;
                imm_choose = `Imm_I_type;
                case (instr[14:12])
                `I_alu_addi:
                begin
                    alusel = `EXE_RES_MATH;
                    aluop = `EXE_OP_MATH_ADD; 
                end     
                `I_alu_slti:begin
                    alusel = `EXE_RES_MATH;
                    aluop = `EXE_OP_MATH_SLT;
                end      
                `I_alu_sltiu:begin
                    alusel = `EXE_RES_MATH;
                    aluop = `EXE_OP_MATH_SLTU; 
                end     
                `I_alu_xori:begin
                    alusel = `EXE_RES_LOGIC;
                    aluop = `EXE_OP_LOGIC_XOR; 
                end    
                `I_alu_ori :begin
                    alusel = `EXE_RES_LOGIC;
                    aluop = `EXE_OP_LOGIC_ORI; 
                end     
                `I_alu_andi:begin
                    alusel = `EXE_RES_LOGIC;
                    aluop = `EXE_OP_LOGIC_AND;
                end     
                `I_alu_slli:begin
                    if (instr[31:25] == 7'b0) begin
                        alusel = `EXE_RES_NOP;
                        aluop = `EXE_OP_NOP_NOP;
                        imm_choose = `Imm_no;
                    end else begin
                        alusel = `EXE_RES_LOGIC;
                        aluop = `EXE_OP_SHIFT_SLL;
                        imm_choose = `Imm_I_shift;
                    end
                    
                end      
                `I_alu_srli_or_srai: begin
                    if (instr[31:25] == 7'b0) begin
                        alusel = `EXE_RES_NOP;
                        aluop = `EXE_OP_NOP_NOP;
                        imm_choose = `Imm_no;
                    end else begin
                        if (instr[30] == `I_alu_srli) begin
                            aluop = `EXE_OP_SHIFT_SRL;
                        end else begin
                            aluop = `EXE_OP_SHIFT_SRA;
                        end
                        imm_choose = `Imm_I_shift;
                        alusel = `EXE_RES_LOGIC;
                    end

                end

                //miss
                default:begin
                    alusel = `EXE_RES_NOP;
                    aluop = `EXE_OP_NOP_NOP;
                    imm_choose = `Imm_no;
                end 
                endcase
            end
            `I_load_type:
            begin
                isload = `Loaded;
                op1_rd_en = `ReadEnable;
                op2_rd_en = `ReadDisable;
                wr_en = `WriteEnable;      //wait 3 cycles to write back
                alusel = `EXE_RES_LOAD_STORE;
                alusrc = `AluSrc_imm;
                imm_choose = `Imm_I_type;
                case (instr[14:12])
                    `I_load_lb: begin
                        aluop = `EXE_OP_LOAD_STORE_LB;
                        loadtype = `loadbyte;
                    end
                    `I_load_lh: begin
                        aluop = `EXE_OP_LOAD_STORE_LH;
                        loadtype = `loadhalfword;
                    end
                    `I_load_lw: begin
                        aluop = `EXE_OP_LOAD_STORE_LW;
                        loadtype = `loadword;
                    end
                    `I_load_lbu: begin
                        aluop = `EXE_OP_LOAD_STORE_LBU;
                        loadtype = `loadbyteunsigned;
                    end
                    `I_load_lhu: begin
                        aluop = `EXE_OP_LOAD_STORE_LHU;
                        loadtype = `loadhalfwordunsigned;
                    end
                    default: aluop = `EXE_OP_NOP_NOP;
                endcase
            end
            `CSR_E:
            begin
                alusel = `EXE_RES_CSR;
                op2_rd_en = `ReadDisable;
                wr_en = `WriteEnable;
                case (instr[14:12])
                    `CSR_ECALL_EBREAK:
                    begin
                        aluop = `EXE_OP_CSR_ECALL;
                        op1_rd_en = `ReadEnable;
                        alusrc = `AluSrc_rs2;
                        imm_choose = `Imm_no;
                        //??????????/
                    end
                    `CSR_CSRRW:
                    begin
                        aluop = `EXE_OP_CSR_CSRRW;
                        op1_rd_en = `ReadEnable;
                        alusrc = `AluSrc_rs2;
                        imm_choose = `Imm_no;
                    end       
                    `CSR_CSRRS:
                    begin
                        aluop = `EXE_OP_CSR_CSRRS;
                        op1_rd_en = `ReadEnable;
                        alusrc = `AluSrc_rs2;
                        imm_choose = `Imm_no;
                    end       
                    `CSR_CSRRC:
                    begin
                        aluop = `EXE_OP_CSR_CSRRC;
                        op1_rd_en = `ReadEnable;
                        alusrc = `AluSrc_rs2;
                        imm_choose = `Imm_no;
                    end       
                    `CSR_CSRRWI:
                    begin
                        aluop = `EXE_OP_CSR_CSRRWI;
                        op1_rd_en = `ReadDisable;
                        alusrc = `AluSrc_imm;
                        imm_choose = `Imm_CSR;
                    end      
                    `CSR_CSRRSI:
                    begin
                        aluop = `EXE_OP_CSR_CSRRSI;
                        op1_rd_en = `ReadDisable;
                        alusrc = `AluSrc_imm;
                        imm_choose = `Imm_CSR;
                    end      
                    `CSR_CSRRCI:
                    begin
                        aluop = `EXE_OP_CSR_CSRRCI;
                        op1_rd_en = `ReadDisable;
                        alusrc = `AluSrc_imm;
                        imm_choose = `Imm_CSR;
                    end      
                    default:
                    begin
                        op1_rd_en = `ReadEnable;
                        alusrc = `AluSrc_rs2;
                        imm_choose = `Imm_no;
                    end
                endcase
            end
            endcase
        end
    end 

endmodule
