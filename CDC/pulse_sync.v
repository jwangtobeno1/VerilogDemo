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

(*async_reg = "true"*)reg [2:0] toggle_sync;

always @(posedge clkb or negedge rst_n) begin
    if(!rst_n) begin
        toggle_sync[0] <= 1'b0;
        toggle_sync[1] <= 1'b0;
        toggle_sync[2] <= 1'b0;
    end else begin
        toggle_sync[0] <= toggle;
        toggle_sync[1] <= toggle_sync[0];
        toggle_sync[2] <= toggle_sync[1];
    end
end

always @(posedge clkb or negedge rst_n) begin
    if(!rst_n)
        dout <= 1'b0;
    else
        dout <= toggle_sync[2] ^ toggle_sync[1]; 
end



endmodule
