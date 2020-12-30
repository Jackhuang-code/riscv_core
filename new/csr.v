`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/24 11:19:01
// Design Name: 
// Module Name: csr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: control and status register
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module csr(
    input clk,
    input rst,

    //write csr
    input [`RegBus] csr_wr_data,
    input [`CSRAddrBus] csr_wr_addr,
    input csr_wr_en,
    //read csr
    input [`CSRAddrBus] csr_rd_addr,
    output reg [`RegBus] csr_rd_data
    );


    //reg
    reg [`RegBus] mtvec;
    reg [`RegBus] epc;
    reg [`RegBus] cause;
    reg [`RegBus] mie;
    reg [`RegBus] mip;
    reg [`RegBus] mtval;
    reg [`RegBus] mscratch;
    reg [`RegBus] mstatus;

    //write
    always @(posedge clk) begin
        if (rst == `RstDisable) begin
            if (csr_wr_en == `WriteEnable) begin
                case (csr_wr_addr)
                    `CSR_EPC:    epc <= csr_wr_data;
                    `CSR_CAUSE:    cause <= csr_wr_data;
                    `CSR_MIE:    mie <= csr_wr_data;
                    `CSR_MIP:    mip <= csr_wr_data;
                    `CSR_MTVAL:    mtval <= csr_wr_data;
                    `CSR_MSCRATCH:    mscratch <= csr_wr_data;
                    `CSR_MSTATUS:    mstatus <= csr_wr_data;
                    `CSR_MTVEC:    mtvec <= csr_wr_data; 
                    default: begin
                    end
                endcase
            end
        end else begin
            epc <= `ZeroWord;
            cause <= `ZeroWord;
            mie <= `ZeroWord;
            mip <= `ZeroWord;
            mtval <= `ZeroWord;
            mscratch <= `ZeroWord;
            mstatus <= `ZeroWord;
            mtvec <= `ZeroWord; 
        end
    end

    //read
    always @(*) begin
        if (rst == `RstEnable) begin
            csr_rd_data = `ZeroWord;
        end
        else if (csr_rd_addr == `CSR0) begin
            csr_rd_data = `ZeroWord;
        end
        else begin
            if ((csr_rd_addr == csr_wr_addr) && (csr_wr_en == `WriteEnable)) begin
                csr_rd_data = csr_wr_data;
            end else begin
                case (csr_rd_addr)
                    `CSR_EPC:       csr_rd_data <= epc;
                    `CSR_CAUSE:     csr_rd_data <= cause;
                    `CSR_MIE:       csr_rd_data <= mie;
                    `CSR_MIP:       csr_rd_data <= mip;
                    `CSR_MTVAL:     csr_rd_data <= mtval;
                    `CSR_MSCRATCH:  csr_rd_data <= mscratch;
                    `CSR_MSTATUS:   csr_rd_data <= mstatus;
                    `CSR_MTVEC:     csr_rd_data <= mtvec; 
                    default: begin
                    end
                endcase
            end
        end
    end
endmodule
