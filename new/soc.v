`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/01 20:22:17
// Design Name: 
// Module Name: soc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: soc: core, instruction rom, memery
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module soc(
    input clk,
    input rst
    );

    wire [`InstBus] rom_data;
    wire [`InstAddrBus] rom_addr;
    wire rom_ce_o;

    wire [`CacheLine] mem_rd_data;
    wire [`DataAddrBus] mem_rd_addr;
    wire mem_rd_en;
    wire [`DataBus] mem_wr_data;
    wire [`DataAddrBus] mem_wr_addr;
    wire mem_wr_en;
    wire [`SmallMemNumlog2-1:0] mem_wr_sel;

    riscv_core  core(
    .clk(clk),
    .rst(rst),
    .rom_data_i(rom_data),

    .rom_addr_o(rom_addr),
    .rom_ce_o(rom_ce_o),

    .mem_rd_en(mem_rd_en),
    .mem_rd_addr(mem_rd_addr),
    .mem_rd_data(mem_rd_data),

    .mem_wr_data(mem_wr_data),
    .mem_wr_addr(mem_wr_addr),
    .mem_wr_en(mem_wr_en),
    .mem_wr_sel(mem_wr_sel)
    );


    instr_rom instruction_rom(
    .ce(rom_ce_o),
    .pc(rom_addr),
    .instr(rom_data)
    );

    mem_ram memery_DRAM(
        .clk(clk),

        .ce(mem_rd_en),
        .rd_addr(mem_rd_addr),
        .rd_data(mem_rd_data),

        .wr_data(mem_wr_data),
        .wr_addr(mem_wr_addr),
        .we(mem_wr_en),
        .mem_wr_sel(mem_wr_sel)
    );

endmodule
