`include "vending_machine_def.v"

	

module check_time_and_coin(clk,reset_n,i_input_coin,i_select_item,current_total,o_available_item,item_price, coin_value,i_trigger_return,wait_time,o_return_coin,input_total);
	input clk;
	input reset_n;
	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0]	i_select_item;
	input [`kTotalBits-1:0] current_total;
	input [`kNumItems-1:0] o_available_item;
	input [31:0] item_price [`kNumItems-1:0];
    input [31:0] coin_value [`kNumCoins-1:0];
	input i_trigger_return;

	output reg  [`kNumCoins-1:0] o_return_coin; // 여기에 돈 다 저장 (현재 돈 현황)
	output reg [31:0] wait_time;
	output reg  [`kTotalBits-1:0] input_total; //추가
	reg  [`kTotalBits-1:0]output_total,return_total;

	// initiate values
	initial begin
		// TODO: initiate values
		input_total = 0;
		output_total = 0;
		return_total =0;
		o_return_coin = 0;
		wait_time = `kWaitTime;


	end


	// update coin return time
	always @(i_input_coin, i_select_item) begin
		// TODO: update coin return time
		if (i_input_coin != 0 && (current_total==0 || current_total==1)) begin
			
			if ( i_input_coin == 3'b001 ) begin
				output_total = input_total + coin_value[0];
			end
			else if ( i_input_coin == 3'b010 ) begin
				output_total = input_total + coin_value[1];
			end
			else if ( i_input_coin == 3'b100 ) begin
				output_total = input_total + coin_value[2];
			end
			else begin
			end
		end
		else if ((i_select_item & o_available_item) && current_total==1) begin

			if ( i_select_item == 4'b0001 ) begin
				output_total = input_total- item_price[0];
			end
			else if ( i_select_item == 4'b0010 ) begin
				output_total = input_total - item_price[1];
			end
			else if ( i_select_item == 3'b0100 ) begin
				output_total = input_total- item_price[2];
			end
			else if(i_select_item==4'b1000) begin
                output_total = input_total - item_price[3];
            end
		end
            

	end

	always @(*) begin
		// TODO: o_return_coin
		o_return_coin = 3'b000;
		return_total = input_total;

		case (current_total)
		0: begin 
			o_return_coin=3'b000;
			return_total=0;
		end
		1: begin
			o_return_coin=3'b000;
			return_total=0;
		end
		2: begin
			o_return_coin=3'b000;
			return_total=0;
		end
		3: begin
			return_total = input_total;
			if (return_total >= coin_value[2]) begin
            	o_return_coin = 3'b100;
				return_total = input_total -coin_value[2];
			end
        	if (return_total >= coin_value[1]) begin 
            	o_return_coin = o_return_coin | 3'b010;
				return_total = input_total -coin_value[1];
			end
        	else if (return_total >= coin_value[0])begin
            	o_return_coin = o_return_coin | 3'b001;
				return_total = input_total -coin_value[0];
			end
        	else begin
            	o_return_coin = 3'b000;
				return_total = input_total;
			end
		end
		default: begin
			o_return_coin=3'b000;
			return_total=0;
			end

		endcase
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
			input_total <= 0;
			return_total =0;
			o_return_coin = 0;
			wait_time <= `kWaitTime;
		end
		else begin
		// TODO: update all states.
			if (return_total>0) begin
				input_total <= return_total;
			end
			else begin
				input_total <= output_total;
			end
			wait_time <= wait_time - 1;
			if(i_trigger_return) begin 
                wait_time <=0;
			end 

		end
	end
endmodule 
