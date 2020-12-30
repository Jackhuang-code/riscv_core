//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: HYJ
// 
// Create Date: 2020/11/26 12:00:45
// Design Name: 
// Module Name: 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: global variables
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// global define
`define RstEnable 			            1'b1			
`define RstDisable 			            1'b0			
`define ZeroWord 			            32'h00000000	
`define WriteEnable 		            1'b1			
`define WriteDisable 		            1'b0			
`define ReadEnable 			            1'b1			
`define ReadDisable 		            1'b0			
`define AluOpBus 			            7:0				
`define AluSelBus 			            2:0				
`define InstValid 			            1'b0			
`define InstInvalid 		            1'b1			
`define InDelaySlot 		            1'b1
`define NotInDelaySlot 		            1'b0
`define Jump_Branch 	                1'b1
`define NotJump_Branch 		            1'b0
`define InterruptAssert 	            1'b1
`define InterruptNotAssert 	            1'b0
`define TrapAssert 			            1'b1
`define TrapNotAssert 		            1'b0
`define ChipEnable 			            1'b1
`define ChipDisable 		            1'b0
`define Flush 				            1'b1
`define NotFlush			            1'b0
`define Loaded 				            1'b1
`define NotLoaded 			            1'b0
`define Stop                            1'b1
`define NotStop                         1'b0
`define Miss                            1'b1
`define NotMiss                         1'b0
`define Update                          1'b1
`define NotUpdate                       1'b0

//load type
`define LoadTypeNumlog2                 2'h3
`define noload                          3'b000
`define loadbyte                        3'b001
`define loadhalfword                    3'b010
`define loadword                        3'b011
`define loadbyteunsigned                3'b100
`define loadhalfwordunsigned            3'b101

//store type
`define StoreTypeNumlog2                2'h2
`define nostore                         2'b00
`define storebyte                       2'b01
`define storehalfword                   2'b10
`define storeword                       2'b11

//mem to ex op: redirect
`define RedirectEnable 			        1'b1
`define RedirectDisable 	            1'b0

// instruction rom
`define InstAddrBus 		            31:0
`define InstBus 			            31:0
`define InstMemNum 			            131071
`define InstMemNumLog2 		            17

// RAM 
`define DataAddrBus			            31:0
`define DataBus 			            31:0
`define DataMemNumber 		            131072
`define DataMemNumberLog2 	            32
// `define DataMemNumberLog2 	        17
//`define DataMemNumber 		        16
//`define DataMemNumberLog2 	        4
`define ByteWidth 			            7:0
`define SmallMemNumlog2                 2'h2
`define no_sel                          2'h0
`define byte_sel                        2'h1
`define half_word_sel                   2'h2
`define word_sel                        2'h3

//Cache
`define CacheLine			            255:0
`define CacheBlock                      31:0
`define CacheMemBus                     255:0
`define CacheLineNum                    4'h8
`define CacheLineNumLog2                2:0
`define CacheLine0                      3'b0
`define Tag                             31:5
`define CacheTag                        282:256
`define BlockAddr                       4:2
`define TagSize                         27
`define CacheLineWithTag                282:0

// register file
`define RegAddrBus 			            4:0
`define RegBus 				            31:0
`define RegWidth 			            32
`define DoubleRegWidth 		            64
`define DoubleRegBus 		            63:0
`define RegNum 				            32
`define RegNumLog2 			            5
`define NOPRegAddr 			            5'b00000
`define Reg0                            5'h0

// pipeline stall
`define StallEnable 	                1'b1
`define StallDisable 	                1'b0
`define StallNone 		                6'b000000
`define StallFromID 	                6'b000111
`define StallFromEX 	                6'b001111



///////////decode////////////////
//opcode
`define R_type                          7'b0110011
`define I_alu_type                      7'b0010011
`define S_type                          7'b0100011
`define I_load_type                     7'b0000011
`define B_type                          7'b1100011
`define I_jalr                          7'b1100111
`define J_jal                           7'b1101111
`define U_auipc                         7'b0010111
`define U_lui                           7'b0110111
`define CSR_E                           7'b1110011

//B_type
`define B_beq                           3'b000
`define B_bne                           3'b001
`define B_blt                           3'b100
`define B_bge                           3'b101
`define B_bltu                          3'b110
`define B_bgeu                          3'b111

//I_load_type
`define I_load_lb                       3'b000
`define I_load_lh                       3'b001
`define I_load_lw                       3'b010
`define I_load_lbu                      3'b100
`define I_load_lhu                      3'b101

//I_alu_type
`define  I_alu_addi                     3'b000
`define  I_alu_slti                     3'b010
`define  I_alu_sltiu                    3'b011
`define  I_alu_xori                     3'b100
`define  I_alu_ori                      3'b110
`define  I_alu_andi                     3'b111

`define  I_alu_slli                     3'b001
`define  I_alu_srli_or_srai             3'b101  //differ in func7
`define  I_alu_srai                     3'b101  
`define  I_alu_srli                     3'b101  

//R_type
`define R_add_or_sub_type               3'b000
`define R_sll                           3'b001
`define R_slt                           3'b010
`define R_sltu                          3'b011
`define R_xor                           3'b100
`define R_srl_or_sra_type               3'b101
`define R_or                            3'b110
`define R_and                           3'b111
//instr[30]         
`define R_add                           1'b0
`define R_sub                           1'b1
`define R_srl                           1'b0
`define R_sra                           1'b1


