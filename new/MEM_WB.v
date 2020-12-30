`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 10:10:31
// Design Name: 
// Module Name: MEM_WB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: pipeline reg between mem and wb
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MEM_WB(
    input clk,
    input rst,
    input [`RegBus] mem_result,
    input mem_wr_bck_en,
    input [`RegAddrBus] mem_wr_reg_addr,
    input [`InstAddrBus]   mem_pc,
    
    input flush_mem_wb,

    output reg [`RegBus] mem_wb_result,
    output reg wb_wr_bck_en,
    output reg [`RegAddrBus] wb_wr_reg_addr,
    output reg [`InstAddrBus]   wb_pc,

    //csr
    input [`RegBus] mem_reg_csr_wr_data,
    input [`CSRAddrBus] mem_reg_csr_wr_addr,
    input mem_reg_csr_wr_en,
    output reg [`RegBus] mem_wb_csr_wr_data,
    output reg [`CSRAddrBus] mem_wb_csr_wr_addr,
    output reg mem_wb_csr_wr_en
    );


    always @(posedge clk) begin
        if (rst == `RstEnable ||
            flush_mem_wb == `Flush) begin
            mem_wb_result <= `ZeroWord;
            wb_wr_bck_en <= `WriteDisable;
            wb_wr_reg_addr <= `NOPRegAddr;
            wb_pc <= `ZeroWord;
            mem_wb_csr_wr_data <= `CSR0;
            mem_wb_csr_wr_addr <= `WriteDisable;
            mem_wb_csr_wr_en <= `CSR0;
        end else begin
            mem_wb_result <= mem_result;
            wb_wr_bck_en <= mem_wr_bck_en;
            wb_wr_reg_addr <= mem_wr_reg_addr;
            wb_pc <= mem_pc;
            mem_wb_csr_wr_data <= mem_reg_csr_wr_data;
            mem_wb_csr_wr_addr <= mem_reg_csr_wr_addr;
            mem_wb_csr_wr_en <= mem_reg_csr_wr_en;
        end
    end
endmodule
