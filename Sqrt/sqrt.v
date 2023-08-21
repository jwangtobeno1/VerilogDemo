`timescale 1ns / 1ps

//
//  逐次逼近算法求一个数的平方根
//

module sqrt#(parameter
    DATA_WIDTH  =   8
)(
    input                           clk,
    input                           rst_n,
    input                           vld_i,
    input   [DATA_WIDTH-1:0]        data_i,

    output  reg                     vld_o,
    output  reg [DATA_WIDTH/2-1:0]  data_o,
    output  reg [DATA_WIDTH/2:0]    data_r // remainder 余数
);

localparam TMP_WIDTH = DATA_WIDTH/2-1;
localparam STAGE = DATA_WIDTH/2;

reg     [DATA_WIDTH-1:0]    data_reg    [STAGE:1];  // 存储被开方数
reg     [TMP_WIDTH:0]       data_tmp1   [STAGE:1];  // 存放临时数据
reg     [TMP_WIDTH:0]       data_tmp2   [STAGE:1];
reg                         vld_tmp     [STAGE:1];

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_reg[STAGE] <= 'd0;
        data_tmp1[STAGE] <= 'd0;
        data_tmp2[STAGE] <= 'd0;
        vld_tmp[STAGE]  <= 1'b0;
    end else if(vld_i) begin
        data_reg[STAGE] <= data_i;
        data_tmp1[STAGE] <= {1'b1,{TMP_WIDTH{1'b0}}};
        data_tmp2[STAGE] <= 'd0;
        vld_tmp[STAGE] <= 1'b1;
    end else begin
        data_reg[STAGE] <= 'd0;
        data_tmp1[STAGE] <= 'd0;
        data_tmp2[STAGE] <= 'd0;
        vld_tmp[STAGE] <= 1'b0;
    end
end

generate
    genvar i;
        for(i = TMP_WIDTH; i >= 1; i = i-1) begin : calc
            always @(posedge clk or negedge rst_n) begin
                if(!rst_n) begin
                    data_reg[i] <= 'd0;
                    data_tmp1[i] <= 'd0;
                    data_tmp2[i] <= 'd0;
                    vld_tmp[i]  <= 1'b0;
                end else if(vld_tmp[i+1]) begin
                    if(data_tmp1[i+1] * data_tmp1[i+1] > data_reg[i+1]) begin
                        data_tmp1[i] <= {data_tmp2[i+1][TMP_WIDTH:i],1'b1,{(i-1){1'b0}}};
                        data_tmp2[i] <= data_tmp2[i+1];
                    end else begin
                        data_tmp1[i] <= {data_tmp1[i+1][TMP_WIDTH:i],1'b1,{(i-1){1'b0}}};
                        data_tmp2[i] <= data_tmp1[i+1];
                    end
                    data_reg[i] <= data_reg[i+1];
                    vld_tmp[i] <= 1'b1;
                end else begin
                    data_reg[i] <= 'd0;
                    data_tmp1[i] <= 'd0;
                    data_tmp2[i] <= 'd0;
                    vld_tmp[i]  <= 1'b0;
                end
            end
        end
endgenerate

// 计算余数与最终平方根
/* verilator lint_off WIDTHTRUNC */
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        vld_o <= 1'b0;
        data_o <= 'd0;
        data_r <= 'd0;
    end else if(vld_tmp[1]) begin
        vld_o <= 1'b1;
        if(data_tmp1[1]*data_tmp1[1] > data_reg[1]) begin
            data_o <= data_tmp2[1];
            data_r <= data_reg[1] - data_tmp2[1]*data_tmp2[1];
        end else begin
            data_o <= data_tmp1[1];
            data_r <= data_reg[1] - data_tmp1[1]*data_tmp1[1];
        end
    end else begin
        vld_o <= 1'b0;
        data_o <= 'd0;
        data_r <= 'd0;
    end
end

endmodule
