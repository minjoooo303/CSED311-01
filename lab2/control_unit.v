`include "opcodes.v"


module control_unit (    input [6:0] part_of_inst,
                    output wire is_jal,
                    output wire is_jalr,
                    output wire branch,
                    output wire mem_read,
                    output wire mem_to_reg,
                    output wire mem_write,
                    output reg alu_src,
                    output reg write_enable, // reg_write
                    output wire pc_to_reg,
                    output reg is_ecall
                    
);
    reg jalr_reg;
    reg jal_reg;
    reg branch_reg;

    reg PCtoReg_reg;

    reg isStore;
    reg isLoad;

    assign is_jalr = jalr_reg;
    assign is_jal = jal_reg;
    assign branch = branch_reg;

    assign mem_read = isLoad;
    assign mem_to_reg = isLoad;
    assign mem_write = isStore;

    assign pc_to_reg = PCtoReg_reg;

    always @(*) begin
        jalr_reg = 0;
        jal_reg = 0;
        branch_reg = 0;
        PCtoReg_reg = 0;
        isStore = 0;
        isLoad = 0;
        is_ecall = 0;
        alu_src = 0;
        write_enable = 0;

        case(part_of_inst[6:0])
            `ARITHMETIC: begin // R-type
                write_enable = 1;
            end
            `ARITHMETIC_IMM: begin // I-type
                alu_src = 1;
                write_enable = 1;
            end
            `LOAD: begin // I-type
                isLoad = 1;
                alu_src = 1;
                write_enable = 1;
            end
            `JALR: begin // I-type
                jalr_reg = 1;
                PCtoReg_reg = 1;
                alu_src = 1;
                write_enable = 1;
            end
            `STORE: begin // S-type
                isStore = 1;
                alu_src = 1;
            end
            `JAL: begin // J-type
                jal_reg = 1;
                PCtoReg_reg = 1; 
                write_enable = 1;
            end
            `BRANCH: begin // B-type
                branch_reg = 1;
            end
            `ECALL: begin
                is_ecall = 1;
            end
            default: begin
            end

        endcase 

    end


endmodule
