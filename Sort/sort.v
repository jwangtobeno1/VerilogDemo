`timescale 1ns/1ps

module sort#(parameter
    LEN     =   16,
    WIDTH   =   8
)(
    input                   clk ,
    input                   rst_n,
    input   [WIDTH-1:0]     din,
    input                   din_vld,
    output  [WIDTH-1:0]     dout,
    output                  dout_vld 
);

localparam  SCORE_WIDTH = $clog2(LEN);

reg [SCORE_WIDTH-1:0]   data_cnt;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_cnt <= 'd0;
    else if(din_vld && data_cnt == LEN-1)
        data_cnt <= 'd0;
    else if(din_vld)
        data_cnt <= data_cnt + 1'b1;
end

reg [(SCORE_WIDTH)+(WIDTH-1):0] data_mem    [LEN-1:0];
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        for(integer i = 0; i < LEN; i = i+1)
            data_mem[i] = {WIDTH{1'b0}};
    else if(din_vld)
        data_mem[data_cnt] <= din_vld;
end

reg     rec_done;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        rec_done <= 1'b0;
    else if(din_vld && data_cnt == LEN-1)
        rec_done <= 1'b1;
    else
        rec_done <= 1'b0;
end

function [SCORE_WIDTH-1:0] all_compare;
    input   [(LEN-1)*WIDTH-1:0] data;
    input   [WIDTH-1:0] compare;
    reg [LEN-1:0]   score;
    begin
        generate
            for(integer i = 0; i < LEN; i = i+1) begin :compare
                score[i] = compare > data[(LEN-1-i)*WIDTH-1 -: WIDTH] ? 1'b0 : 1'b1;
                all_compare = all_compare + socre[i];
            end
        endgenerate   
    end
endfunction

always @(*) begin
    if (rec_done) begin
        data_mem[SCORE_WIDTH+WIDTH-1 -: SCORE_WIDTH-1] = 
                all_compare(,)
    end
end 

endmodule
