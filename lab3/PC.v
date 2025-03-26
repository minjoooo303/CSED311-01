module PC (input reset,
           input clk,
           input [31:0] next_pc,
           input CurrIsNextPC,
           output reg [31:0] current_pc); // instruction at addr

always @(posedge clk) begin
    if (reset) begin
        current_pc <= 0; 
    end
    else begin
        if (CurrIsNextPC) begin
            current_pc <= next_pc;
        end
    end
end
endmodule
