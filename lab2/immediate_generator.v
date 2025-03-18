`include "opcodes.v"

module immediate_generator (    input [31:0] part_of_inst,
                                output reg [31:0] imm_gen_out );

    always @(*) begin //조합논리 블록이므로 블로킹 할당 사용
        case(part_of_inst[6:0])
            `ARITHMETIC: begin // R-type
                imm_gen_out = 32'b0;
            end
            `ARITHMETIC_IMM, `LOAD, `JALR: begin // I-type
                imm_gen_out = {{20{part_of_inst[31]}}, part_of_inst[31:20]}; 
            end
            `STORE: begin // S-type
                imm_gen_out = {{20{part_of_inst[31]}}, part_of_inst[31:25], part_of_inst[11:7]};
            end
            `BRANCH: begin // SB-type
                imm_gen_out = {{19{part_of_inst[31]}}, part_of_inst[31], part_of_inst[7], part_of_inst[30:25], part_of_inst[11:8], 1'b0}
            end
            `JAL: begin // J-type
                imm_gen_out = {{11{part_of_inst[31]}}, part_of_inst[31], part_of_inst[19:12], part_of_inst[20], part_of_inst[30:21], 1'b0}
            end
            default: begin
                imm_gen_out = 32'b0;
            end

        endcase
    end


endmodule