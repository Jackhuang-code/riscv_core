`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 09:05:36
// Design Name: 
// Module Name: EX_MEM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: pipeline reg between ex and mem
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module EX_MEM(
    input clk,
    input rst,
    input [`RegBus] ex_alu_result,
    input ex_wr_bck_en,
    input [`RegAddrBus] ex_wr_reg_addr,
    input [`InstAddrBus]   ex_pc,
    input stall_ex_mem,
    input [`LoadTypeNumlog2-1:0]   ex_reg_loadtype,
    input [`StoreTypeNumlog2-1:0] ex_reg_storetype,
    input [`RegBus] ex_reg_store_data,
    input ex_reg_isload,

    output reg [`RegBus] mem_alu_result,
    output reg mem_wr_bck_en,
    output reg [`RegAddrBus] mem_wr_reg_addr,
    output reg [`InstAddrBus]   mem_pc,
    output reg [`LoadTypeNumlog2-1:0]   ex_mem_loadtype,
    output reg [`StoreTypeNumlog2-1:0] ex_mem_storetype,
    output reg [`RegBus] ex_mem_store_data,
    output reg ex_mem_isload,

    //csr
    input [`RegBus] ex_reg_csr_wr_data,
    input [`CSRAddrBus] ex_reg_csr_wr_addr,
    input ex_reg_csr_wr_en,
    output reg [`RegBus] ex_mem_csr_wr_data,
    output reg [`CSRAddrBus] ex_mem_csr_wr_addr,
    output reg ex_mem_csr_wr_en
    );

    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            mem_alu_result <= `ZeroWord;
            mem_wr_bck_en <= `WriteDisable;
            mem_wr_reg_addr <= `NOPRegAddr;
            mem_pc <= `ZeroWord;
            ex_mem_loadtype <= `noload;
            ex_mem_storetype <= `nostore;
            ex_mem_store_data <= `ZeroWord;
            ex_mem_isload <= `NotLoaded;
            ex_mem_csr_wr_data <= `CSR0;
            ex_mem_csr_wr_addr <= `WriteDisable;
            ex_mem_csr_wr_en <= `CSR0;
        end else if (stall_ex_mem == `NotStop)begin
            mem_alu_result <= ex_alu_result;
            mem_wr_bck_en <= ex_wr_bck_en;
            mem_wr_reg_addr <= ex_wr_reg_addr;
            mem_pc <= ex_pc;
            ex_mem_loadtype <= ex_reg_loadtype;
            ex_mem_storetype <= ex_reg_storetype;
            ex_mem_store_data <= ex_reg_store_data;
            ex_mem_isload <= ex_reg_isload;
            ex_mem_csr_wr_data <= ex_reg_csr_wr_data;
            ex_mem_csr_wr_addr <= ex_reg_csr_wr_addr;
            ex_mem_csr_wr_en <= ex_reg_csr_wr_en;
        end
        //else: stall ex_mem, keep reg value
    end
endmodule
