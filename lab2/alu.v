module alu ( 	input [2:0] alu_op,
				input [1:0] btype, //for EQ, NE, GE, LT
				input [31 : 0] alu_in_1, //A
				input [31 : 0] alu_in_2, //B
       			output reg [31 : 0] alu_result, //C
				output reg alu_bcond);	



	always @(*) begin
		case (alu_op) 
			alu_bcond = 0;
			4'b0000: alu_result = alu_in_1 + alu_in_2; //ADD
			4'b0001: begin //SUB, Branch
				alu_result = alu_in_1 - alu_in_2;	
				case (btype)
					2'b00: alu_bcond = (alu_result == 32'b0) ? 1 : 0; 	// BEQ(Branch if Equal)
					2'b01: alu_bcond = (alu_result != 32'b0) ? 1 : 0; 	// BNE(Branch if Not Equal) 
					2'b10: alu_bcond = (alu_result[31]) ? 1 : 0; 		// BGE(Branch if Greater or Equal), 뺄셈 이후의 부호를 확인함.
					2'b11: alu_bcond = (!alu_result[31]) ? 1 : 0; 		// BLT(Branch if Less Than), 마찬가지로 부호 확인.
				endcase
			end
			4'b0010: alu_result = alu_in_1;
			4'b0011: alu_result = ~alu_in_1; //NOT
			4'b0100: alu_result = alu_in_1 & alu_in_2; //AND
			4'b0101: alu_result = alu_in_1 | alu_in_2; //OR

			4'b0110: alu_result = ~(alu_in_1 & alu_in_2); //NAND
			4'b0111: alu_result = ~(alu_in_1 | alu_in_2); //NOR

			4'b1000: alu_result = alu_in_1 ^ alu_in_2; //XOR
			4'b1001: alu_result = ~(alu_in_1 ^ alu_in_2); //XNOR

			4'b1010: alu_result = alu_in_1 << alu_in_2; //SLL
			4'b1011: alu_result = alu_in_1 >> alu_in_2; //SRL

			4'b1100: alu_result = alu_in_1 <<< alu_in_2; //Arithmetic Left Shift
			4'b1101: alu_result = alu_in_1 >>> alu_in_2; //SRA

			4'b1110: alu_result = ~alu_in_1 + 1; //NEG
			4'b1111: alu_result = 0;
			default: alu_result = 0;

		endcase
	end

endmodule

