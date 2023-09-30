module shift_reg #(parameter 
    STAGE = 4,
    WIDTH = 8
)(
    input logic clk,
    input logic rst_n,
    input logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout
);

logic   [WIDTH-1:0] ffs [STAGE];

integer i;
always_ff @(posedge clk) begin
    ffs[0] <= in_data;
    for(i = 0; i < STAGE; i = i+1) begin
        ffs[i] <= ffs[i-1];
    end
end

assign dout = ffs[STAGE-1];

endmodule
