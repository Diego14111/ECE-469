`timescale 1ns/10ps
module register (data_out, Register, WriteData, reset, clk);
	output logic [63:0] data_out;
	input logic [63:0] WriteData;
	input logic Register, reset, clk;
	
	genvar i;
	generate 
		for (i = 0; i < 64; i++) begin : reg_loop
			Enable ff (data_out[i], Register, WriteData[i], reset, clk);
		end
	endgenerate

endmodule 

`timescale 1ns/10ps
module register_testbench;
	logic [63:0] data_out;
	logic [63:0] WriteData;
	logic Register, reset, clk;
	
	parameter period = 100;
	
	register dut (.Register, .WriteData, .reset, .clk, .data_out);
	
	initial begin
		clk <= 1;
		forever #(period/2) clk <= ~clk;
	end

	integer i;
	integer k;
	initial begin
		reset = 1;
		Register = 0;
		WriteData = 0;
		
		reset = 0; @(posedge clk);
		Register = 1; @(posedge clk);
		
		for(k=0; k<64; k++) begin
			for(i=0; i<2; i++) begin
				WriteData[k] = i; @(posedge clk);
			end
		end
		
		Register = 0; @(posedge clk);
		for(k=0; k<64; k++) begin
			for(i=0; i<2; i++) begin
				WriteData[k] = i; @(posedge clk);
			end
		end
	end
endmodule 
