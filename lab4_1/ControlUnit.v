`include "opcodes.v"

module ControlUnit(
                input [6:0] part_of_inst,  // input
                input is_hazard,      // input

                output reg mem_read,      // output
                output reg mem_to_reg,    // output
                output reg mem_write,     // output
                output reg alu_src,       // output
                output reg write_enable,  // output (==reg_write)
                output reg pc_to_reg,     // output
                output reg [1:0] alu_op,        // output
                output reg is_rs1_used,   // output 추가
                output reg is_rs2_used,   // output 추가
                output is_ecall       // output (ecall inst)
);  

    always @(*) begin
        mem_read = 0;
        mem_to_reg = 0;
        mem_write = 0; 
        alu_src = 0;
        write_enable = 0; 
        pc_to_reg = 0;
        alu_op = 0;
        is_rs1_used = 0;
        is_rs2_used = 0;
        is_ecall = 0;

        case (part_of_inst)
            `ARITHMETIC: begin
                write_enable = 1;
                alu_op = 2'b10;
                is_rs1_used = 1;
                is_rs2_used = 1;
            end

            `ARITHMETIC_IMM: begin
                alu_src = 1; // immediate generator에서 나온 값을 alu에 넣도록
                write_enable = 1;
                alu_op = 2'b10;
                is_rs1_used = 1;
            end

            `LOAD: begin
                mem_read = 1;
                mem_to_reg = 1;
                alu_src = 1;
                write_enable = 1;
                is_rs1_used = 1;
            end

            `STORE: begin
                mem_write = 1;
                alu_src = 1;
                is_rs1_used = 1;
                is_rs2_used = 2;
            end

            `ECALL: begin
                is_ecall = 1;
            end

            default: begin
                mem_read = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                write_enable = 0;
                pc_to_reg = 0;
                alu_op = 0;
                is_rs1_used = 0;
                is_rs2_used = 0;
                is_ecall = 0; 
            end
        endcase

    end



endmodule
