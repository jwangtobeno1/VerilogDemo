`timescale 1ns/1ns

module JC_counter(
   input                clk ,
   input                rst_n,
 
   output reg [3:0]     Q  
);

reg [2:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 'd0;
    else
        cnt <= cnt + 1'b1;
end

reg [7:0]   data_reg;

always @(posedge clk or negedge rst_n)   begin
    if(!rst_n)
        data_reg <= 'hf0;
    else if(cnt == 'd7)
        data_reg <= 'hf0;
    else
        data_reg <= {1'b0,data_reg[7:1]};
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        Q <= 'd0;
    else
        Q <= data_reg[3:0];
end

endmodule
