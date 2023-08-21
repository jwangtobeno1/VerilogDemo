`timescale 1ns/1ps

module clk_sw(
    input           clka,
    input           clkb,
    input           rst_n,
    input           sel,
    output          clk_out
);

reg     clka_out;
always @(negedge clka or negedge rst_n) begin
    if(!rst_n)
        clka_out <= 1'b0;
    else
        clka_out <= (~clkb_out) && sel;
end

reg     clkb_out;
always @(negedge clkb or negedge rst_n) begin
    if(!rst_n)
        clkb_out <= 1'b0;
    else
        clkb_out <= (~clka_out) && (~sel);
end

assign clk_out = (clka & clka_out) | (clkb & clkb_out);

endmodule
