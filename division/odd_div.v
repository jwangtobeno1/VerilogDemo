`timescale 1ns/1ns

module odd_div #(parameter
    N = 7
)(
    input    wire  rst ,
    input    wire  clk_in,
    output   wire  clk_out
);

localparam WIDTH = $clog2(N);

reg   clkp;
reg   clkn;

reg [WIDTH-1 : 0] cnt;

/* verilator lint_off WIDTHEXPAND */
always @(posedge clk_in or negedge rst) begin
    if(!rst)
        cnt <= 'd0;
    else if(cnt == N-1)
        cnt <= 'd0;
    else
        cnt <= cnt + 1'b1;
end


always @(posedge clk_in or negedge rst) begin
    if(!rst)
        clkp <= 'd0;
    else if(cnt == (N >> 1)) 
        clkp <= 1'b1;
    else if(cnt == N-1)
        clkp <= 1'b0;
end

always @(negedge clk_in or negedge rst) begin
    if(!rst)
        clkn <= 1'b0;
    else if(cnt == (N >> 1))
        clkn <= 1'b1;
    else if(cnt == N-1)
        clkn <= 1'b0;
end

assign clk_out = clkp | clkn;

endmodule