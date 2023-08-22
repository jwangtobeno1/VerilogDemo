module handshake #(
    parameter DATA_WIDTH = 8
)(
    input                           clkx,
    input                           rst_nx,
    input                           clky,
    input                           rst_ny,

    input   [DATA_WIDTH-1:0]        din,
    input                           din_vld,
    output  reg [DATA_WIDTH-1:0]    dout,
    output  reg                     dout_vld
);

// 假设两个din_vld脉冲间隔大于5个clkx周期

(*async_reg = "true"*)reg     din_vld_reg1;
reg     din_vld_reg2;
always @(posedge clky or negedge rst_ny) begin
    if(!rst_ny) begin
        din_vld_reg1 <= 1'b0;
        din_vld_reg2 <= 1'b0;
    end else begin
        din_vld_reg1 <= din_vld;
        din_vld_reg2 <= din_vld_reg1;
    end
end

always @(posedge clky or negedge rst_ny) begin
    if(!rst_ny) begin
        dout <= 'd0;
        dout_vld <= 1'b0;
    end else if(din_vld_reg2) begin
        dout <= din;
        dout_vld <= 1'b1;
    end else begin
        dout <= dout;
        dout_vld <= 1'b0;
    end
end

(*async_reg = "true"*) reg  dout_vld_reg1;
reg     dout_vld_reg2;
always @(posedge clkx or negedge rst_nx) begin
    if(!rst_nx) begin
        dout_vld_reg1 <= 1'b0;
        dout_vld_reg2 <= 1'b0;
    end else begin
        dout_vld_reg1 <= dout_vld;
        dout_vld_reg2 <= dout_vld_reg1;
    end
end

endmodule
