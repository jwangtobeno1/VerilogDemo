module pulse_count(
    input               clk,
    input               rst_n,
    input               pulse,
    output  reg [3:0]   count
);

reg     toggle;
always @(posedge pulse or negedge rst_n) begin
    if(!rst_n)
        toggle <= 1'b0;
    else
        toggle <= ~toggle;
end

reg     toggle_d1;
reg     toggle_d2;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        toggle_d1 <= 1'b0;
        toggle_d2 <= 1'b0;
    end else begin
        toggle_d1 <= toggle;
        toggle_d2 <= toggle_d1;
    end
end

wire    pulse_sync;
assign pulse_sync = toggle_d1 ^ toggle_d2;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        count <= 'd0;
    else if(pulse_sync)
        count <= count + 1'b1;
    else
        count <= count;
end

endmodule
