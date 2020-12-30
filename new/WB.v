`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 08:21:59
// Design Name: 
// Module Name: WB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: write back stage
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module WB(
    input clk,
    input rst,
    input [`RegBus] mem_result_i,
    input wr_bck_en_i,
    input [`RegAddrBus] wr_reg_addr_i,
    input [`InstAddrBus]   wb_pc,

    output reg [`RegBus] wb_result,
    output reg wr_bck_en_o,
    output reg [`RegAddrBus] wr_reg_addr_o,
    output reg [`InstAddrBus] pc,
    //??????pc where to go

    //csr read and write
    input [`RegBus] mem_wb_csr_wr_data,
    input [`CSRAddrBus] mem_wb_csr_wr_addr,
    input mem_wb_csr_wr_en,

    input [`CSRAddrBus] ex_csr_rd_addr,
    output [`RegBus] csr_ex_rd_data
    );

    //propagate write back signals
    always @(*) begin
        if (rst == `RstEnable) begin
            wb_result = `ZeroWord;
            wr_bck_en_o = `WriteDisable;
            wr_reg_addr_o = `NOPRegAddr;
        end else begin
            wb_result = mem_result_i;
            wr_bck_en_o = wr_bck_en_i;
            wr_reg_addr_o = wr_reg_addr_i;
        end
    end

    csr control_status_reg(
        .clk(clk),
        .rst(rst),
        .csr_wr_data(mem_wb_csr_wr_data),
        .csr_wr_addr(mem_wb_csr_wr_addr),
        .csr_wr_en(mem_wb_csr_wr_en),

        .csr_rd_addr(ex_csr_rd_addr),
        .csr_rd_data(csr_ex_rd_data)
    );
endmodule
