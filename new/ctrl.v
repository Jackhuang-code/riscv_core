`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/09 21:57:50
// Design Name: 
// Module Name: ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: control unit to stall/flush pipeline
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ctrl(
    input rst,
    input id_stall_req,
    input ex_jump_branch_flush,
    input mem_cache_miss,

    output reg stall_pc,
    output reg stall_if_id,
    output reg flush_id_ex,
    output reg stall_ex_mem,
    output reg flush_mem_wb,
    output reg stall_id_ex
    );

    always @(*) begin
        if (rst == `RstEnable) begin
            stall_pc = `NotStop;
            stall_if_id = `NotStop;
            flush_id_ex = `NotFlush;
            stall_ex_mem = `NotStop;
            flush_mem_wb = `NotFlush;
            stall_id_ex = `NotStop;
        end else begin
            //cache miss, stall pipeline
            if (mem_cache_miss == `Miss) begin
                stall_pc = `Stop;
                stall_if_id = `Stop;
                flush_id_ex = `NotFlush;
                stall_ex_mem = `Stop;
                flush_mem_wb = `Flush;
                stall_id_ex = `Stop;
            //load_use
            end else if (id_stall_req == `Stop) begin
                stall_pc = `Stop;
                stall_if_id = `Stop;
                flush_id_ex = `Flush;
                stall_ex_mem = `NotStop;
                flush_mem_wb = `NotFlush;
                stall_id_ex = `NotStop;
            end else if (ex_jump_branch_flush == `Stop)begin
                stall_pc = `NotStop;
                stall_if_id = `NotStop;
                flush_id_ex = `Flush;
                stall_ex_mem = `NotStop;
                flush_mem_wb = `NotFlush;
                stall_id_ex = `NotStop;
            end
            else begin
                stall_pc = `NotStop;
                stall_if_id = `NotStop;
                flush_id_ex = `NotFlush;
                stall_ex_mem = `NotStop;
                flush_mem_wb = `NotFlush;
                stall_id_ex = `NotStop;
            end
        end
    end

endmodule
