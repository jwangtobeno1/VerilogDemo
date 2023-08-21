`timescale 1ns/1ps
// 时钟切换模块
module clk_sw_ff(
    input           clka,
    input           clkb,
    input           rst_n,
    input           sel,
    output          clk_out
);

reg     clka_out;
always @(posedge clka or negedge rst_n) begin
    if(!rst_n)
        clka_out <= 1'b0;
    else
        clka_out <= (~clkb_out_r) & sel; // sel为1时，选择输出clka
end
reg     clka_out_r;
always @(negedge clka or negedge rst_n) begin
    if(!rst_n)
        clka_out_r <= 1'b0;
    else
        clka_out_r <= clka_out;
end

reg     clkb_out;
always @(posedge clkb or negedge rst_n) begin
    if(!rst_n)
        clkb_out <= 1'b0;
    else
        clkb_out <= (~clka_out_r) & (~sel); // sel为0时，选择输出clkb
end
reg     clkb_out_r;
always @(negedge clkb or negedge rst_n) begin
    if(!rst_n)
        clkb_out_r <= 1'b0;
    else
        clkb_out_r <= clkb_out;
end

assign clk_out = (clka & clka_out_r) | (clkb & clkb_out_r);

endmodule
