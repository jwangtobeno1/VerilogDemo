`timescale 1ns/1ps

module count(
    input       clk ,
    input       rst_n,
    output reg [4:0] cnt
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 'd0;
    else
        cnt <= cnt + 1'b1;
end

endmodule
