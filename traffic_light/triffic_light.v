`timescale 1ns/1ns

module triffic_light #(parameter
    RED_CNT     =   10,
    YELLOW_CNT  =   5,
    GREEN_CNT   =   60
)(
    input rst_n, //异位复位信号，低电平有效
    input clk, //时钟信号
    input pass_request,
    output wire[7:0]clock,
    output reg red,
    output reg yellow,
    output reg green
);

localparam  RED     =   3'b001,
            YELLOW  =   3'b010,
            GREEN   =   3'b100;

reg [2:0]   cstate;
reg [2:0]   nstate;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cstate <= RED;
    else
        cstate <= nstate;
end

always @(*) begin

    case(cstate)
    RED:
        if(cnt_red == 1)
            nstate = YELLOW;
        else
            nstate = RED;
    YELLOW:
        if(cnt_yellow == 1)
            nstate = GREEN;
        else
            nstate = YELLOW;
    GREEN:
        if(cnt_green == 1)
            nstate = RED;
        else
            nstate = GREEN;
    default: nstate = nstate;
    endcase
end

reg [3:0] cnt_red;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_red <= RED_CNT;
    else if(cstate == RED)
        cnt_red <= cnt_red - 1'b1;
    else
        cnt_red <= 'd0;
end

reg [2:0] cnt_yellow;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_yellow <= YELLOW_CNT;
    else if(cstate == YELLOW)
        cnt_yellow <= cnt_yellow - 1'b1;
    else
        cnt_yellow <= 'd0;
end

reg [5:0] cnt_green;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_green <= GREEN_CNT;
    else if(cstate == GREEN && pass_request && cnt_green > 10)
        cnt_green <= 10;
    else if(cstate == GREEN)
        cnt_green <= cnt_green - 1'b1;
    else
        cnt_green <= 'd0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        red <= 1'b0;
    else if(cstate == RED)
        red <= 1'b1;
    else
        red <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        yellow <= 1'b0;
    else if(cstate == YELLOW)
        yellow <= 1'b1;
    else
        yellow <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        green <= 1'b0;
    else if(cstate == GREEN)
        green <= 1'b1;
    else
        green <= 1'b0;
end

assign clock =  (cstate == RED) ? {4'd0, cnt_red} : 
                (cstate == YELLOW) ? {5'd0, cnt_yellow} :
                (cstate == GREEN) ? {2'd0, cnt_green} :
                'd0;

endmodule
