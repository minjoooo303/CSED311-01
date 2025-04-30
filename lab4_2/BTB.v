module BTB (
            input reset,
            input clk,
            input [31:0] pc_in,
            input update_BTB,
            input [31:0] real_target,

            output reg BTB_hit,
            output reg [31:0] guessed_target
);

    reg [26:0] Tags [0:31];
    reg [31:0] Targets [0:31];
    reg Valid_bit [0:31];

    wire [4:0] pc_idx;
    assign pc_idx = pc_in[6:2];

    always @(posedge clk) begin
        if (reset) begin
            for (integer i = 0; i < 32; i++) begin
                Valid_bit[i] <= 0;
            end
            BTB_hit <= 0;
        end
        else begin
            // 분기 발생; BTB를 업데이트한다; Tags, Targets, Valid_bit의 값을 알맞게 변경
            if (update_BTB) begin
                Tags[pc_idx] <= pc_in[31:7];
                Targets[pc_idx] <= real_target;
                Valid_bit[pc_idx] <= 1;
            end

            // hit인 경우; BTB에서 target pc를 가져와 next pc로 설정
            if (Valid_bit[pc_idx] && (Tags[pc_idx] == pc_in[31:7])) begin
                BTB_hit <= 1;
                guessed_target <= Targets[pc_idx];
            end
            // miss인 경우; flush 발생
            else begin
                BTB_hit <= 0;
                guessed_target <= 32'b0;
            end
        end
    end

endmodule
