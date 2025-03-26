module ALU ( 	input [3:0] alu_op,
				input [1:0] btype, //for EQ, NE, GE, LT
				input [31 : 0] alu_in_1, //A
				input [31 : 0] alu_in_2, //B
       			output reg [31 : 0] alu_result, //C
				output reg alu_bcond);	



	always @(*) begin
		alu_bcond = 0;
		case (alu_op) 
			4'b0000: begin alu_result = alu_in_1 + alu_in_2; end //ADD
			4'b0001: begin //SUB, Branch
				alu_result = alu_in_1 - alu_in_2;	
				case (btype)
					2'b00: alu_bcond = (alu_result == 32'b0) ? 1 : 0; 	// BEQ(Branch if Equal)
					2'b01: alu_bcond = (alu_result != 32'b0) ? 1 : 0; 	// BNE(Branch if Not Equal) 
					2'b10: alu_bcond = (alu_result[31]) ? 1 : 0; 		// BGE(Branch if Greater or Equal), 뺄셈 이후의 부호를 확인함.
					2'b11: alu_bcond = (!alu_result[31]) ? 1 : 0; 		// BLT(Branch if Less Than), 마찬가지로 부호 확인.
				endcase
			end
			4'b0010: begin alu_result = alu_in_1; end
			4'b0011: begin alu_result = ~alu_in_1; end //NOT
			4'b0100: begin alu_result = alu_in_1 & alu_in_2; end //AND
			4'b0101: begin alu_result = alu_in_1 | alu_in_2; end //OR

			4'b0110: begin alu_result = ~(alu_in_1 & alu_in_2); end //NAND
			4'b0111: begin alu_result = ~(alu_in_1 | alu_in_2); end //NOR

			4'b1000: begin alu_result = alu_in_1 ^ alu_in_2; end //XOR
			4'b1001: begin alu_result = ~(alu_in_1 ^ alu_in_2); end //XNOR

			4'b1010: begin alu_result = alu_in_1 << alu_in_2; end //SLL
			4'b1011: begin alu_result = alu_in_1 >> alu_in_2; end //SRL

			4'b1100: begin alu_result = alu_in_1 <<< alu_in_2; end //Arithmetic Left Shift
			4'b1101: begin alu_result = alu_in_1 >>> alu_in_2; end //SRA

			4'b1110: begin alu_result = ~alu_in_1 + 1; end //NEG
			4'b1111: begin alu_result = 0; end 
			default: begin alu_result = 0; end 

		endcase
	end

endmodule

