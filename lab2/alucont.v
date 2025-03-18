`include "opcodes.v"

module alucont (input [10:0] part_of_inst, 
                output [3:0] Reg alu_op
);

wire [6:0] opcodes;
wire [2:0] funct3;
wire funct7;

assign opcodes = part_of_inst[6:0];
assign funct3 = part_of_inst[9:7];
assign funct7 = part_of_inst[10];

always @(*) begin
    case (opcodes)
        `ARITHMETIC, `ARITHMETIC_IMM: begin
            // ARITHMETIC의 경우 funct7이 1이면 추가 분기 처리
            if(opcodes == `ARITHMETIC && funct7) begin
                alu_op = 4'b0001;
            end 
            else begin
                case(funct3)
                    `FUNCT3_ADD: alu_op = 4'b0000;
                    `FUNCT3_AND: alu_op = 4'b0010;
                    `FUNCT3_OR:  alu_op = 4'b0011;
                    `FUNCT3_XOR: alu_op = 4'b0100;
                    `FUNCT3_SLL: alu_op = 4'b0101;
                    `FUNCT3_SRL: alu_op = 4'b0110;
                endcase
            end
        end
        `LOAD: begin
            alu_op = 4'b0000;
        end
        `JALR: begin
            alu_op = 4'b0000;
        end
        `STORE: begin
            alu_op = 4'b0000;
        end
        `BRANCH: begin
            case (funct3)
                `FUNCT3_BEQ: alu_op = 4'b1000;
                `FUNCT3_BNE: alu_op = 4'b1001;
                `FUNCT3_BLT: alu_op = 4'b1010;
                `FUNCT3_BGE: alu_op = 4'b1011;
            endcase
        end
    endcase


end


endmodule
