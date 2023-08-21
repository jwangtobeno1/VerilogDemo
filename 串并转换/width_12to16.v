module width_12to16(
    input           clk,
    input           rst_n,
    input   [11:0]  din,
    input           din_vld,
    input           din_vld_last,

    output  reg [15:0]  dout,
    output  reg         dout_vld
    //output  reg         dout_vld_last
);

reg [11:0]  din_reg;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        din_reg <= 'd0;
    else if(din_vld)
        din_reg <= din;
    else    
        din_reg <= din_reg;
end

reg [1:0]   din_vld_cnt;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        din_vld_cnt <= 'd0;
    else if(din_vld)
        din_vld_cnt <= din_vld_cnt + 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        dout <= 'd0;
    else if(din_vld) begin
        case(din_vld_cnt)
            2'b01: dout <= {din[3:0],din_reg};
            2'b10: dout <= {din[7:0],din_reg[11:4]};
            2'b11: dout <= {din,din_reg[11:8]};
            default: dout <= dout;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        dout_vld <= 'd0;
    else if(din_vld && ((din_vld_cnt == 'd1) || (din_vld_cnt == 'd2) || (din_vld_cnt == 'd3)))
        dout_vld <= 1'b1;
    else
        dout_vld <= 1'b0;
end

endmodule
