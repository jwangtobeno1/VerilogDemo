`timescale 1ns/1ns

module seller2(
	input wire clk  ,
	input wire rst  ,
	input wire d1 ,
	input wire d2 ,
	input wire sel ,
	
	output reg out1,
	output reg out2,
	output reg out3
);
//*************code***********//

localparam  IDLE	=	7'b000_0001,
			S05     =   7'b000_0010,
            S10     =   7'b000_0100,
            S15     =   7'b000_1000,
            S20     =   7'b001_0000,
            S25     =   7'b010_0000,
            S30     =   7'b100_0000;

reg     [6:0]   cstate;
reg     [6:0]   nstate;

always @(posedge clk or negedge rst) begin
    if(!rst)
        cstate <= IDLE;
    else
        cstate <= nstate;
end

always @(*) begin
    nstate <= nstate;
    case(cstate)
        IDLE:   
            if(d1)
                nstate <= S05;
            else if(d2)
                nstate <= S10;
        S05:
            if(d1)
                nstate <= S10;
            else if(d2)
                nstate <= S15;
        S10:
            if(d1)
                nstate <= S15;
            else if(d2)
                nstate <= S20;
        S15:
            if(sel == 1'b0) begin
                    nstate <= IDLE;
            end else begin
                if(d1)
                    nstate <= S20;
                else if(d2)
                    nstate <= S25;
            end
            
        S20:
            if(sel == 1'b0) begin
                    nstate <= IDLE;
            end else begin
                if(d1)
                    nstate <= S25;
                else if(d2)
                    nstate <= S30;
            end
        S25:
            nstate <= IDLE;
        S30:
            nstate <= IDLE;
        default : nstate <= IDLE;
    endcase
end

// out1 饮料1输出逻辑
always @(posedge clk or negedge rst) begin
    if(!rst)
        out1 <= 1'b0;
    else if(sel == 1'b0) begin
        if(nstate == S15 || nstate == S20)
            out1 <= 1'b1;
        else
            out1 <= 1'b0;
    end else
        out1 <= 1'b0;
end

// out2 饮料2输出逻辑
always @(posedge clk or negedge rst) begin
    if(!rst)
        out2 <= 1'b0;
    else if(sel == 1'b1) begin
        if(nstate == S25 || nstate == S30)
            out2 <= 1'b1;
        else
            out2 <= 1'b0;
    end else
        out2 <= 1'b0;
end

// out3 找零逻辑
always @(posedge clk or negedge rst) begin
    if(!rst)
        out3 <= 1'b0;
    else begin
        out3 <= 1'b0;
        case(sel)
            1'b0:
                if(nstate == S20) out3 <= 1'b1;
            1'b1:
                if(nstate == S30) out3 <= 1'b1;
            default:
                out3 <= 1'b0;
        endcase
    end 
end

endmodule