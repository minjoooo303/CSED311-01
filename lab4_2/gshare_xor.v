module gshare_xor (
                    input [4:0] pc_idx,
                    input [4:0] BHSR_output,
                    output [4:0] PHT_idx
);

    assign PHT_idx = pc_idx ^ BHSR_output;

endmodule
