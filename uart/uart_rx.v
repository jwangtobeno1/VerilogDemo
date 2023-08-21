`timescale 1ns/1ns

module uart_rx#(parameter
    CLK = 100_000_000,
    BPS = 9600
)(
    input               clk ,
    input               rst_n,
    input               rx,
    output  reg [7:0]   rx_data,
    output  reg         rx_flag
);

localparam BAUD_CNT_MAX = CLK / BPS;
localparam BAUD_CNT_WIDTH = $clog2(BAUD_CNT_MAX); // baud计数器位宽

reg     rx_d1;
reg     rx_d2;
reg     rx_d3;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        rx_d1 <= 1'b1;
        rx_d2 <= 1'b1;
        rx_d3 <= 1'b1;
    end else begin
        rx_d1 <= rx;
        rx_d2 <= rx_d1;
        rx_d3 <= rx_d2;
    end
end

reg     start;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        start <= 1'b0;
    else if((!rx_d2) & rx_d3)
        start <= 1'b1;
    else
        start <= 1'b0;
end

reg     work_en;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        work_en <= 1'b0;
    else if(start)
        work_en <= 1'b1;
    else if(bit_flag && bit_cnt == 4'd8)
        work_en <= 1'b0;
    
end

reg     [BAUD_CNT_WIDTH-1:0]    baud_cnt;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        baud_cnt <= 'd0;
    else if(baud_cnt == BAUD_CNT_MAX-1 || work_en == 1'b0)
        baud_cnt <= 'd0;
    else if(work_en)
        baud_cnt <= baud_cnt + 1'b1;
    else
        baud_cnt <= 'd0;
end

reg     bit_flag;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        bit_flag <= 1'b0;
    else if(baud_cnt == BAUD_CNT_MAX/2-1)
        bit_flag <= 1'b1;
    else
        bit_flag <= 1'b0;
end

reg     [3:0]   bit_cnt;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        bit_cnt <= 'd0;
    else if(bit_cnt == 4'd8 && bit_flag)
        bit_cnt <= 'd0;
    else if(bit_flag)
        bit_cnt <= bit_cnt + 1'b1;
    else
        bit_cnt <= bit_cnt;
end

reg     [7:0]   po_data;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        po_data <= 'd0;
    else if((bit_cnt >= 4'd1)&&(bit_cnt <= 4'd8) && bit_flag)
        po_data <= {rx_d3, po_data[7:1]};
    else
        po_data <= po_data;
end

reg     po_flag;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        po_flag <= 1'b0;
    else if(bit_cnt == 4'd8 && bit_flag)
        po_flag <= 1'b1;
    else 
        po_flag <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rx_data <= 'd0;
    else if(po_flag)
        rx_data <= po_data;
    else
        rx_data <= rx_data;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rx_flag <= 1'b0;
    else
        rx_flag <= po_flag;
end

endmodule
