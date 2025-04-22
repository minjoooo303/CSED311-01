module data_forwarding (input [4:0] ID_EX_rs1, 
                        input [4:0] ID_EX_rs2,
                        input [4:0] EX_MEM_rd,
                        input EX_MEM_reg_write,
                        input [4:0] MEM_WB_rd,
                        input MEM_WB_reg_write,

                        output reg [1:0] forward_a,
                        output reg [1:0] forward_b
); // ex reg의 rs1!=0 && ex reg의 rs1 == mem reg의 rd && mem reg의 reg write


// mux 에서 0이 기본, 1이 mem forwarding, 2가 wb forwarding
    always @(*) begin
        // rs1
        if (ID_EX_rs1 != 0 && ID_EX_rs1==EX_MEM_rd && EX_MEM_reg_write) begin
            forward_a = 2'b01;
        end
        elif (ID_EX_rs1 != 0 && ID_EX_rs1==MEM_WB_rd && MEM_WB_reg_write) begin
            forward_a = 2'b10;
        end
        else begin
            forward_a = 2'b00;
        end

        //rs2
        if (ID_EX_rs2 != 0 && ID_EX_rs2==EX_MEM_rd && EX_MEM_reg_write) begin
            forward_b = 2'b01;
        end
        elif (ID_EX_rs2 != 0 && ID_EX_rs2==MEM_WB_rd && MEM_WB_reg_write) begin
            forward_b = 2'b10;
        end
        else begin 
            forward_b = 2'b00;
        end
    end
endmodule


