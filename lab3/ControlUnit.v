`include "opcodes.v"

module ControlUnit (    
                    input reset, // 추가
                    input clk, // 추가
                    input [6:0] part_of_inst,
                    output reg mem_read, // 메모리에서 값을 읽을지
                    output reg mem_to_reg, // 메모리에서 읽은 값을 레지스터에 저장할지 ALU의 결과값을 레지스터에 저장할지
                    output reg mem_write, // 메모리에 값을 쓸지(저장할지)
                    output reg write_enable, // reg_write
                    // new for multi-cycle cpu
                    output reg PCWriteNotCond,
                    output reg PCWrite,
                    output reg IorD, // 메모리 주소의 사용 목적이 명령어인지 데이터인지
                    output reg IRWrite,
                    output reg PCSource,
                    output reg [1:0] ALUOp,
                    output reg ALUSrcA,
                    output reg [1:0] ALUSrcB,
                    // 이상.
                    output reg is_ecall // ecall
                    
);

    reg [2:0] curr_state;
    reg [2:0] next_state;

    // 클럭에 따라 reset되거나 다음 state로 넘어감
    always @(posedge clk) begin 
        if(reset) begin
            curr_state <= `IF;
        end
        else begin
            curr_state <= next_state;
        end
    end

    // next_stage를 설정하는 always블록
    always @(*) begin
        case(curr_state)
            `IF: begin
                case (part_of_inst)
                    `JAL: begin next_state = `EX; end
                    default: begin next_state = `ID; end
                endcase
            end
            `ID: begin
                next_state = `EX;
            end
            `EX: begin
                case (part_of_inst)
                    `BRANCH: begin next_state = `IF; end
                    `LOAD: begin next_state = `MEM; end
                    `STORE: begin next_state = `MEM; end
                    default: begin next_state = `WB; end
                endcase
            end
            `MEM: begin
               case (part_of_inst)
                    `LOAD: begin next_state = `WB; end
                    default: begin next_state = `IF; end // STORE일 때
                endcase 
            end
            `WB: begin
                next_state = `IF;
            end
            default: begin
                next_state = `IF;
            end
        endcase 

    end

    // control signal들을 설정하는 always블록
    always @(*) begin
        mem_read = 0;
        mem_to_reg = 0;
        mem_write = 0;
        write_enable = 0;
        PCWriteNotCond = 1; // branch일 때만 0
        PCWrite = 0;
        IorD = 0;
        IRWrite = 0;
        PCSource,
        ALUOp = 0;
        ALUSrcA = 0;
        ALUSrcB = 0;
        is_ecall = 0;

        if(part_of_inst == `ECALL) begin
            is_ecall = 1;
        end
        
        case(curr_state)
            `IF: begin
                mem_read = 1;
                PCWrite = 1;
                IRWrite = 1;
                ALUSrcB = 2'b01;
            end
            `ID: begin
                
            end
            `EX: begin
                case (part_of_inst)
                    `ARITHMETIC: begin // R-type
                        ALUOp = 2'b10;
                        ALUSrcA = 1;
                    end
                    `ARITHMETIC_IMM: begin // I-type
                        ALUOp = 2'b10;
                        ALUSrcA = 1;
                        ALUSrcB = 2'b10;
                    end
                    `LOAD: begin
                        ALUSrcA = 1;
                        ALUSrcB = 2'b10;
                    end
                    `JALR: begin
                        ALUSrcA = 1;
                        ALUSrcB = 2'b10; 
                    end
                    `STORE: begin
                        ALUSrcA = 1;
                        ALUSrcB = 2'b10;
                    end
                    `BRANCH: begin
                        PCWriteNotCond = 0;
                        PCSource = 1;
                        ALUOp = 2'b01; // SUB
                        ALUSrcA = 1;
                    end
                    `JAL: begin
                        ALUSrcB = 2'b10;
                    end
                endcase
            end
            `MEM: begin
                IorD = 1; 
                case (part_of_inst)
                    `LOAD: begin mem_read = 1; end
                    `STORE: begin mem_write = 1; end
                endcase
            end
            `WB: begin
                write_enable = 1; // reg_write
                case (part_of_inst)
                    `LOAD: begin 
                        mem_to_reg = 1; 
                    end
                    `JALR, `JAL: begin
                        PCWrite = 1;
                        PCSource = 1;
                    end
                endcase
            end
            default: begin
                PCWriteNotCond = 1;
            end
        endcase 
    end

endmodule
