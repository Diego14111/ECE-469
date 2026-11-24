`timescale 1ns/10ps
module Zero_Checker(zero, result);
	output logic zero;
	input logic [63:0] result;
	logic [64:0] zer0_start;
	logic op1;

	assign zer0_start[0] = 0;
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin : Z
			or #0.05 zer(zer0_start[i + 1], result[i], zer0_start[i]);
		end
	endgenerate
	
	not #0.05 real_value (zero, zer0_start[64]);
	
endmodule
//module Zero_Checker_testbench;
//	logic zero;
//	logic [63:0] result;
//	logic Enable;
	
//	Zero_Checker dut (zero, result, Enable);
	
	