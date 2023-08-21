`timescale 1ns/1ns

module uart_tx#(parameter
    CLK     =   'd100_000_100,
    BPS     =   'd9600
)(
    input               clk ,
    input               rst_n,
    input   [7:0]       pi_data,
    input               pi_flag,
    output  reg         tx
);

/* verilator lint_off WIDTHEXPAND */

localparam BAUD_CNT_MAX = CLK / BPS;
localparam BAUD_CNT_WIDTH = $clog2(BAUD_CNT_MAX);

reg     [7:0]   tx_data;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tx_data <= 'd0;
    else if(pi_flag)
        tx_data <= pi_data;
    else
        tx_data <= tx_data;
end

reg     work_en /*verilator public_flat_rw*/; 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        work_en <= 1'b0;
    else if(pi_flag)
        work_en <= 1'b1;
    else if(bit_cnt == 'd9 && bit_flag)
        work_en <= 1'b0;
end

reg     [BAUD_CNT_WIDTH:0]  baud_cnt;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        baud_cnt <= 'd0;
    else if(baud_cnt == BAUD_CNT_MAX-1 && work_en)
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
    else if(baud_cnt == 'd1)
        bit_flag <= 1'b1;
    else
        bit_flag <= 1'b0;
end

reg     [3:0]   bit_cnt;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        bit_cnt <= 'd0;
    else if(bit_flag && bit_cnt == 'd9)
        bit_cnt <= 'd0;
    else if(bit_flag)
        bit_cnt <= bit_cnt + 1'b1;
    else
        bit_cnt <= bit_cnt;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tx <= 1'b1;
    else if(bit_flag)
        case(bit_cnt)
            0 : tx <= 1'b0;
            1 : tx <= tx_data[0];
            2 : tx <= tx_data[1];
            3 : tx <= tx_data[2];
            4 : tx <= tx_data[3];
            5 : tx <= tx_data[4];
            6 : tx <= tx_data[5];
            7 : tx <= tx_data[6];
            8 : tx <= tx_data[7];
            9 : tx <= 1'b1;
            default : tx <= 1'b1;
        endcase
end

endmodule
