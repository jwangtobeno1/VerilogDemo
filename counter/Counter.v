module Counter(
    input       clk,
    input       rst_n,
    input       cntEn,
    output  [63:0]  cnt
);

reg     [15:0]      cnt1;
reg     [15:0]      cnt2;
reg     [15:0]      cnt3;
reg     [15:0]      cnt4;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt1 <= 'd0;
    else if(cntEn)
        cnt1 <= cnt1 + 1'b1;
    else
        cnt1 <= cnt1;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt2 <= 'd0;
    else if(&cnt1)
        cnt2 <= cnt2 + 1'b1;
    else
        cnt2 <= cnt2;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt3 <= 'd0;
    else if(&cnt2)
        cnt3 <= cnt3 + 1'b1;
    else
        cnt3 <= cnt3;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt4 <= 'd0;
    else if(&cnt3)
        cnt4 <= cnt4 + 1'b1;
    else
        cnt4 <= cnt4;
end

assign cnt = {cnt4,cnt3,cnt2,cnt1};

endmodule
