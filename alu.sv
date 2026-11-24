`timescale 1ns/10ps
module alu (result, negative, zero, overflow, carry_out, A, B, cntrl);
	output logic [63:0] result;
	output logic negative, zero, overflow, carry_out;
	input logic [63:0] A, B;
	input logic [2:0] cntrl;
	logic [7:0] [63:0] out;
	logic [1:0] temp_overflow, temp_carry_out;
	
	or #0.05 Pass_B [63:0] (out[0], B, {64{1'b0}});
	ALU_Add ALU_2 (out [2], temp_overflow[0], temp_carry_out[0], A, B);
	ALU_Subtract ALU_3 (out [3], temp_overflow[1], temp_carry_out[1], A, B);
	and #0.05 ANDER [63:0] (out[4], A, B); //AND
	or #0.05 OR_1 [63:0] (out[5], A, B); //OR
	xor #0.05 XOR_1 [63:0] (out[6], A, B); //XOR
	
	mux_8by1 Result (result, cntrl, out, 1'b1);
	and #0.05 negative_checker (negative, result[63], 1'b1);
	Zero_Checker Z (zero, result);
	
	wire notcontrol2;
	wire notcontrol0;
	wire add;
	wire sub;

	not #0.05 (notcontrol2, cntrl[2]);
	not #0.05 (notcontrol0, cntrl[0]);

	and #0.05 Add (add, notcontrol2, cntrl[1], notcontrol0);
	and #0.05 Sub (sub, notcontrol2, cntrl[1], cntrl[0]);

	wire overflow_1, overflow_2;
	wire carry_out_1, carry_out_2;

	and #0.05 overflow_ (overflow_1, temp_overflow[0], add);
	and #0.05 overflow__ (overflow_2, temp_overflow[1], sub);

	and #0.05 carry_out_ (carry_out_1, temp_carry_out[0], add);
	and #0.05 carry_out__ (carry_out_2, temp_carry_out[1], sub);

	or #0.05 overflow_final (overflow, overflow_1, overflow_2);
	or #0.05 carry_out_final (carry_out, carry_out_1, carry_out_2);
	
endmodule 

module alu_testbench;
	logic [63:0] result;
	logic negative, zero, overflow, carry_out;
	logic [63:0] A, B;
	logic [2:0] cntrl;
	logic [64:0] sum;
	logic carry_over, overflow_r;
	
	alu dut (result, negative, zero, overflow, carry_out, A, B, cntrl);
	
	parameter delay = 100000;
	
	integer i;
	initial begin
		$display("%t testing PASS_B operations", $time);
		cntrl[2] = 0;
		cntrl[1] = 0;
		cntrl[0] = 0;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			#(delay);
			if (result == B && negative == B[63] && zero == (B == '0))
				$display("Pass");
			else
				$display("Fail");
		end
		
		$display("%t testing ALU_ADD operations", $time);
		cntrl[2] = 0;
		cntrl[1] = 1;
		cntrl[0] = 0;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			sum = {1'b0, A} + {1'b0, B};
			carry_over = sum[64];
			overflow_r = (A[63] == B[63]) && (sum[63] != A[63]);
			#(delay);
			if (result == (A + B) && negative == result[63] && zero == (result == '0) && carry_out == carry_over && overflow == overflow_r)
				$display("Pass");
			else
				$display("Fail");
		end
		
		$display("%t testing ALU_SUBTRACT operations", $time);
		cntrl[2] = 0;
		cntrl[1] = 1;
		cntrl[0] = 1;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			sum = {1'b0, A} + {1'b0, ~B} + 65'd1;
			carry_over = sum[64];
			overflow_r = (A[63] != B[63]) && (sum[63] != A[63]);
			#(delay);
			if (result == (A - B) && negative == result[63] && zero == (result == '0) && carry_out == carry_over && overflow == overflow_r)
				$display("Pass");
			else
				$display("Fail");
		end
		
		$display("%t testing ALU_AND operations", $time);
		cntrl[2] = 1;
		cntrl[1] = 0;
		cntrl[0] = 0;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			#(delay);
			if (result == (A & B) && negative == result[63] && zero == (result == '0))
				$display("Pass");
			else
				$display("Fail");
		end
		
		$display("%t testing ALU_OR operations", $time);
		cntrl[2] = 1;
		cntrl[1] = 0;
		cntrl[0] = 1;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			#(delay);
			if (result == (A | B) && negative == result[63] && zero == (result == '0))
				$display("Pass");
			else
				$display("Fail");
		end
		
		$display("%t testing ALU_OR operations", $time);
		cntrl[2] = 1;
		cntrl[1] = 1;
		cntrl[0] = 0;
		for (i=0; i<100; i++) begin
			A = {$random(), $random()}; B = {$random(), $random()};
			#(delay);
			if (result == (A ^ B) && negative == result[63] && zero == (result == '0))
				$display("Pass");
			else
				$display("Fail");
		end
	end
endmodule 