//S_type
`define S_sb                            3'b000
`define S_sh                            3'b001
`define S_sw                            3'b010

//immediate type    
`define Imm_type_num_log2               2'h3
`define Imm_no                          3'b000
`define Imm_I_type                      3'b001
`define Imm_S_type                      3'b011
`define Imm_B_type                      3'b010
`define Imm_U_type                      3'b100
`define Imm_J_type                      3'b101
`define Imm_I_shift                     3'b110
`define Imm_CSR                         3'b111

//CSR   func3
`define CSR_ECALL_EBREAK                3'b000
`define CSR_CSRRW                       3'b001
`define CSR_CSRRS                       3'b010
`define CSR_CSRRC                       3'b011
`define CSR_CSRRWI                      3'b101
`define CSR_CSRRSI                      3'b110
`define CSR_CSRRCI                      3'b111
//ECALL_EBREAK  instr[20]
`define CSR_ECALL                       1'b0
`define CSR_EBREAK                      1'b1


//alu source
`define AluSrc_imm 1'b0
`define AluSrc_rs2 1'b1


// AluSel
`define EXE_RES_NOP			            3'b000
`define EXE_RES_LOGIC 		            3'b001
`define EXE_RES_SHIFT		            3'b010
//`define EXE_RES_MOVE		            3'b011
`define EXE_RES_MATH		            3'b100
`define EXE_RES_JUMP_BRANCH	            3'b110
`define EXE_RES_LOAD_STORE 	            3'b111
`define EXE_RES_CSR		                3'b101


//alu operate
`define AluOp                           7:0
// AluOp
`define EXE_OP_NOP_NOP 		            8'h0 

`define EXE_OP_LOGIC_AND	            8'h1 
`define EXE_OP_LOGIC_OR		            8'h2 
`define EXE_OP_LOGIC_XOR 	            8'h3 
`define EXE_OP_LOGIC_NOR 	            8'h4 
`define EXE_OP_LOGIC_ANDI	            8'h5 
`define EXE_OP_LOGIC_ORI	            8'h6 
`define EXE_OP_LOGIC_XORI	            8'h7 
`define EXE_OP_LOGIC_NORI	            8'h8 

`define EXE_OP_SHIFT_SLL	            8'h9 
`define EXE_OP_SHIFT_SRL	            8'ha 
`define EXE_OP_SHIFT_SRA	            8'hb 
`define EXE_OP_SHIFT_SLLI	            8'hc 
`define EXE_OP_SHIFT_SRLI	            8'hd 
`define EXE_OP_SHIFT_SRAI	            8'he 
`define EXE_OP_SHIFT_LUI	            8'hf 

`define EXE_OP_MATH_ADD		            8'h10
`define EXE_OP_MATH_ADDI	            8'h11
`define EXE_OP_MATH_SUB		            8'h12
`define EXE_OP_MATH_SLT		            8'h13
`define EXE_OP_MATH_SLTU	            8'h14
`define EXE_OP_MATH_SLTI		        8'h15
`define EXE_OP_MATH_SLTUI		        8'h16
`define EXE_OP_MATH_AUIPC		        8'h17

`define EXE_OP_JUMP_BRANCH_JALR		    8'h18
`define EXE_OP_JUMP_BRANCH_JAL		    8'h19
`define EXE_OP_JUMP_BRANCH_BEQ		    8'h1a
`define EXE_OP_JUMP_BRANCH_BNE		    8'h1b
`define EXE_OP_JUMP_BRANCH_BLTU		    8'h1c
`define EXE_OP_JUMP_BRANCH_BGE		    8'h1d
`define EXE_OP_JUMP_BRANCH_BLT 	        8'h1e
`define EXE_OP_JUMP_BRANCH_BGEU 	    8'h1f

`define EXE_OP_LOAD_STORE_LB 		    8'h20
`define EXE_OP_LOAD_STORE_LH 		    8'h21
`define EXE_OP_LOAD_STORE_LW 		    8'h22
`define EXE_OP_LOAD_STORE_LBU 		    8'h23
`define EXE_OP_LOAD_STORE_LHU 		    8'h24
`define EXE_OP_LOAD_STORE_SB 		    8'h25
`define EXE_OP_LOAD_STORE_SH 		    8'h26
`define EXE_OP_LOAD_STORE_SW 		    8'h27

`define EXE_OP_CSR_CSRRW 		        8'h28
`define EXE_OP_CSR_CSRRWI 		        8'h29
`define EXE_OP_CSR_CSRRC 		        8'h2a
`define EXE_OP_CSR_CSRRCI 		        8'h2b
`define EXE_OP_CSR_CSRRS 		        8'h2c
`define EXE_OP_CSR_CSRRSI 		        8'h2d
`define EXE_OP_CSR_ECALL 		        8'h2e
`define EXE_OP_CSR_EBREAK 		        8'h2f



////CSR addr/////
`define CSRAddrBus                      11:0
`define CSR0                            12'h0
`define CSR_EPC                         12'h1
`define CSR_CAUSE                       12'h2
`define CSR_MIE                         12'h3
`define CSR_MIP                         12'h4
`define CSR_MTVAL                       12'h5
`define CSR_MSCRATCH                    12'h6
`define CSR_MSTATUS                     12'h7
`define CSR_MTVEC                       12'h8