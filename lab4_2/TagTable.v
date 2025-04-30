module TagTable (
            input reset,
            input clk,
            input [31:0] pc_in,
            input update_TagTable,

            output reg TagTable_hit
);

    reg [24:0] Tags [0:31];
    reg Valids [0:31];

    wire [4:0] pc_idx;
    assign pc_idx = pc_in[6:2];

    wire [24:0] pc_tag;
    assign pc_tag = pc_in[31:7]; //


    always @(posedge clk) begin
        if (reset) begin
            for (integer i = 0; i < 32; i++) begin
                Valids[i] <= 0;
                Tags[i] <= 0;
            end
            TagTable_hit <= 0;
        end
        else begin
            // 분기했다면
            if (update_TagTable) begin
                Tags[pc_idx]   <= pc_tag;
                Valids[pc_idx] <= 1'b1;
            end

            // hit인 경우
            TagTable_hit <= Valids[pc_idx] && (Tags[pc_idx] == pc_tag);
            
        end
    end

endmodule
