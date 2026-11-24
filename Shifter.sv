`timescale 1ns/10ps
module Shifter #(parameter WIDTH = 9, parameter SHIFT = 2) (Shifted, bits);
	output logic [WIDTH - 1:0] Shifted;
	input logic [WIDTH - 1:0] bits;

	// uses generate to shift the bits by 2
	genvar i;
	generate
		for(i = WIDTH - 1; i > SHIFT - 1 ; i--) begin : Shifter
			assign Shifted[i] = bits[i - SHIFT]; //moves the bit i - 2 to i aka shifts it by 2
		end
	endgenerate
	
	// uses generate to set the bottom bits to 0
	generate
		for(i = SHIFT - 1; i > -1 ; i--) begin : Zero
			assign Shifted[i] = 1'b0; 
		end
	endgenerate
endmodule

module Shifter_testbench;
	parameter WIDTH = 8;
	parameter SHIFT = 2;
	logic [WIDTH - 1:0] Shifted;
	logic [WIDTH - 1:0] bits;

	Shifter #(.WIDTH(WIDTH), .SHIFT(SHIFT)) dut (Shifted, bits);

	initial begin
		bits = 8'b10101010;
		#100;
		bits = 8'b10111110;
		#100;
		bits = 8'b11111111;
		#100;
		bits = 8'b10000000;
		#100;
	end
endmodule