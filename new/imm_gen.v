`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/27 11:23:19
// Design Name: 
// Module Name: imm_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: generate immediate for alu
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module imm_gen(
    input [`InstBus]    instr,
    input [`Imm_type_num_log2-1:0] imm_type,
    output reg [`RegBus]    immediate
    );

    always @(*) begin
        case (imm_type)
        //no immediate
        `Imm_no: immediate = `ZeroWord;
        //low 12 bit, sign extend
        `Imm_I_type: immediate = {{20{instr[31]}}, instr[31:20]};
        //low 12 bit, sign extend, left shift to jump or branch
        `Imm_B_type: immediate = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        //low 12 bit, sign extend
        `Imm_S_type: immediate = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        //high 20 bit
        `Imm_U_type: immediate = {instr[31:12], 12'b0};
        //
        `Imm_J_type: immediate = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        `Imm_I_shift: immediate = {27'b0, instr[24:20]};
        //csr
        `Imm_CSR: immediate = {27'b0, instr[19:15]};
        default: immediate = `ZeroWord;
        endcase
    end
endmodule
