module reqack #(parameter
    DATA_WIDTH  =   8
)(
    input                           clka,
    input                           rst_n,
    input   reg                     req,
    input   [DATA_WIDTH-1:0]        data_a,
    output  reg                     ack_s,

    input                           clkb,
    output  reg                     ack,
    output  reg [DATA_WIDTH-1:0]    data_b
);

reg     req_toggle_s;
always @(posedge clka or negedge rst_n) begin
    if(!rst_n)
        req_toggle_s <= 1'b0;
    else if(req)
        req_toggle_s <= ~req_toggle_s;
    else
        req_toggle_s <= req_toggle_s;
end

reg     req_toggle_sync1;
reg     req_toggle_sync2;
always @(posedge clkb or negedge rst_n) begin
    if(!rst_n) begin
        req_toggle_sync1 <= 1'b0;
        req_toggle_sync2 <= 1'b0;
    end else begin
        req_toggle_sync1 <= req_toggle_s;
        req_toggle_sync2 <= req_toggle_sync1;
    end
end

wire    req_sync;
assign req_sync = req_toggle_sync1 ^ req_toggle_sync2;

always @(posedge clkb or negedge rst_n) begin
    if(!rst_n) begin
        ack <= 1'b0;
        data_b <= 'd0;
    end
    else if(req_sync) begin
        ack <= req_sync;
        data_b <= data_a;
    end else begin
        ack <= 1'b0;
        data_b <= 'd0;
    end
end

reg     ack_toggle_s;
always @(posedge clkb or negedge rst_n) begin
    if(!rst_n)
        ack_toggle_s <= 1'b0;
    else if(ack)
        ack_toggle_s <= ~ack_toggle_s;
    else
        ack_toggle_s <= ack_toggle_s;
end

reg     ack_toggle_sync1;
reg     ack_toggle_sync2;
always @(posedge clka or negedge rst_n) begin
    if(!rst_n) begin
        ack_toggle_sync1 <= 1'b0;
        ack_toggle_sync2 <= 1'b0;
    end else begin
        ack_toggle_sync1 <= ack_toggle_s;
        ack_toggle_sync2 <= ack_toggle_sync1;
    end
end

wire    ack_sync;
assign ack_sync = ack_toggle_sync1 ^ ack_toggle_sync2;

always @(posedge clka or negedge rst_n) begin
    if(!rst_n)
        ack_s <= 1'b0;
    else
        ack_s <= ack_sync;
end

endmodule
