`timescale 1ns/10ps
module Adder (out, Cout, A, B, Cin);
	output logic out, Cout;
	input logic A, B, Cin;
	logic Not_A, op1, op2, op3, op4, op5, op6, op7, op8, op9;
	
	//boolean equation for Result
	not #0.05 Adder_1 (Not_A, A);
	xnor #0.05 Adder_2 (op1, B, Cin);
	and #0.05 Adder_3 (op2, op1, A);
	xor #0.05 Adder_4 (op3, B, Cin);
	and #0.05 Adder_5 (op4, op3, Not_A);
	or #0.05 Adder_6 (out, op4, op2);
	
	//boolean equation for Cout
	
	or #0.05 Adder_8 (op6, B, Cin);
	and #0.05 Adder_9 (op7, op6, A);
	and #0.05 Adder_10 (op8, B, Cin);
	or #0.05 Adder_11 (Cout, op8, op7);
	
endmodule 


module Adder_testbench;
	logic out, Cout;
	logic A, B, Cin;
	
	Adder dut (out, Cout, A, B, Cin);
	
	integer k;
	integer i;
	integer j;
	initial begin
		for(i = 0; i < 2; i++) begin
			for(k = 0; k < 2; k++) begin
				for(j = 0; j < 2; j++) begin
					A = i;
					B = k;
					Cin = j;
					#1000;
					if ((out  === (A ^ B ^ Cin)) &&
							(Cout ===  ((A & B) | (A & Cin) | (B & Cin))))
						$display("Pass");
					else
						$display("Fail");
				end
			end
		end
	end
endmodule
