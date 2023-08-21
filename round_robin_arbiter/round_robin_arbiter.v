`timescale 1ns/1ns

module round_robin_arbiter#(parameter
    N   =   16
)(
    input               clk,
    input               rst_n,
    input   [N-1:0]     req,
    output  reg [N-1:0] grant
);

reg     [N-1:0]     pointer_reg; // 优先级寄存器

wire    [N-1:0]     req_masked;
assign req_masked = req & pointer_reg;

/* verilator lint_off UNOPTFLAT */
wire    [N-1:0]     mask_higher_pri_reqs;
assign mask_higher_pri_reqs[N-1:1] = mask_higher_pri_reqs[N-2:0] | req_masked[N-2:0];
assign mask_higher_pri_reqs[0] = 1'b0;

wire    [N-1:0]     grant_masked;
wire grant_masked = req_masked & (~mask_higher_pri_reqs);

wire    [N-1:0]     unmask_higher_pri_reqs;
assign unmask_higher_pri_reqs[N-1:1] = unmask_higher_pri_reqs[N-2:0] | req[N-2:0];
assign unmask_higher_pri_reqs[0] = 1'b0;

wire    [N-1:0]     grant_unmasked;
assign grant_unmasked = req & ~unmask_higher_pri_reqs;

wire    no_req_masked;
assign no_req_masked = ~(|req_masked);

wire    [N-1:0]     grant_s;
assign  grant_s = grant_masked | ({N{no_req_masked}} & grant_unmasked);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        grant <= 'd0;
    else
        grant <= grant_s;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        pointer_reg <= {N{1'b1}};
    else begin
        if(|req_masked)
            pointer_reg <= mask_higher_pri_reqs;
        else if(|req)
            pointer_reg <= unmask_higher_pri_reqs;
        else
            pointer_reg <= pointer_reg;
    end
end

endmodule
