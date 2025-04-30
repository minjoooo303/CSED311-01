module PHT (
            input reset,
            input clk,
            input [4:0] PHT_idx,
            input update,
            input real_taken, // actually taken인지
            output predict_taken
);

    // 32개의 2bit saturation counter
    reg [1:0] twobit_counters [0:31];

    // 2'10이거나 2'11일 때 taken으로 예측하도록 값을 assign
    assign predict_taken = (twobit_counters[PHT_idx] >= 2'b10);

    always @(posedge clk) begin
        if (reset) begin
            for (integer i = 0; i < 32; i++) begin
                twobit_counters[i] <= 2'b00;
            end
        end
        else if (update) begin
            case (twobit_counters[PHT_idx]) 
                2'b00: begin twobit_counters[PHT_idx] <= real_taken ? 2'b01 : 2'b00; end // Strongly Not Taken
                2'b01: begin twobit_counters[PHT_idx] <= real_taken ? 2'b10 : 2'b00; end // Weakly Not Taken
                2'b10: begin twobit_counters[PHT_idx] <= real_taken ? 2'b11 : 2'b01; end // Weakly Taken
                2'b11: begin twobit_counters[PHT_idx] <= real_taken ? 2'b11 : 2'b10; end // Strongly Taken
                default: begin twobit_counters[PHT_idx] <= 2'b00; end
            endcase
        end
    end

endmodule
