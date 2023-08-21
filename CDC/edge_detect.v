`timescale 1ns/1ps

// 边沿检测，慢时钟域信号同步到快时钟域

module edge_detect(
    input               clka,
    input               din,
    input               clkb,
    output  reg         dout
);

reg din_d1;
reg din_d2;
reg din_d3;

always @(posedge clkb) begin
    din_d1 <= din;
    din_d2 <= din_d1;
    din_d3 <= din_d2;
end

always @(posedge clkb) begin
    dout <= din_d2 & din_d3;
end

endmodule
