module mux(input s,
           input [31:0] in0,
           input [31:0] in1,
           output reg [31:0] out);

always @(*) begin
    if(s) begin
        out = in1;
    end
    else begin
        out = in0;
    end
end

endmodule
