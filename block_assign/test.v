`timescale 1ns/1ps
module test(
    input clk
);

reg [1:0]   a;
reg [1:0]   b;
reg [1:0]   c;
reg [1:0]   d;
reg [1:0]   e;
reg [1:0]   f;

/* verilator lint_off INITIALDLY */
initial begin
    a <= 2;
    b <= 1;
    c <= 3;
    d <= 0;
    e <= 0;
    f <= 0;
end

always @(posedge clk) begin
    d <= a;
    e = f;
    f <= c;
end

endmodule