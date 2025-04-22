module muxFiveBits(input s,
           input [4:0] in0,
           input [4:0] in1,
           output reg [4:0] out);

always @(*) begin
    if(s) begin
        out = in1;
    end
    else begin
        out = in0;
    end
end

endmodule
