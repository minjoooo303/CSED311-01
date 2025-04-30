module BTB (
            input reset,
            input clk,
            input [31:0] pc_in,
            input update_BTB,
            input [31:0] real_target,

            output reg [31:0] guessed_target
);

    reg [31:0] Targets [0:31];

    wire [4:0] pc_idx;
    assign pc_idx = pc_in[6:2];

    always @(posedge clk) begin
        if (reset) begin
            for (integer i = 0; i < 32; i++) begin
                Targets[i] <= 0;
            end
            guessed_target <= 0;
        end
        else begin
            // 분기 발생; BTB를 업데이트한다; Tags, Targets 값을 알맞게 변경
            if (update_BTB) begin
                Targets[pc_idx] <= real_target;
            end
            // predict_target 출력
            
            guessed_target <= Targets[pc_idx];
            
            
        end
    end

endmodule
