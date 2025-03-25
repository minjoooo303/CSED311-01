`include "opcodes.v"
//# part_of_inst 수정해야함 !!
module alu_control_unit (input [3:0] part_of_inst, 
                input [1:0] ALUOp,
                output reg[3:0] alu_op,
                output reg [1:0] btype
);

// wire [6:0] opcodes;
wire [2:0] funct3;
wire funct7;

// assign opcodes = part_of_inst[6:0];
assign funct3 = part_of_inst[2:0];
assign funct7 = part_of_inst[3];

always @(*) begin
    alu_op = 4'b0000;
    btype  = 2'b00;
    
    case (ALUOp)
        2'b00: alu_op = 4'b00010; // Load, Store -> add

        2'b01: begin // Branch -> sub
            alu_op = 4'b0001;
            case(funct3)
                `FUNCT3_BEQ: btype = 2'b00;
                `FUNCT3_BNE: btype = 2'b01;
                `FUNCT3_BLT: btype = 2'b10;
                `FUNCT3_BGE: btype = 2'b11;
                default: btype = 2'b00;
            endcase
        end
        2'b10: begin // R and I type
            if(opcode == `ARITHMETIC &&funct7) begin
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
        
        default: alu_op = 4'b0000;

    endcase
end

endmodule
