`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/26 17:11:43
// Design Name: 
// Module Name: regfile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: regfile for operator
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module regfile(
    input clk, rst,

    //read op1 op2
    input [`RegAddrBus]    op1_rd_addr,
    input op1_rd_en,
    output reg [`RegBus]    op1,

    input [`RegAddrBus]    op2_rd_addr,
    input op2_rd_en,
    output reg [`RegBus]    op2,

    //write op3
    input [`RegAddrBus]    wr_addr,
    input [`RegBus]    wr_data,
    input wr_en

);
    //register files
    reg [`RegBus]   register [0:`RegNum-1];

    //write register
    always @(posedge clk) begin
        if (rst == `RstDisable) begin
            if ((wr_en == `WriteEnable) && (wr_addr != `Reg0)) begin
                register[wr_addr] <= wr_data;
            end
        end
    end

    //read op1
    always @(*) begin
        if (rst == `RstEnable) begin
            op1 = `ZeroWord;
        end
        else if (op1_rd_addr == `Reg0) begin
            op1 = `ZeroWord;
        end
        else if (op1_rd_en == `ReadEnable) begin
            if ((op1_rd_addr == wr_addr) && (wr_en == `WriteEnable)) begin
                op1 = wr_data;
            end else begin
                op1 = register[op1_rd_addr];
            end
        end
        else begin
            op1 = `ZeroWord;
        end
    end


    //read op2
    always @(*) begin
        if (rst == `RstEnable) begin
            op2 = `ZeroWord;
        end
        else if (op2_rd_addr == `Reg0) begin
            op2 = `ZeroWord;
        end
        else if (op2_rd_en == `ReadEnable) begin
            if ((op2_rd_addr == wr_addr) && (wr_en == `WriteEnable)) begin
                op2 = wr_data;
            end else begin
                op2 = register[op2_rd_addr];
            end
        end
        else begin
            op2 = `ZeroWord;
        end
    end
    
endmodule  //regfile