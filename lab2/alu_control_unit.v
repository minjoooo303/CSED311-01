`include "opcodes.v"

module alu_control_unit (input [10:0] part_of_inst, 
                output reg[3:0] alu_op,
                output reg [1:0] btype
);

wire [6:0] opcodes;
wire [2:0] funct3;
wire funct7; 

assign opcodes = part_of_inst[6:0];
assign funct3 = part_of_inst[9:7];
assign funct7 = part_of_inst[10];

always @(*) begin
    alu_op = 4'b0000;
    btype  = 2'b00;
    
    case (opcodes)
        `ARITHMETIC: begin
            if(funct7) begin
                alu_op = 4'b0001;
            end
            else begin
                case(funct3)
                    `FUNCT3_ADD: alu_op = 4'b0000;
                    `FUNCT3_SLL: alu_op = 4'b1010;
                    `FUNCT3_XOR: alu_op = 4'b1000;
                    `FUNCT3_OR: alu_op = 4'b0101;
                    `FUNCT3_AND: alu_op = 4'b0100;
                    `FUNCT3_SRL: alu_op = 4'b1011;
                    default: alu_op = 4'b0000;

                endcase
            end
        end 

        `ARITHMETIC_IMM: begin
            case(funct3)
                `FUNCT3_ADD: alu_op = 4'b0000;
                `FUNCT3_SLL: alu_op = 4'b1010;
                `FUNCT3_XOR: alu_op = 4'b1000;
                `FUNCT3_OR: alu_op = 4'b0101;
                `FUNCT3_AND: alu_op = 4'b0100;
                `FUNCT3_SRL: alu_op = 4'b1011;
                default: alu_op = 4'b0000;
            endcase
        end
        `LOAD: alu_op = 4'b0000;
        `JALR: alu_op = 4'b0000;
        `STORE: alu_op = 4'b0000;
        `BRANCH: begin
            alu_op = 4'b0001;
            case(funct3)
                `FUNCT3_BEQ: btype = 2'b00;
                `FUNCT3_BNE: btype = 2'b01;
                `FUNCT3_BLT: btype = 2'b10;
                `FUNCT3_BGE: btype = 2'b11;
                default: btype = 2'b00;
            endcase
        end
        `JAL: alu_op = 4'b0000;
        `ECALL: alu_op = 4'b0000;
        default: alu_op = 4'b0000;

    endcase
end

endmodule
