module wide2narrow(
    input               clk,
    input               rst_n,
    input   [7:0]       wide_din,

    output  [3:0]       narrow_dout
);

reg     flag;   // 其实是clk的二分频
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        flag <= 1'b0;
    else
        flag <= ~flag;
end

reg     [7:0]   wide_din_sync;
always @(posedge flag or negedge rst_n) begin
    if(!rst_n)
        wide_din_sync <= 'd0;
    else
        wide_din_sync <= wide_din;
end

assign narrow_dout = flag ? wide_din_sync[7:4] : wide_din_sync[3:0];


endmodule
