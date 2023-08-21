// 利用计数器的方法分频

`timescale 1ns/1ps

module freq_even_div#(parameter
    N   =   10
)(
    input           clk,
    input           rst_n,
    output  reg     div_res
);

localparam  CNT_WIDTH = $clog2(N);

reg [CNT_WIDTH-1:0] cnt;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 'd0;
    else if(cnt == N-1)
        cnt <= 'd0;
    else
        cnt <= cnt + 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        div_res <= 1'b0;
    else if(cnt == N/2-1 || cnt == N-1)
        div_res <= ~div_res;
end

endmodule
