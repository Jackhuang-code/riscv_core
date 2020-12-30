`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 10:25:05
// Design Name: 
// Module Name: riscv_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: the riscv core, top module of five stage pipeline
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module riscv_core(
    input clk,
    input rst,
    input [`InstBus] rom_data_i,

    //access instruction rom
    output [`InstAddrBus] rom_addr_o,
    output rom_ce_o,

    //access memery
    input [`CacheLine] mem_rd_data,
    output [`DataAddrBus] mem_rd_addr,
    output mem_rd_en,
    output [`DataBus] mem_wr_data,
    output [`DataAddrBus] mem_wr_addr,
    output mem_wr_en,
    output [`SmallMemNumlog2-1:0] mem_wr_sel
    );

    //signals

    //IF
    wire [`InstBus] id_instr;
    wire [`InstAddrBus] if_pc, id_pc;

    //ID
    wire [`RegAddrBus] wr_bck_addr;
    wire [`RegBus]    wr_bck_data;
    wire wr_bck_en;
    wire [`RegBus] op1;
    wire [`RegBus] op2;
    wire [`RegAddrBus] id_reg_op1_rd_addr, id_reg_op2_rd_addr;
    wire id_reg_op1_rd_en, id_reg_op2_rd_en;
    wire [`AluOpBus] aluop;
    wire [`AluSelBus] alusel;
    wire wr_en;
    wire [`RegAddrBus] wr_reg_addr;
    wire [`LoadTypeNumlog2-1:0]   id_reg_loadtype;
    wire [`StoreTypeNumlog2-1:0] id_reg_storetype;
    wire id_reg_isload;
    wire id_stall_req;
    wire [`RegBus] id_reg_store_data;
    wire jump_branch_flag;
    wire [`InstAddrBus] jump_branch_addr;
    wire [`CSRAddrBus] id_reg_csr_wr_addr;
    wire id_reg_csr_wr_en;
    wire [`RegBus] id_reg_csr_rd_addr;
    wire [`RegBus] id_reg_jump_imm;

    //ID_EX
    wire [`RegBus] ex_op1;
    wire [`RegBus] ex_op2;
    wire [`AluOpBus] ex_aluop;
    wire [`AluSelBus] ex_alusel;
    wire ex_wr_bck_en;
    wire [`RegAddrBus] ex_wr_reg_addr;
    wire [`LoadTypeNumlog2-1:0]   id_ex_loadtype;
    wire [`StoreTypeNumlog2-1:0] id_ex_storetype;
    wire id_ex_isload; 
    wire id_ex_op1_rd_en;
    wire id_ex_op2_rd_en;
    wire [`RegAddrBus] id_ex_op1_rd_addr;
    wire [`RegAddrBus] id_ex_op2_rd_addr;
    wire [`RegBus] id_ex_store_data;
    wire  [`CSRAddrBus] id_ex_csr_wr_addr;
    wire  id_ex_csr_wr_en;
    wire  [`RegBus] id_ex_csr_rd_addr;
    wire [`RegBus] id_ex_jump_imm;

    //EX
    wire [`RegBus] ex_result;
    wire wr_bck_en_o;
    wire [`RegAddrBus] wr_reg_addr_o;
    wire ex_id_isload;
    wire [`LoadTypeNumlog2-1:0]   ex_reg_loadtype;
    wire [`StoreTypeNumlog2-1:0] ex_reg_storetype;
    wire ex_reg_isload;
    wire [`RegBus] ex_reg_store_data;
    wire [`RegBus] ex_reg_csr_wr_data;
    wire [`CSRAddrBus] ex_reg_csr_wr_addr;
    wire ex_reg_csr_wr_en;
    wire [`CSRAddrBus] ex_csr_rd_addr;
    //EX_MEM
    wire [`RegBus] mem_alu_result;
    wire mem_wr_bck_en;
    wire [`RegAddrBus] mem_wr_reg_addr;
    wire [`LoadTypeNumlog2-1:0]   ex_mem_loadtype;
    wire [`StoreTypeNumlog2-1:0] ex_mem_storetype;
    wire ex_mem_isload;
    wire [`RegBus] ex_mem_store_data;
    wire [`RegBus] ex_mem_csr_wr_data;
    wire [`CSRAddrBus] ex_mem_csr_wr_addr;
    wire ex_mem_csr_wr_en;
    
    //MEM
    wire [`RegBus] mem_result;
    wire wr_bck_en_to_wb;
    wire [`RegAddrBus] wr_reg_addr_to_wb;
    wire [`RegBus]    mem_ex_op;
    wire [`RegAddrBus]    mem_ex_op_addr;
    wire mem_ex_op_en;
    wire [`RegBus] mem_reg_csr_wr_data;
    wire [`CSRAddrBus] mem_reg_csr_wr_addr;
    wire mem_reg_csr_wr_en;

    //MEM_WB signals
    wire [`RegBus] mem_wb_result;
    wire wb_wr_bck_en;
    wire [`RegAddrBus] wb_wr_reg_addr;
    wire [`RegBus] mem_wb_csr_wr_data;
    wire [`CSRAddrBus] mem_wb_csr_wr_addr;
    wire mem_wb_csr_wr_en;

    //WB
    wire [`RegBus] csr_ex_rd_data;
    //pass pc
    wire [`InstAddrBus]  id_reg_pc, id_ex_pc, ex_reg_pc, ex_mem_pc, mem_reg_pc, mem_wb_pc;
    
    //ctrl
    wire stall_pc;
    wire stall_if_id;
    wire flush_id_ex;
    wire stall_ex_mem;
    wire flush_mem_wb;
    wire mem_cache_miss;
    wire stall_id_ex;

    ctrl stall_control(
        .rst(rst),
        .id_stall_req(id_stall_req),
        .ex_jump_branch_flush(jump_branch_flag),
        .mem_cache_miss(mem_cache_miss),
        .stall_pc(stall_pc),
        .stall_if_id(stall_if_id),
        .flush_id_ex(flush_id_ex),
        .stall_ex_mem(stall_ex_mem),
        .flush_mem_wb(flush_mem_wb),
        .stall_id_ex(stall_id_ex)
    );
    
    IF instr_fetch(
        .clk(clk),
        .rst(rst),
        .stall_pc(stall_pc),
        .rom_ce_o(rom_ce_o),
        .rom_addr_o(if_pc),
        .jump_branch_addr(jump_branch_addr),
        .jump_branch_flag(jump_branch_flag)
    );
    assign rom_addr_o = if_pc;
    
    IF_ID pipe_reg_if_id(
        .clk(clk),
        .rst(rst),
        .if_instr(rom_data_i),
        .if_pc(if_pc),
        .stall_if_id(stall_if_id),
        .id_instr(id_instr),
        .id_pc(id_pc)
    );

    ID instr_decoder(
    .clk(clk), 
    .rst(rst),

    .id_pc(id_pc),
    .id_instr(id_instr),

    .wr_bck_addr(wr_bck_addr),
    .wr_bck_data(wr_bck_data),
    .wr_bck_en(wr_bck_en),

    .ex_id_wr_bck_addr(wr_reg_addr_o),
    .ex_id_wr_bck_data(ex_result),
    .ex_id_bck_en(wr_bck_en_o),
    
    .mem_id_wr_bck_addr(wr_reg_addr_to_wb),
    .mem_id_wr_bck_data(mem_result),
    .mem_id_bck_en(wr_bck_en_to_wb),

    .op1(op1),
    .op2(op2),
    .op1_rd_addr(id_reg_op1_rd_addr),
    .op2_rd_addr(id_reg_op2_rd_addr),
    .op1_rd_en(id_reg_op1_rd_en),
    .op2_rd_en(id_reg_op2_rd_en),
    .aluop(aluop),
    .alusel(alusel),
    .ex_pc(id_reg_pc),
    .wr_en(wr_en),
    .wr_reg_addr(wr_reg_addr),
    .loadtype(id_reg_loadtype),
    .storetype(id_reg_storetype),
    .id_reg_store_data(id_reg_store_data),
    .id_reg_isload(id_reg_isload),
    .id_reg_jump_imm(id_reg_jump_imm),
    .id_stall_req(id_stall_req),
    .ex_id_isload(ex_id_isload),
    .id_reg_csr_wr_addr(id_reg_csr_wr_addr),
    .id_reg_csr_wr_en(id_reg_csr_wr_en),
    .id_reg_csr_rd_addr(id_reg_csr_rd_addr)
    );


    ID_EX pipe_reg_id_ex(
    .clk(clk),
    .rst(rst),
    .id_op1(op1),
    .id_op2(op2),
    .id_reg_op1_rd_addr(id_reg_op1_rd_addr),
    .id_reg_op2_rd_addr(id_reg_op2_rd_addr),
    .id_reg_op1_rd_en(id_reg_op1_rd_en),
    .id_reg_op2_rd_en(id_reg_op2_rd_en),
    .id_aluop(aluop),
    .id_alusel(alusel),
    .id_wr_bck_en(wr_en),
    .id_wr_reg_addr(wr_reg_addr),
    .id_pc(id_reg_pc),
    
    .id_reg_jump_imm(id_reg_jump_imm),
    .id_reg_loadtype(id_reg_loadtype),
    .id_reg_storetype(id_reg_storetype),
    .id_reg_store_data(id_reg_store_data),
    .id_reg_isload(id_reg_isload),

    .id_reg_csr_wr_addr(id_reg_csr_wr_addr),
    .id_reg_csr_wr_en(id_reg_csr_wr_en),
    .id_reg_csr_rd_addr(id_reg_csr_rd_addr),

    .flush_id_ex(flush_id_ex),
    .stall_id_ex(stall_id_ex),
    
    .ex_op1(ex_op1),
    .ex_op2(ex_op2),
    .ex_aluop(ex_aluop),
    .ex_alusel(ex_alusel),


    .ex_wr_bck_en(ex_wr_bck_en),
    .ex_wr_reg_addr(ex_wr_reg_addr),
    .ex_pc(id_ex_pc),

    .id_ex_op1_rd_addr(id_ex_op1_rd_addr),
    .id_ex_op1_rd_en(id_ex_op1_rd_en),
    .id_ex_op2_rd_addr(id_ex_op2_rd_addr),
    .id_ex_op2_rd_en(id_ex_op2_rd_en),
    .id_ex_loadtype(id_ex_loadtype),
    .id_ex_storetype(id_ex_storetype),
    .id_ex_store_data(id_ex_store_data),
    .id_ex_isload(id_ex_isload),
    .id_ex_jump_imm(id_ex_jump_imm),

    .id_ex_csr_wr_addr(id_ex_csr_wr_addr),
    .id_ex_csr_wr_en(id_ex_csr_wr_en),
    .id_ex_csr_rd_addr(id_ex_csr_rd_addr)
    );

    EX ex(
    .rst(rst),
    .op1(ex_op1),
    .op2(ex_op2),
    .aluop(ex_aluop),
    .alusel(ex_alusel),
    .wr_bck_en_i(ex_wr_bck_en),
    .wr_reg_addr_i(ex_wr_reg_addr),
    .ex_pc(id_ex_pc),

    .ex_result(ex_result),
    .wr_bck_en_o(wr_bck_en_o),
    .wr_reg_addr_o(wr_reg_addr_o),
    .mem_pc(ex_reg_pc),

    .op1_rd_addr(id_ex_op1_rd_addr),
    .op1_rd_en(id_ex_op1_rd_en),
    .op2_rd_addr(id_ex_op2_rd_addr),
    .op2_rd_en(id_ex_op2_rd_en),
    .id_ex_loadtype(id_ex_loadtype),
    .id_ex_store_data(id_ex_store_data),
    .id_ex_storetype(id_ex_storetype),
    .id_ex_isload(id_ex_isload),
    .id_ex_csr_wr_addr(id_ex_csr_wr_addr),
    .id_ex_csr_wr_en(id_ex_csr_wr_en),
    .id_ex_csr_rd_addr(id_ex_csr_rd_addr),
    .id_ex_jump_imm(id_ex_jump_imm),

    .ex_mem_loadtype(ex_reg_loadtype),
    .ex_reg_store_data(ex_reg_store_data),
    .ex_mem_storetype(ex_reg_storetype),
    .ex_mem_isload(ex_reg_isload),
    .ex_id_isload(ex_id_isload),

    .mem_ex_op(mem_ex_op),
    .mem_ex_op_addr(mem_ex_op_addr),
    .mem_ex_op_en(mem_ex_op_en),
    .mem_ex_csr_data(mem_reg_csr_wr_data),
    .mem_ex_csr_addr(mem_reg_csr_wr_addr),
    .mem_ex_csr_en(mem_reg_csr_wr_en),

    .jump_branch_addr(jump_branch_addr),
    .jump_branch_flag(jump_branch_flag),

    .ex_reg_csr_wr_data(ex_reg_csr_wr_data),
    .ex_reg_csr_wr_addr(ex_reg_csr_wr_addr),
    .ex_reg_csr_wr_en(ex_reg_csr_wr_en),
    .ex_csr_rd_addr(ex_csr_rd_addr),
    .csr_ex_rd_data(csr_ex_rd_data)
    );

    EX_MEM pipe_reg_ex_mem(
    .clk(clk),
    .rst(rst),
    .ex_alu_result(ex_result),
    .ex_wr_bck_en(wr_bck_en_o),
    .ex_wr_reg_addr(wr_reg_addr_o),
    .ex_pc(ex_reg_pc),
    .ex_reg_loadtype(ex_reg_loadtype),
    .ex_reg_storetype(ex_reg_storetype),
    .ex_reg_store_data(ex_reg_store_data),
    .ex_reg_isload(ex_reg_isload),
    .stall_ex_mem(stall_ex_mem),
    .ex_reg_csr_wr_data(ex_reg_csr_wr_data),
    .ex_reg_csr_wr_addr(ex_reg_csr_wr_addr),
    .ex_reg_csr_wr_en(ex_reg_csr_wr_en),

    .mem_alu_result(mem_alu_result),
    .mem_wr_bck_en(mem_wr_bck_en),
    .mem_wr_reg_addr(mem_wr_reg_addr),
    .mem_pc(ex_mem_pc),
    .ex_mem_loadtype(ex_mem_loadtype),
    .ex_mem_storetype(ex_mem_storetype),
    .ex_mem_store_data(ex_mem_store_data),
    .ex_mem_isload(ex_mem_isload),
    
    .ex_mem_csr_wr_data(ex_mem_csr_wr_data),
    .ex_mem_csr_wr_addr(ex_mem_csr_wr_addr),
    .ex_mem_csr_wr_en(ex_mem_csr_wr_en)
    );


    MEM mem(
    .clk(clk),
    .rst(rst),
    .alu_result_i(mem_alu_result),
    .wr_bck_en_i(mem_wr_bck_en),
    .wr_reg_addr_i(mem_wr_reg_addr),
    .mem_pc(ex_mem_pc),
    .loadtype(ex_mem_loadtype),
    .storetype(ex_mem_storetype),
    .ex_mem_isload(ex_mem_isload),
    .ex_mem_store_data(ex_mem_store_data),
    
    .ex_mem_csr_wr_data(ex_mem_csr_wr_data),
    .ex_mem_csr_wr_addr(ex_mem_csr_wr_addr),
    .ex_mem_csr_wr_en(ex_mem_csr_wr_en),

    .mem_result(mem_result),
    .wr_bck_en_o(wr_bck_en_to_wb),
    .wr_reg_addr_o(wr_reg_addr_to_wb),
    .wb_pc(mem_reg_pc),

    .mem_rd_data(mem_rd_data),
    .mem_rd_addr(mem_rd_addr),
    .mem_rd_en(mem_rd_en),
    .mem_wr_data(mem_wr_data),
    .mem_wr_addr(mem_wr_addr),
    .mem_wr_en(mem_wr_en),
    .mem_wr_sel(mem_wr_sel),

    .mem_ex_op(mem_ex_op),
    .mem_ex_op_addr(mem_ex_op_addr),
    .mem_ex_op_en(mem_ex_op_en),

    .mem_reg_csr_wr_data(mem_reg_csr_wr_data),
    .mem_reg_csr_wr_addr(mem_reg_csr_wr_addr),
    .mem_reg_csr_wr_en(mem_reg_csr_wr_en),

    .mem_cache_miss(mem_cache_miss)
    );

    MEM_WB pipe_reg_mem_wb(
    .clk(clk),
    .rst(rst),
    .mem_result(mem_result),
    .mem_wr_bck_en(wr_bck_en_to_wb),
    .mem_wr_reg_addr(wr_reg_addr_to_wb),
    .mem_pc(mem_reg_pc),
    .flush_mem_wb(flush_mem_wb),
    .mem_reg_csr_wr_data(mem_reg_csr_wr_data),
    .mem_reg_csr_wr_addr(mem_reg_csr_wr_addr),
    .mem_reg_csr_wr_en(mem_reg_csr_wr_en),
    
    .mem_wb_result(mem_wb_result),
    .wb_wr_bck_en(wb_wr_bck_en),
    .wb_wr_reg_addr(wb_wr_reg_addr),
    .wb_pc(mem_wb_pc),
    
    .mem_wb_csr_wr_data(mem_wb_csr_wr_data),
    .mem_wb_csr_wr_addr(mem_wb_csr_wr_addr),
    .mem_wb_csr_wr_en(mem_wb_csr_wr_en)
    );

    //WB 
    WB  write_back(
    .clk(clk),
    .rst(rst),
    .mem_result_i(mem_wb_result),
    .wr_bck_en_i(wb_wr_bck_en),
    .wr_reg_addr_i(wb_wr_reg_addr),
    .wb_pc(mem_wb_pc),
    .mem_wb_csr_wr_data(mem_wb_csr_wr_data),
    .mem_wb_csr_wr_addr(mem_wb_csr_wr_addr),
    .mem_wb_csr_wr_en(mem_wb_csr_wr_en),
    .ex_csr_rd_addr(ex_csr_rd_addr),
    .csr_ex_rd_data(csr_ex_rd_data),

    .wb_result(wr_bck_data),
    .wr_bck_en_o(wr_bck_en),
    .wr_reg_addr_o(wr_bck_addr)
    );

endmodule
