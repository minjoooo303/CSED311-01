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


	reg [`kTotalBits-1:0] curr_coin; // store total coin
	reg [`kTotalBits-1:0] curr_coin2;
	// initiate values
	initial begin
		// TODO: initiate values
		input_total = 0;
		curr_coin = 0;
		curr_coin2 =0;
		o_return_coin = 0;
		wait_time = `kWaitTime;


	end


	// update coin return time
	always @(i_input_coin, i_select_item) begin
		// TODO: update coin return time
		if (i_input_coin != 0 && (current_total==0 || current_total==1)) begin
			
			if ( i_input_coin == 3'b001 ) begin
				curr_coin <= input_total + coin_value[0];
			end
			else if ( i_input_coin == 3'b010 ) begin
				curr_coin <= input_total + coin_value[1];
			end
			else if ( i_input_coin == 3'b100 ) begin
				curr_coin <= input_total + coin_value[2];
			end
			else begin
			end
		end
		else if ((i_select_item & o_available_item) && current_total==1) begin

			if ( i_select_item == 4'b0001 ) begin
				curr_coin <= curr_coin- item_price[0];
			end
			else if ( i_select_item == 4'b0010 ) begin
				curr_coin <= curr_coin - item_price[1];
			end
			else if ( i_select_item == 3'b0100 ) begin
				curr_coin<= curr_coin- item_price[2];
			end
			else if(i_select_item==4'b1000) begin
                curr_coin <= curr_coin - item_price[3];
            end
		end
            

	end

	always @(*) begin
		// TODO: o_return_coin
		case (current_total)
		0: begin 
			o_return_coin=3'b000;
			curr_coin2=0;
		end
		1: begin
			o_return_coin=3'b000;
			curr_coin2=0;
		end
		2: begin
			o_return_coin=3'b000;
			curr_coin2=0;
		end
		3: begin
			if (input_total >= coin_value[2]) begin
            	o_return_coin = 3'b100;
				curr_coin2 = input_total -coin_value[2];
			end
        	else if (input_total >= coin_value[1]) begin 
            	o_return_coin = 3'b010;
				curr_coin2 = input_total -coin_value[1];
			end
        	else if (input_total >= coin_value[0])begin
            	o_return_coin = 3'b001;
				curr_coin2 = input_total -coin_value[0];
			end
        	else begin
            	o_return_coin = 3'b000;
				curr_coin2 = input_total;
			end
		end
		default: begin
			o_return_coin=3'b000;
			curr_coin2=0;
			end

		endcase
	end

	always @(posedge clk ) begin
		if (!reset_n) begin
		// TODO: reset all states.
			input_total <= 0;
			curr_coin <= 0;
			o_return_coin <= 0;
			wait_time <= `kWaitTime;
		end
		else begin
		// TODO: update all states.
			if (!curr_coin2) begin
				input_total <= curr_coin;
			end
			else begin
				input_total <= curr_coin2;
			end
			wait_time <= wait_time - 1;
			if(i_trigger_return) begin 
                wait_time <=0;
			end 

		end
	end
endmodule 
