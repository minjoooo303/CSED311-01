`include "vending_machine_def.v"


module change_state(clk,reset_n,current_total_nxt,current_total,i_trigger_return);

	input clk;
	input reset_n;
	input [`kTotalBits-1:0] current_total_nxt;
	output reg [`kTotalBits-1:0] current_total;
	input i_trigger_return;
	
	// Sequential circuit to reset or update the states
	always @(posedge clk ) begin //since it is sequential logic, nonblocking assignment is required
		if (!reset_n) begin
			// TODO: reset all states.
			current_total <= 0;
		end
		if(i_trigger_return) begin 
                current_total <=3;
		end 
		else begin
			// TODO: update all states.
			current_total <= current_total_nxt;
		end
	end
endmodule 
