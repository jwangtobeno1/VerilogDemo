module s_to_p #(parameter 
    N = 48
)(
    input           clk ,
    input           rst_n,
    input           valid_a,
    input           data_a,
    output  reg         ready_a,
    output  reg         valid_b,
    output  reg [N-1:0] data_b
);

reg     [N-1 : 0]   data_reg;

/* verilator lint_off WIDTHEXPAND */
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data_reg <= 'd0;
    else if(valid_a)
        data_reg <= {data_a, data_reg[N-1 : 1]};
    else
        data_reg <= data_reg;
end

localparam WIDTH_CNT = $clog2(N);
reg     [WIDTH_CNT-1:0] cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt <= 'd0;
    else if(valid_a && cnt == (N-1))
        cnt <= 'd0;
    else if(valid_a)
        cnt <= cnt + 1'b1;
    else
        cnt <= cnt;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        valid_b <= 1'b0;
        data_b <= 'd0;
    end else if(valid_a && cnt == (N-1)) begin
        valid_b <= 1'b1;
        data_b <= {data_a, data_reg[N-1 : 1]};
    end else begin
        valid_b <= 1'b0;
        data_b <= data_b;
    end
end

endmodule
