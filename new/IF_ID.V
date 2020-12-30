`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/26 17:03:25
// Design Name: 
// Module Name: IF_ID
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: pipeline reg between if and id
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IF_ID
(
    input   clk,
    input   rst,
    input  [`InstAddrBus]   if_pc,
    input [`InstBus]   if_instr,

    //pipeline stall
    input stall_if_id,

    output reg [`InstAddrBus]   id_pc,
    output reg [`InstBus]   id_instr
);


    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc <= `ZeroWord;
            id_instr <= `ZeroWord;
        end else if (stall_if_id == `NotStop)begin
            id_pc <= if_pc;
            id_instr <= if_instr;
        end
        //stall_if_id, then hold on the old pc and instruction
    end

endmodule  