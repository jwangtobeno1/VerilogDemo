`timescale 1ns / 1ps

module pingpong_buf #(parameter
    WIDTH   =   8,
    DEPTH   =   16
)(
    // system port
    clk         ,
    rst_n       ,

    // left port data_in
    wr_addr     ,
    wr_data     ,
    wr_en       ,
    switch_buf  ,
    cur_wr_buf  ,

    // right port data_out
    rd_addr     ,
    rd_data     
);

localparam ADDR_WIDTH = $clog2(DEPTH);

input       clk;
input       rst_n;

input   [ADDR_WIDTH-1 : 0]  wr_addr;
input   [WIDTH-1 : 0]       wr_data;
input       wr_en;
input       switch_buf;
output      cur_wr_buf;

input   [ADDR_WIDTH-1 : 0]  rd_addr;
output  [WIDTH-1 : 0]       rd_data;


reg     wr_buf; 
wire    wr_buf0_en;
wire    wr_buf1_en;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        wr_buf <= 'd0;
    else if(switch_buf)
        wr_buf <= ~wr_buf;
    else
        wr_buf <= wr_buf;
end

assign wr_buf0_en = (wr_buf == 1'b0) ?  1'b1 : 1'b0;
assign wr_buf1_en = (wr_buf == 1'b1) ?  1'b1 : 1'b0;

assign cur_wr_buf = wr_buf;

wire    rd_buf;
wire    [WIDTH-1 : 0]   rd_buf0_data;
wire    [WIDTH-1 : 0]   rd_buf1_data;

assign rd_buf = ~wr_buf;

assign rd_data = rd_buf ? rd_buf1_data : rd_buf0_data;

ad_mem #(

    .DATA_WIDTH(WIDTH),
    .ADDRESS_WIDTH(ADDR_WIDTH)

    )buf0_inst(

    .clka(clk),
    .wea(wr_en && wr_buf0_en),
    .addra(wr_addr),
    .dina(wr_data),

    .clkb(clk),
    .reb(1'b1),
    .addrb(rd_addr),
    .doutb(rd_buf0_data)
);

ad_mem #(

    .DATA_WIDTH(WIDTH),
    .ADDRESS_WIDTH(ADDR_WIDTH)

    )buf1_inst(

    .clka(clk),
    .wea(wr_en && wr_buf1_en),
    .addra(wr_addr),
    .dina(wr_data),

    .clkb(clk),
    .reb(1'b1),
    .addrb(rd_addr),
    .doutb(rd_buf1_data)
);

endmodule
