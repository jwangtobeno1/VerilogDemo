module clock_4times(
    input       clk,
    input       rst_n,
    output      clk_out
);
    
wire    clock_out1;

reg     q_r1;
always @(posedge clock_out1 or negedge rst_n) begin
    if(!rst_n)
        q_r1 <= 1'b0;
    else
        q_r1 <= ~q_r1;
end

assign clock_out1 = ~(clk ^ q_r1);

reg     q_r2;
always @(posedge clk_out or negedge rst_n) begin
    if(!rst_n)
        q_r2 <= 1'b0;
    else
        q_r2 <= ~q_r2;
end

assign clk_out = ~(clock_out1 ^ q_r2);

endmodule
