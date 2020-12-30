`include "define.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/28 09:40:14
// Design Name: 
// Module Name: cache
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: full-associated cache: 8 lines with 256b-size line
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cache(
    input clk, rst,

    //read
    input [`DataAddrBus] cache_rd_wr_addr,
    input cache_rd_en,
    output reg [`CacheBlock] cache_rd_data,
    output reg miss,
    //write
    input cache_wr_en,
    input [`CacheBlock] cache_wr_data,
    input [`SmallMemNumlog2-1:0] cache_wr_sel,
    //cache_mem interface
    input [`CacheLine] update_data,
    input update_en
    
    );

    reg [`CacheLineWithTag] cache[0:`CacheLineNum-1];

    //read
    integer i;
    always @(*) begin
        miss = `Miss;
        for (i = 0; i < `CacheLineNum; i = i + 1)begin
            //hit
            if (cache[i][`CacheTag] == cache_rd_wr_addr[`Tag])begin
                miss = `NotMiss;
                //read
                if (cache_rd_en == `ReadEnable) begin
                    case (cache_rd_wr_addr[`BlockAddr])
                    3'h0: cache_rd_data = cache[i][31:0]; 
                    3'h1: cache_rd_data = cache[i][63:32];
                    3'h2: cache_rd_data = cache[i][95:64];
                    3'h3: cache_rd_data = cache[i][127:96];
                    3'h4: cache_rd_data = cache[i][159:128];
                    3'h5: cache_rd_data = cache[i][191:160];
                    3'h6: cache_rd_data = cache[i][223:192];
                    3'h7: cache_rd_data = cache[i][255:224];
                    default: cache_rd_data = `ZeroWord;
                    endcase
                end else begin
                    cache_rd_data = `ZeroWord;
                end
            end
        end
    end

    //write
    integer j;
    always @(posedge clk) begin
        miss = `Miss;
        for (j = 0; j < `CacheLineNum; j = j + 1)begin
            //hit
            if (cache[j][`CacheTag] == cache_rd_wr_addr[`Tag])begin
                miss = `NotMiss;
                //write
                if (cache_wr_en == `WriteEnable) begin
                    case (cache_rd_wr_addr[`BlockAddr])
                    3'h0: begin
                        case (cache_wr_sel)
                        `byte_sel:begin
                            cache[j][7:0] = cache_wr_data[7:0];  
                        end
                        `half_word_sel:begin
                            cache[j][15:0] = cache_wr_data[15:0];  
                        end
                        `word_sel:begin
                            cache[j][31:0] = cache_wr_data; 
                        end
                        default:begin end
                        endcase
                    end
                    3'h1: begin
                        case (cache_wr_sel)
                        `byte_sel:begin
                            cache[j][39:32] = cache_wr_data[7:0];  
                        end
                        `half_word_sel:begin
                            cache[j][47:32] = cache_wr_data[15:0];  
                        end
                        `word_sel:begin
                            cache[j][63:32] = cache_wr_data;
                        end
                        default:begin end
                        endcase
                    end
                    3'h2:  begin
                        case (cache_wr_sel)
                        `byte_sel:begin
                            cache[j][71:64] = cache_wr_data[7:0];  
                        end
                        `half_word_sel:begin
                            cache[j][79:64] = cache_wr_data[15:0];  
                        end
                        `word_sel:begin
                            cache[j][95:64] = cache_wr_data;
                        end
                        default:begin end
                        endcase
                    end
                    3'h3:  begin
                        case (cache_wr_sel)
                        `byte_sel:begin
                            cache[j][103:96] = cache_wr_data[7:0];  
                        end
                        `half_word_sel:begin
                            cache[j][111:96] = cache_wr_data[15:0];  
                        end
                        `word_sel:begin
                            cache[j][127:96] = cache_wr_data;
                        end
                        default:begin end
                        endcase
                    end
                    3'h4:  begin
                        case (cache_wr_sel)
                        `byte_sel:begin
                            cache[j][135:128] = cache_wr_data[7:0];  
                        end
                        `half_word_sel:begin
                            cache[j][143:128] = cache_wr_data[15:0];  
                        end
                        `word_sel:begin
                            cache[j][159:128] = cache_wr_data;
                        end
                        default:begin end
                        endcase
                    end
                    3'h5:  begin
                        case (cache_wr_sel)
                        `byte_sel:begin
                            cache[j][167:160] = cache_wr_data[7:0];  
                        end
                        `half_word_sel:begin
                            cache[j][175:160] = cache_wr_data[15:0];  
                        end
                        `word_sel:begin
                            cache[j][191:160] = cache_wr_data;
                        end
                        default:begin end
                        endcase
                    end
                    3'h6:  begin
                        case (cache_wr_sel)
                        `byte_sel:begin
                            cache[j][199:192] = cache_wr_data[7:0];  
                        end
                        `half_word_sel:begin
                            cache[j][207:192] = cache_wr_data[15:0];  
                        end
                        `word_sel:begin
                            cache[j][223:192] = cache_wr_data;
                        end
                        default:begin end
                        endcase
                    end
                    3'h7:  begin
                        case (cache_wr_sel)
                        `byte_sel:begin
                            cache[j][231:224] = cache_wr_data[7:0];  
                        end
                        `half_word_sel:begin
                            cache[j][239:224] = cache_wr_data[15:0];  
                        end
                        `word_sel:begin
                            cache[j][255:224] = cache_wr_data;
                        end
                        default:begin end
                        endcase
                    end
                    default: cache[j] = 283'b0;
                    endcase
                end
            end
        end
    end

    reg [`CacheLineNumLog2] update_addr;
    //update cache: change update_addr in order
    always @(posedge update_en or negedge rst) begin
        if (update_en == `NotUpdate) begin
            update_addr = `CacheLine0;
        end else begin
            update_addr = update_addr + 1'b1;
        end
    end

    always @(posedge clk) begin
        if (update_en == `Update) begin
            cache[update_addr] = {cache_rd_wr_addr[`Tag], update_data};
        end
    end
endmodule
