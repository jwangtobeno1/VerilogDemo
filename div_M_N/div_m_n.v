`timescale 1ns/1ns

module div_m_n #(parameter 
    M_N = 8'd87, 
    c89 = 8'd24, 
    div_e = 5'd8,
    div_o = 5'd9
)(
    input  wire clk,
    input  wire rst_n,
    output wire clk_out
);

localparam CNT_WIDTH = $clog2(M_N);
localparam CNT2_WIDTH = $clog2(c89);

reg [CNT_WIDTH-1:0]     cnt_clk;
reg [CNT2_WIDTH-1:0]    cnt_div;
reg                     div_flag;

/* verilator lint_off WIDTHEXPAND */

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_clk <= 'd0;
    else if(cnt_clk == M_N-1)
        cnt_clk <= 'd0;
    else
        cnt_clk <= cnt_clk + 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_div <= 'd0;
    else if(~div_flag) begin
        if(cnt_div == div_e-1)
            cnt_div <= 'd0;
        else
            cnt_div <= cnt_div + 1'b1;
    end
    else begin
        if(cnt_div == div_o-1)
            cnt_div <= 'd0;
        else
            cnt_div <= cnt_div + 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        div_flag <= 1'b0;
    else if(cnt_clk == (M_N-1) || cnt_clk == (c89-1))
        div_flag <= ~div_flag;
    else
        div_flag <= div_flag;
end

reg clk_out_r;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        clk_out_r <= 'd0;
    else if(~div_flag) 
        clk_out_r <= (cnt_div <= (div_e>>2)+1);
    else
        clk_out_r <= (cnt_div <= (div_o>>2)+1);
end

assign clk_out = clk_out_r;

endmodule
