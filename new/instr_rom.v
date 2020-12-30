`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/26 11:58:13
// Design Name: 
// Module Name: instr_rom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: rom to store instruction
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instr_rom(
    input ce,
    input [`InstAddrBus] pc,
    output [`InstBus] instr
    );

    reg [`ByteWidth] ins_rom [0:`InstMemNum-1];

    initial $readmemh("I:/Verilog/risc_v_cpu/risc_v_cpu.srcs/sources_1/new/rom.txt", ins_rom);

//    initial begin
//    ins_rom[0] = 8'hFF;
//    ins_rom[1] = 8'hF0;
//    ins_rom[2] = 8'h60;
//    ins_rom[3] = 8'h93;

//    ins_rom[5] = 8'hAA;
//    ins_rom[6] = 8'hA0;
//    ins_rom[7] = 8'h6F;
//    ins_rom[8] = 8'h93;
//    end
    assign instr = ce ? {ins_rom[pc], ins_rom[pc+1], ins_rom[pc+2], ins_rom[pc+3]} : `ZeroWord;
endmodule
