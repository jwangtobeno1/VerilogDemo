`timescale 1ns/1ns

module width_8to12(
	input 				  clk 		,   
	input 			      rst_n		,
	input				  valid_in	,
	input	[7:0]	      data_in	,

    output  reg			 valid_out,
    output  reg [11:0]   data_out
);

reg         work_en;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        work_en <= 1'b0;
    else if(valid_in)
        work_en <= 1'b1;
end

reg         valid_flag;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        valid_flag <= 1'b0;
    else if(work_en && valid_in)
        valid_flag <= ~valid_flag;
    else
        valid_flag <= valid_flag;
end

reg     [15:0]  data_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_reg <= 24'd0;
    else if(valid_in)
        data_reg <= {data_reg[16:0],data_in};
    else
        data_reg <= data_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_out <= 'd0;
    else if(valid_in && valid_flag)
        data_out <= data_reg[15:4];
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        valid_out <= 'd0;
    else if(valid_in && valid_flag)
        valid_out <= 1'b1;
    else
        valid_out <= 1'b0;
end

endmodule