
`include "vending_machine_def.v"
	

module calculate_current_state(i_input_coin,i_select_item,item_price,coin_value,current_total,
input_total, output_total, return_total,current_total_nxt,wait_time,o_return_coin,o_available_item,o_output_item);


	
	input [`kNumCoins-1:0] i_input_coin,o_return_coin;
	input [`kNumItems-1:0]	i_select_item;			
	input [31:0] item_price [`kNumItems-1:0];
	input [31:0] coin_value [`kNumCoins-1:0];	
	input [`kTotalBits-1:0] current_total;
	input [31:0] wait_time;
	output reg [`kNumItems-1:0] o_available_item,o_output_item;
	output reg  [`kTotalBits-1:0] input_total, output_total, return_total,current_total_nxt;
	integer i;	



	
	// Combinational logic for the next states
	always @(*) begin
		// TODO: current_total_nxt
		// You don't have to worry about concurrent activations in each input vector (or array).
		// Calculate the next current_total state.
		// Calculate the next current_total state.
		case(current_total)
			0: begin // initial state
				if (i_input_coin) begin
					current_total_nxt = 1;
				end
				else begin
					current_total_nxt = 0;
				end
			end
			1: begin // waiting state
				if (wait_time) begin
					if (i_select_item) begin
						if (o_available_item) begin
							current_total_nxt = 2;
						end
						else begin
							current_total_nxt = 1;
						end
					end
					else begin
						current_total_nxt = 1;
					end
				end
				else begin
					current_total_nxt = 3;
				end
			end
			2: begin // dispense state
				current_total_nxt = 1;
			end
			3: begin // return state
				current_total_nxt = 0;
			end
			default:
				current_total_nxt = 0;
		endcase
		
	end

	
	
	// Combinational logic for the outputs
	always @(*) begin
		// TODO: o_available_item
		// TODO: o_output_item
		if (current_total == 1) begin
			if (input_total >= item_price[3]) begin
				o_available_item = 4'b1111;
			end
			else if (input_total >= item_price[2]) begin
				o_available_item = 4'b0111;
			end
			else if (input_total >= item_price[1]) begin
				o_available_item = 4'b0001;
			end
			else if (input_total >= item_price[0]) begin
				o_available_item = 4'b0001;
			end
			else begin
				o_available_item = 4'b0001;
			end
			o_output_item = i_select_item & o_available_item;
		end
		else begin
			o_available_item = 4'b0000;
			o_output_item = 4'b0000;
		end
	end
 
	


endmodule 
