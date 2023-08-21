`timescale 1ns/1ps

module pulse_sync(
    input           clka,
    input           rst_n,
    input           din,
    input           clkb,
    output  reg     dout
);

reg toggle;
always @(posedge clka or negedge rst_n) begin
    if(!rst_n)
        toggle <= 1'b0;
    else if(din)
        toggle <= ~toggle;
    else
        toggle <= toggle;
end

reg toggle_sync1;
reg toggle_sync2;
reg toggle_sync3;
always @(posedge clkb or negedge rst_n) begin
    if(!rst_n) begin
        toggle_sync1 <= 1'b0;
        toggle_sync2 <= 1'b0;
        toggle_sync3 <= 1'b0;
    end else begin
        toggle_sync1 <= toggle;
        toggle_sync2 <= toggle_sync1;
        toggle_sync3 <= toggle_sync2;
    end
end

always @(posedge clkb or negedge rst_n) begin
    if(!rst_n)
        dout <= 1'b0;
    else
        dout <= toggle_sync3 ^ toggle_sync2; 
end



endmodule
