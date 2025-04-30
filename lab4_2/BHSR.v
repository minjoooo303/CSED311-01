module BHSR(parameter WIDTH = 5) (  // WIDTH: BHSR 비트 수
    input clk,
    input reset,
    input update_en,       // 업데이트할지 신호
    input taken,           // 이번 분기 결과 (1: taken, 0: not taken)
    output reg [WIDTH-1:0] bhsr_out  // 현재 BHSR 값 출력
);

always @(posedge clk) begin
    if (reset)
        bhsr_out <= 0;
    else if (update_en)
        bhsr_out <= {bhsr_out[WIDTH-2:0], taken}; // 왼쪽으로 shift 후 taken 추가
end

endmodule
