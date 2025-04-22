module HazardDetectionUnit (
                            input [4:0] rs1,
                            input [4:0] rs2,
                            input [4:0] rd,
                            input is_rs1_used,
                            input is_rs2_used,
                            input mem_read,
                            input is_ecall,
                            output reg pc_write,
                            output reg IF_ID_write,
                            output reg is_hazard 

);
    always @(*) begin
        // hazard detected
        if (((((rs1 == rd) && is_rs1_used) || (rs2 == rd) && is_rs2_used) && mem_read) || (rd == 17) && is_ecall) begin
            is_hazard = 1; 
            pc_write = 0;
            IF_ID_write = 0;
        end
        // hazard not detected
        else begin
            is_hazard = 0;
            pc_write = 1;
            IF_ID_write = 1;
        end
    end

endmodule

