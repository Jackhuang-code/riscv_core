`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/26 18:04:18
// Design Name: 
// Module Name: ID_EX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: pipeline reg between id and exe 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ID_EX(
    input clk, rst,
    input [`RegBus] id_op1,
    input [`RegBus] id_op2,
    input id_reg_op1_rd_en,
    input id_reg_op2_rd_en,
    input [`RegAddrBus] id_reg_op1_rd_addr,
    input [`RegAddrBus] id_reg_op2_rd_addr,
    input [`AluOpBus] id_aluop,
    input [`AluSelBus] id_alusel,
    input  id_wr_bck_en,
    input [`RegAddrBus] id_wr_reg_addr,
    input [`InstAddrBus] id_pc,
    input [`RegBus] id_reg_jump_imm,

    //load type
    input [`LoadTypeNumlog2-1:0]   id_reg_loadtype,
    input [`StoreTypeNumlog2-1:0] id_reg_storetype,
    input [`RegBus] id_reg_store_data,
    input id_reg_isload, 

    //load use stall pipeline
    input flush_id_ex,
    input stall_id_ex,
    output reg [`RegBus] ex_op1,
    output reg [`RegBus] ex_op2,
    output reg [`AluOpBus] ex_aluop,
    output reg [`AluSelBus] ex_alusel,
    output reg ex_wr_bck_en,
    output reg [`RegAddrBus] ex_wr_reg_addr,
    output reg [`InstAddrBus]  ex_pc,
    output reg id_ex_op1_rd_en,
    output reg id_ex_op2_rd_en,
    output reg [`RegAddrBus] id_ex_op1_rd_addr,
    output reg [`RegAddrBus] id_ex_op2_rd_addr,
    output reg [`LoadTypeNumlog2-1:0]   id_ex_loadtype,
    output reg [`StoreTypeNumlog2-1:0] id_ex_storetype,
    output reg [`RegBus] id_ex_store_data,
    output reg id_ex_isload,
    output reg [`RegBus] id_ex_jump_imm,

    //csr
    input [`CSRAddrBus] id_reg_csr_wr_addr,
    input id_reg_csr_wr_en,
    input [`RegBus] id_reg_csr_rd_addr,
    output reg  [`CSRAddrBus] id_ex_csr_wr_addr,
    output reg  id_ex_csr_wr_en,
    output reg  [`RegBus] id_ex_csr_rd_addr
    );

    always @(posedge clk) begin
        if (rst == `RstEnable ||
        //load_use flush ex
            flush_id_ex == `Flush) begin
            ex_op1 <= `ZeroWord;
            ex_op2 <= `ZeroWord;
            ex_aluop <= `EXE_OP_NOP_NOP;
            ex_alusel <= `EXE_RES_NOP;
            ex_wr_bck_en <= `WriteDisable;
            ex_wr_reg_addr <= `NOPRegAddr;
            ex_pc <= `ZeroWord;

            id_ex_op1_rd_en = `ReadDisable;
            id_ex_op2_rd_en = `ReadDisable;
            id_ex_op1_rd_addr = `NOPRegAddr;
            id_ex_op2_rd_addr = `NOPRegAddr;
            id_ex_loadtype = `noload;
            id_ex_storetype = `nostore;
            id_ex_store_data =  `ZeroWord;
            id_ex_isload = `NotLoaded;
            id_ex_jump_imm = `ZeroWord;
            id_ex_csr_wr_addr = `CSR0;
            id_ex_csr_wr_en = `WriteDisable;
            id_ex_csr_rd_addr = `CSR0;
        end else if (stall_id_ex == `NotStop)begin
            ex_op1 <= id_op1;
            ex_op2 <= id_op2;
            ex_aluop <= id_aluop;
            ex_alusel <= id_alusel;
            ex_wr_bck_en <= id_wr_bck_en;
            ex_wr_reg_addr <= id_wr_reg_addr;
            ex_pc <= id_pc;

            id_ex_op1_rd_en = id_reg_op1_rd_en;
            id_ex_op2_rd_en = id_reg_op2_rd_en;
            id_ex_op1_rd_addr = id_reg_op1_rd_addr;
            id_ex_op2_rd_addr = id_reg_op2_rd_addr;
            id_ex_loadtype = id_reg_loadtype;
            id_ex_storetype = id_reg_storetype;
            id_ex_store_data = id_reg_store_data;
            id_ex_isload = id_reg_isload;
            id_ex_jump_imm = id_reg_jump_imm;
            id_ex_csr_wr_addr = id_reg_csr_wr_addr;
            id_ex_csr_wr_en = id_reg_csr_wr_en;
            id_ex_csr_rd_addr = id_reg_csr_rd_addr;
        end
        //else: stall_id_ex = stop, hold reg value
    end

endmodule
