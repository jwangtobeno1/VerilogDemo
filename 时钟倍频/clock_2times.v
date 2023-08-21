`timescale 1ns/1ns

module clock_2times(
    input     wire clk ,
    input     wire rst_n,

    output    wire clk_out
);

reg q_r = 1'b0;
always @(posedge clk_out or negedge rst_n) begin
	if(!rst_n) 
		q_r <= 0;
	else
		q_r <= ~q_r;
end

// 同或门 实现
assign clk_out = ~(clk ^ q_r);

endmodule
