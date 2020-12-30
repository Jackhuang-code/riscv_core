`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/11/30 09:17:19
// Design Name: 
// Module Name: MEM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: access memery stage
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MEM(
    input clk,
    input rst,
    input [`RegBus] alu_result_i,
    input wr_bck_en_i,
    input [`RegAddrBus] wr_reg_addr_i,
    input [`InstAddrBus]   mem_pc,
    input [`LoadTypeNumlog2-1:0]   loadtype,
    input [`StoreTypeNumlog2-1:0]   storetype,
    input [`RegBus] ex_mem_store_data,
    input ex_mem_isload,

    output reg [`RegBus] mem_result,
    output reg wr_bck_en_o,
    output reg [`RegAddrBus] wr_reg_addr_o,
    output reg [`InstAddrBus]   wb_pc,

    //access memery
    input [`CacheLine] mem_rd_data,
    output reg [`DataAddrBus] mem_rd_addr,
    output reg mem_rd_en,
    output reg [`DataBus] mem_wr_data,
    output reg [`DataAddrBus] mem_wr_addr,
    output reg mem_wr_en,
    output reg [`SmallMemNumlog2-1:0] mem_wr_sel,
    output reg mem_cache_miss,

    //send data from memery to ex advanced: 
    output reg [`RegBus]    mem_ex_op,
    output reg [`RegAddrBus]    mem_ex_op_addr,
    output reg mem_ex_op_en,

    input [`RegBus] ex_mem_csr_wr_data,
    input [`CSRAddrBus] ex_mem_csr_wr_addr,
    input ex_mem_csr_wr_en,
    output reg [`RegBus] mem_reg_csr_wr_data,
    output reg [`CSRAddrBus] mem_reg_csr_wr_addr,
    output reg mem_reg_csr_wr_en
    );



    //cache 
    wire [`CacheBlock] cache_rd_data;
    reg [`DataAddrBus] cache_rd_wr_addr;
    reg cache_rd_en;
    wire miss;
    reg cache_wr_en;
    reg [`CacheBlock] cache_wr_data;
    reg [`SmallMemNumlog2-1:0] cache_wr_sel;
    //reg [`CacheLine] update_data;
    reg update_en;
    cache data_cache(
    .clk(clk),
    .rst(rst),

    .cache_rd_wr_addr(cache_rd_wr_addr),
    .cache_rd_en(cache_rd_en),
    .cache_rd_data(cache_rd_data),
    .miss(miss),

    .cache_wr_en(cache_wr_en),
    .cache_wr_data(cache_wr_data),
    .cache_wr_sel(cache_wr_sel),
    .update_data(mem_rd_data),
    .update_en(update_en)
    );


    //choose load type
    reg [`RegBus]   loadresult;
    always @(*) begin
        if (rst == `RstEnable) begin
            //cache miss, access memery
            mem_rd_addr = `ZeroWord;
            mem_rd_en = `ReadDisable;
            mem_wr_addr = `ZeroWord;
            mem_wr_en = `WriteDisable;
            mem_wr_data = `ZeroWord;
            mem_wr_sel = `no_sel;
            //cache data
            cache_rd_wr_addr = `ZeroWord;
            cache_rd_en = `ReadDisable;
            cache_wr_en = `WriteDisable;
            cache_wr_data = `ZeroWord;
            cache_wr_sel = `no_sel;
            update_en = `NotUpdate;
            mem_cache_miss = `NotMiss;
            loadresult = `ZeroWord;
        end else begin
            mem_rd_addr = alu_result_i;
            mem_wr_addr = alu_result_i;
            cache_rd_wr_addr = alu_result_i;
            update_en = `NotUpdate;
            mem_cache_miss = `NotMiss;
            //load
            if (ex_mem_isload == `NotLoaded) begin
                cache_rd_en = `ReadDisable;
                mem_rd_en = `ReadDisable;
            end else begin
                cache_rd_en = `ReadEnable;
                if (miss == `Miss) begin
                    mem_rd_en = `ReadEnable;
                    mem_cache_miss = `Miss;
                    update_en = `Update;
                end else begin
                    mem_rd_en = `ReadDisable;
                end
            end
            case (loadtype)
                `noload: loadresult = `ZeroWord;        
                `loadbyte:   loadresult = {{24{cache_rd_data[7]}} , cache_rd_data[7:0]};            
                `loadhalfword:   loadresult = {{16{cache_rd_data[15]}}, cache_rd_data[15:0]};        
                `loadword:   loadresult = cache_rd_data[31:0];            
                `loadbyteunsigned:   loadresult = {24'b0, cache_rd_data[7:0]};    
                `loadhalfwordunsigned:   loadresult = {16'b0, cache_rd_data[15:0]};
                default: loadresult = `ZeroWord;
            endcase

            //store
            if (storetype == `nostore) begin
                mem_wr_en = `WriteDisable;
                cache_wr_en = `WriteDisable;
            end else begin
                mem_wr_en = `WriteEnable;
                cache_wr_en = `WriteEnable;
            end
            case (storetype)
                `nostore: begin 
                    mem_wr_data = `ZeroWord;
                    mem_wr_sel = `no_sel;
                    cache_wr_data = `ZeroWord;
                    cache_wr_sel = `no_sel;
                end
                `storebyte:   begin 
                    //zero extend
                    mem_wr_data = {24'b0, ex_mem_store_data[7:0]};
                    mem_wr_sel = `byte_sel;
                    cache_wr_data = {24'b0, ex_mem_store_data[7:0]};
                    cache_wr_sel = `byte_sel;
                end                
                `storehalfword:   begin
                    mem_wr_data = {16'b0, ex_mem_store_data[15:0]};
                    mem_wr_sel = `half_word_sel;
                    cache_wr_sel = `half_word_sel;
                    cache_wr_data = {16'b0, ex_mem_store_data[15:0]};
                end         
                `storeword:   begin
                    mem_wr_data = ex_mem_store_data[31:0];
                    mem_wr_sel = `word_sel;
                    cache_wr_sel = `word_sel;
                    cache_wr_data = ex_mem_store_data[31:0];
                end
                default: begin
                    mem_wr_data = `ZeroWord;
                    mem_wr_sel = `no_sel;
                    cache_wr_sel = `no_sel;
                    cache_wr_data = `ZeroWord;
                end
            endcase
        end
    end

    //propagate write back signals
    always @(*) begin
        if (rst == `RstEnable) begin
            mem_result = `ZeroWord;
            wr_bck_en_o = `WriteDisable;
            wr_reg_addr_o = `NOPRegAddr;
            wb_pc = `ZeroWord;
            mem_ex_op = `ZeroWord;
            mem_ex_op_addr = `NOPRegAddr;
            mem_ex_op_en = `RedirectDisable;
            mem_reg_csr_wr_data = `ZeroWord;
            mem_reg_csr_wr_addr = `CSR0;
            mem_reg_csr_wr_en = `WriteDisable;
        end else begin
            if (ex_mem_isload == `Loaded) 
                begin
                mem_result = loadresult;
                mem_ex_op = loadresult;
                mem_ex_op_en = `RedirectEnable;
            end else begin
                mem_result = alu_result_i;
                mem_ex_op = alu_result_i;
                mem_ex_op_en = `ReadDisable;
            end
            wr_bck_en_o = wr_bck_en_i;
            wr_reg_addr_o = wr_reg_addr_i;
            wb_pc <= mem_pc;
            mem_ex_op_addr = wr_reg_addr_i;
            mem_reg_csr_wr_data = ex_mem_csr_wr_data;
            mem_reg_csr_wr_addr = ex_mem_csr_wr_addr;
            mem_reg_csr_wr_en = ex_mem_csr_wr_en;
        end
    end

endmodule
