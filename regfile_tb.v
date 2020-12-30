`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/02 11:57:11
// Design Name: 
// Module Name: regfile_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module regfile_tb( );
reg clk, rst;
reg [4:0] wr_addr, op1_addr;
reg wr_en, rd1_en;
reg [31:0] wr_data;
wire [31:0] op1,op2;

always #5 clk = ~clk;
initial begin
   clk = 0;
   rst = 1;
   #10
   rst = 0;
   #43
   rd1_en = 1'b1;
   op1_addr = 5'h1;
   #2
   wr_addr = 5'h1;
   wr_data = 32'h00000fff;
   wr_en = 1'b1;
   
end


    regfile reg0(clk, rst,op1_addr, rd1_en,op1,5'b0, 1'b0,op2,
        wr_addr,
        wr_data,
        wr_en);
        
endmodule

