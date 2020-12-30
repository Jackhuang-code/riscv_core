`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/26 18:04:18
// Design Name: 
// Module Name: ID
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: instruction decode stage:
//                  1.decode  2.get operator 3.extend immediate
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ID(
    input clk, rst,

    //input instruction and pc
    input [`InstAddrBus]   id_pc,
    input [`InstBus]   id_instr,

    //write back from WB stage
    input [`RegAddrBus] wr_bck_addr,
    input [`RegBus]    wr_bck_data,
    input wr_bck_en,

    //check data independecy
    input [`RegAddrBus] ex_id_wr_bck_addr,
    input [`RegBus]    ex_id_wr_bck_data,
    input ex_id_bck_en,
    
    input [`RegAddrBus] mem_id_wr_bck_addr,
    input [`RegBus]    mem_id_wr_bck_data,
    input mem_id_bck_en,

    //load use check
    input ex_id_isload,

    //send to EXE: operator, operation, write back
    output reg [`RegBus] op1,
    output reg [`RegBus] op2,
    output [`RegAddrBus] op1_rd_addr, op2_rd_addr,
    output op1_rd_en, op2_rd_en,
    output [`AluOpBus] aluop,
    output [`AluSelBus] alusel,

    //send rs imm to ex to calculate jump addr
    output [`RegBus] id_reg_jump_imm,

    //propagate pc
    output [`InstAddrBus]   ex_pc,

    //write back after 3 cycles
    output  wr_en,
    output [`RegAddrBus] wr_reg_addr,

    //generate load store signals
    output [`LoadTypeNumlog2-1:0]   loadtype,
    output [`StoreTypeNumlog2-1:0] storetype,
    output reg [`RegBus] id_reg_store_data,
    output id_reg_isload,
    output reg id_stall_req,


    //csr
    output [`CSRAddrBus] id_reg_csr_wr_addr,
    output id_reg_csr_wr_en,
    output [`RegBus] id_reg_csr_rd_addr
    );

    wire [`Imm_type_num_log2-1:0]   imm_choose;
    wire alusrc;

    //propagate pc
    assign ex_pc = (rst == `RstEnable)? `ZeroWord : id_pc;

    //decode rs1, rs2
    wire [`RegBus] rs1_data, rs2_data;
    reg [`RegBus] rs2_depen;

    //write back addr
    assign wr_reg_addr = id_instr[11:7];
    //read addr
    assign op1_rd_addr= id_instr[19:15];
    assign op2_rd_addr = id_instr[24:20];

    //csr read and write
    assign id_reg_csr_wr_addr = id_instr[31:20];
    assign id_reg_csr_rd_addr = id_instr[31:20];
    assign id_reg_csr_wr_en = (alusel == `EXE_RES_CSR)? `WriteEnable: `WriteDisable;

    instr_decoder decoder(
    .rst(rst),
    .instr(id_instr),    
    .op1_rd_en(op1_rd_en),  
    .op2_rd_en(op2_rd_en),  
    .wr_en(wr_en),
    .imm_choose(imm_choose), 
    .aluop(aluop),
    .alusel(alusel),      
    .alusrc(alusrc),
    .loadtype(loadtype),
    .storetype(storetype),
    .isload(id_reg_isload)
    );

    regfile registers(
        .clk(clk),
        .rst(rst),
        .op1_rd_addr(op1_rd_addr),
        .op1_rd_en(op1_rd_en),
        .op1(rs1_data),

        .op2_rd_addr(op2_rd_addr),
        .op2_rd_en(op2_rd_en),
        .op2(rs2_data),

        .wr_addr(wr_bck_addr),
        .wr_data(wr_bck_data),
        .wr_en(wr_bck_en)
    );

    wire [`RegBus]  rs2_imm;
    imm_gen generate_immediate(
        .instr(id_instr),
        .imm_type(imm_choose),
        .immediate(rs2_imm)
    );
    //rs imm to ex to calculate jump addr
    assign id_reg_jump_imm = rs2_imm;

    //choose op1
    always @(*) begin
        if ((op1_rd_en == `ReadEnable) && (ex_id_bck_en == `WriteEnable) && (op1_rd_addr == ex_id_wr_bck_addr)) begin
            op1 = ex_id_wr_bck_data;
        end else if ((op1_rd_en == `ReadEnable) && (mem_id_bck_en == `WriteEnable) && (op1_rd_addr == mem_id_wr_bck_addr)) begin
            op1 = mem_id_wr_bck_data;
        end
        else begin
            op1 = rs1_data;
        end
    end

    //choose rs2 and store data(rs2 data)
    always @(*) begin
        if ((op2_rd_en == `ReadEnable) && (ex_id_bck_en == `WriteEnable) && (op2_rd_addr == ex_id_wr_bck_addr)) begin
            rs2_depen = ex_id_wr_bck_data;
            if (storetype == `storebyte  ||  
                storetype == `storehalfword ||
                storetype == `storeword    ) begin
                id_reg_store_data = ex_id_wr_bck_data;
            end else begin
                id_reg_store_data = `ZeroWord;
            end
        end else if ((op2_rd_en == `ReadEnable) && (mem_id_bck_en == `WriteEnable) && (op2_rd_addr == mem_id_wr_bck_addr)) begin
            rs2_depen = mem_id_wr_bck_data;
            if (storetype == `storebyte  ||  
                storetype == `storehalfword ||
                storetype == `storeword    ) begin
                id_reg_store_data = mem_id_wr_bck_data;
            end else begin
                id_reg_store_data = `ZeroWord;
            end
        end
        else begin
            rs2_depen = rs2_data;
            if (storetype == `storebyte  ||  
                storetype == `storehalfword ||
                storetype == `storeword    ) begin
                id_reg_store_data = rs2_data;
            end else begin
                id_reg_store_data = `ZeroWord;
            end
        end
    end

    // choose op2
    always @(*) begin
        case (alusrc)
        `AluSrc_imm: op2 = rs2_imm;
        `AluSrc_rs2: op2 = rs2_depen;
        default: op2 = `ZeroWord;
        endcase
    end

    //generate stall pipe signals
    always @(*) begin
        if (rst == `RstEnable) begin
            id_stall_req = `NotStop;
        end else begin
            if (ex_id_isload == `Loaded &&
                op1_rd_en == `ReadEnable &&
                op1_rd_addr == ex_id_wr_bck_addr) begin
                id_stall_req = `Stop;
            end else if (ex_id_isload == `Loaded &&
                        op2_rd_en == `ReadEnable &&
                        op2_rd_addr == ex_id_wr_bck_addr)begin
                id_stall_req = `Stop;
            end else begin
                id_stall_req = `NotStop;
            end
        end
    end

endmodule
