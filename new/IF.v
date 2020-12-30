`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: HYJ
// 
// Create Date: 2020/11/26 11:54:35
// Design Name: 
// Module Name: IF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: instrction fetch stage 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IF(
    input clk,
    input rst,
    input stall_pc,
    input jump_branch_flag,
    input [`InstAddrBus] jump_branch_addr,

    output rom_ce_o,        //chip enable
    output reg [`InstAddrBus] rom_addr_o    //pc
    );

    wire [`InstAddrBus] pc;
    pc_gen pc_generator(
        .clk(clk), 
        .rst(rst),
        .stall_pc(stall_pc),
        .jump_branch_flag(jump_branch_flag),
        .jump_branch_addr(jump_branch_addr),
        .pc(pc),
        .ce(rom_ce_o)
    );

    //choose instruction addr
    always @(*) begin
        if (rst == `RstEnable) begin
            rom_addr_o <= `ZeroWord;
        end else begin
            if (jump_branch_flag == `Jump_Branch) begin
                rom_addr_o <= jump_branch_addr;
            end else begin
                rom_addr_o <= pc;
            end
        end
    end

endmodule
