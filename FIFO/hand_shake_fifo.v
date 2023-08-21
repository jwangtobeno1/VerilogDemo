//多级流水设计中，每一级都只有一个寄存器，并且都在一个模块，也就是颗粒度划分很细，
//一般使用带存储体的反压，设计好流水线，FIFO没有满的时候提前发出反压信号，一般水线=FIFO_DEPTH - 流水级数
//核心思想 fifo未达到水线时候给上一级的ready_o信号持续拉高，否则为低；fifo非空，就给下一级valid_o拉高，
//下一级的反压信号ready_i还可以作为FIFO读使能信号
//https://zhuanlan.zhihu.com/p/359330607
module hand_shake_fifo#(
	parameter	FIFO_DATA_WIDTH = 32,
	parameter	FIFO_DEPTH = 8
)(
	input 			clk,
	input			rst,
	input			valid_i,
	input			ready_i,
	input [31:0]	a,
	input [31:0]	b,
	input [31:0]	c,
	input [31:0]	d,
	input [31:0]	e,
	input [31:0]	f,
	
	output 	[31:0]	dout,
	output			ready_o,
	output			valid_o
);

localparam	WATERLINE	 = FIFO_DEPTH - 3; // 3为3级流水

wire handshake;
reg	handshake_ff1;
reg handshake_ff2;
reg wr_en;

assign handshake = ready_o & valid_i;

always@(posedge clk or negedge rst)begin
	if(rst)begin
		handshake_ff1	<= 'd0;
		handshake_ff2	<= 'd0;
	end
	else begin
		handshake_ff1	<= handshake;
		handshake_ff2	<= handshake_ff1;
	end
end

reg [31:0]	r1_ab;
always@(posedge clk or negedge rst)begin
	if(rst)
		r1_ab <= 'd0;
	else if(handshake)
		r1_ab <= a+b;
end

reg [31:0]	r1_cd;
always@(posedge clk or negedge rst)begin
	if(rst)
		r1_cd <= 'd0;
	else if(handshake)
		r1_cd <= c+d;
end

reg [31:0]	r1_ef;
always@(posedge clk or negedge rst)begin
	if(rst)
		r1_ef <= 'd0;
	else if(handshake)
		r1_ef <= e+f;
end

reg [31:0]	r2_abcd;
always@(posedge clk or negedge rst)begin
	if(rst)
		r2_abcd <= 'd0;
	else if(handshake_ff1)
		r2_abcd <= r1_ab+r1_cd;
end

reg [31:0]	r2_ef;
always@(posedge clk or negedge rst)begin
	if(rst)
		r2_ef <= 'd0;
	else if(handshake_ff1)
		r2_ef <= e+f;
end

reg [31:0]	r3;
always@(posedge clk or negedge rst)begin
	if(rst)
		r3 <= 'd0;
	else if(handshake_ff2)
		r3 <= r2_abcd + r2_ef;
end


always@(posedge clk or negedge rst)begin
	if(rst)
		wr_en <= 1'b0;
	else if(handshake_ff2)
		wr_en <= 1'b1;
	else
		wr_en <= 1'b0;
end

always@(posedge clk or negedge rst)begin
	if(rst)begin
		ready_o <= 1'b0;
	end
	else if(usedw > WATERLINE)
		ready_o <= 1'b0;
	else
		ready_o <= 1'b1;
end

assign valid_o = ~empty;

sync_fifo # (
        .MEM_TYPE   ("auto"         ),
        .READ_MODE  ("fwft"         ),
        .WIDTH      (FIFO_DATA_WIDTH),
        .DEPTH      (FIFO_DEPTH     )
    )fifo_inst(
        .clk    (clk                ), // input  wire
        .rst_n  (rst_n              ), // input  wire
        .wren   (wr_en              ), // input  wire
        .din    (r3                 ), // input  wire [WIDTH-1:0]
        .rden   (ready_i            ), // input  wire
        .dout   (dout               ), // output reg  [WIDTH-1:0]
        .empty  (empty              ), // output wire
        .usedw  (usedw              )
    );
endmodule