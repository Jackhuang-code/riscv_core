`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/11 08:31:15
// Design Name: 
// Module Name: mem_ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: memery ram
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mem_ram(
    input clk,

    input ce,
    input [`DataAddrBus] rd_addr,
    output reg [`CacheLine] rd_data,

    input [`DataAddrBus] wr_addr,
    input [`DataBus] wr_data,
    input [`SmallMemNumlog2-1:0] mem_wr_sel,
    input we

    );
    
    reg [`ByteWidth] ram0 [0:`DataMemNumberLog2-1];
    reg [`ByteWidth] ram1 [0:`DataMemNumberLog2-1];
    reg [`ByteWidth] ram2 [0:`DataMemNumberLog2-1];
    reg [`ByteWidth] ram3 [0:`DataMemNumberLog2-1];

    //write
    always @(posedge clk) begin
        if (we == `WriteEnable) begin
            case (mem_wr_sel)
                `byte_sel:begin
                    ram0[wr_addr >> 2] <= wr_data[7:0];
                end
                `half_word_sel:begin
                    ram0[wr_addr >> 2] <= wr_data[7:0];
                    ram1[wr_addr >> 2] <= wr_data[15:8];
                end
                `word_sel:begin
                    ram0[wr_addr >> 2] <= wr_data[7:0];
                    ram1[wr_addr >> 2] <= wr_data[15:8];
                    ram2[wr_addr >> 2] <= wr_data[23:16];
                    ram3[wr_addr >> 2] <= wr_data[31:24];
                end
                default:begin end
            endcase
        end
    end

    //read rd_data
    always @(*) begin
        if (ce == `ReadDisable) begin
            rd_data = {8{`ZeroWord}};
        end else begin
            rd_data = {ram3[(wr_addr >> 5) +7], ram2[(wr_addr >> 5) +7], ram1[(wr_addr >> 5) +7], ram0[(wr_addr >> 5) +7]
                ,ram3[(wr_addr >> 5) +6], ram2[(wr_addr >> 5) +6], ram1[(wr_addr >> 5) +6], ram0[(wr_addr >> 5) +6]
                ,ram3[(wr_addr >> 5) +5], ram2[(wr_addr >> 5) +5], ram1[(wr_addr >> 5) +5], ram0[(wr_addr >> 5) +5]
                ,ram3[(wr_addr >> 5) +4], ram2[(wr_addr >> 5) +4], ram1[(wr_addr >> 5) +4], ram0[(wr_addr >> 5) +4]
                ,ram3[(wr_addr >> 5) +3], ram2[(wr_addr >> 5) +3], ram1[(wr_addr >> 5) +3], ram0[(wr_addr >> 5) +3]
                ,ram3[(wr_addr >> 5) +2], ram2[(wr_addr >> 5) +2], ram1[(wr_addr >> 5) +2], ram0[(wr_addr >> 5) +2]
                ,ram3[(wr_addr >> 5) +1], ram2[(wr_addr >> 5) +1], ram1[(wr_addr >> 5) +1], ram0[(wr_addr >> 5) +1]
                ,ram3[(wr_addr >> 5)], ram2[(wr_addr >> 5)], ram1[(wr_addr >> 5)], ram0[(wr_addr >> 5)]};
        end
    end
    
endmodule
