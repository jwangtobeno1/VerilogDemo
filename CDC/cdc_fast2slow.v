module cdc_fast2slow(
    input               clka,
    input               pulse_i,

    input               clkb,
    output              pulse_o
);

reg     pulse_i_level   =   1'b0;
reg     pulse_a_d1      =   1'b0;
reg     pulse_a_d2      =   1'b0;

always @(posedge clka) begin
    if(pulse_i)
        pulse_i_level <= 1'b1;
    else if(pulse_a_d2)
        pulse_i_level <= 1'b0;
end

always @(posedge clka) begin
    pulse_a_d1 <= pulse_b_d2;
    pulse_a_d2 <= pulse_a_d1;
end

reg     pulse_b_d1      =   1'b0;
reg     pulse_b_d2      =   1'b0;
always @(posedge clkb) begin
    pulse_b_d1 <= pulse_i_level;
    pulse_b_d2 <= pulse_b_d1;
end

assign pulse_o = pulse_b_d1 & (~pulse_b_d2);

endmodule
