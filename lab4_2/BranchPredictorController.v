module BranchPredictorController (
    input clk,
    input reset,
    input [31:0] pc,               // 현재 PC
    input update_pre_en,               // 예측기 업데이트 신호
    input taken_actual,            // 실제 분기 결과
    input [31:0] target_pc_actual,  // 실제 타겟 PC

    output [31:0] pre_next_pc
);

wire [31:0] pc_plus4;
assign pc_plus4 = pc + 32'd4;

wire [4:0] pc_idx;
assign pc_idx = pc[6:2];    

wire [4:0] bhsr_out;
wire predict_taken;
wire tagtable_hit;
wire [31:0] predicted_target;


wire [4:0] pht_idx;

wire btb_sig;
assign btb_sig = tagtable_hit & predict_taken;


// 모듈 인스턴스
gshare_xor gshare_xor(
    .pc_idx(pc_idx),
    .BHSR_output(bhsr_out),
    .PHT_idx(pht_idx)
);

BHSR bhsr (
    .reset(reset), //input
    .clk(clk),
    .update_en(update_pre_en),
    .taken(taken_actual),
    .bhsr_out(bhsr_out) //output
);

PHT pht(
    .reset(reset), //input
    .clk(clk),
    .PHT_idx(pht_idx),
    .update(update_pre_en),
    .real_taken(taken_actual),
    .predict_taken(predict_taken) //output
);

BTB btb(
    .reset(reset),  //input
    .clk(clk),
    .pc_in(pc),
    .update_BTB(update_pre_en),
    .real_target(target_pc_actual), 
    .guessed_target(predicted_target) //output
);

TagTable tagtable(
    .reset(reset),  //input
    .clk(clk),
    .pc_in(pc),
    .update_TagTable(update_pre_en),
    .TagTable_hit(tagtable_hit) //output
);

mux mux(
    .s(btb_sig),
    .in0(pc_plus4),
    .in1(predicted_target),
    .out(pre_next_pc));



endmodule
