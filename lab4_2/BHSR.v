module BHSR() ( 
    input clk,
    input reset,
    input update_en,       // 업데이트할지 신호
    input taken,           // 이번 분기 결과 (1: taken, 0: not taken)
    output reg [4:0] bhsr_out  // 현재 BHSR 값 출력 // WIDTH:5 기준
);
    
always @(posedge clk) begin
    if (reset)
        bhsr_out <= 5'b00000; // WIDTH:5 기준
    else if (update_en)
        bhsr_out <= {bhsr_out[3:0], taken}; // 왼쪽으로 shift 후 taken 추가 // WIDTH:5 기준
end

endmodule
