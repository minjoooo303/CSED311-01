
module adder (  input [31:0] add_input1, 
                input [31:0] add_input2,
                output [31:0] add_output );

    assign add_output = add_input1 + add_input2;

endmodule
