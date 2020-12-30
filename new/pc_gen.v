`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/26 11:58:13
// Design Name: 
// Module Name: pc_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: generate pc
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pc_gen(
    input clk, rst,
    //pipeline stall
    input stall_pc,
    input jump_branch_flag,
    input [`InstAddrBus] jump_branch_addr,

    output [`InstAddrBus] pc,
    output reg ce
    );
    reg [`InstAddrBus] gen_pc;
    assign pc = gen_pc;
    
    always @(posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable;
        end
        else if(rst == `RstDisable) begin
            ce <= `ChipEnable;
        end
    end

    always @(posedge clk) begin
        if (ce == `ChipDisable) begin
            gen_pc <=  `ZeroWord;
        end else if (stall_pc == `NotStop )begin
            if (jump_branch_flag == `Jump_Branch) begin
                gen_pc <= jump_branch_addr + 4'h4;
            end else begin
                gen_pc <= gen_pc + 4'h4;
            end
        end
        //stall pc, then hold on the old pc
    end
endmodule
