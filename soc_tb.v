`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/01 21:48:35
// Design Name: 
// Module Name: soc_tb
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


module soc_tb();

reg clk, rst;

always #5 clk = ~clk;

initial begin
   clk = 0;
   rst = 1;
   #10
   rst = 0;
end
    soc test(
    .clk(clk),
    .rst(rst)
    );
endmodule
