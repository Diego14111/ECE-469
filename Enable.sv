`timescale 1ns/10ps
module Enable (data_out, Register, WriteData, reset, clk);
	output logic data_out;
	input logic WriteData;
	input logic Register, reset, clk;
	logic change, hold, din, disabled;
	
	not #0.05 d (disabled, Register);
	and #0.05 c (change, WriteData, Register);
	and #0.05 h (hold, data_out, disabled);
	or #0.05 new_data (din, change, hold);
	D_FF ff (data_out, din, reset, clk);
	
endmodule 

`timescale 1ns/10ps
module Enable_testbench;
	logic data_out;
	logic WriteData;
	logic Register, reset, clk;
	
	parameter period = 100;
	
	Enable dut (.Register, .WriteData, .reset, .clk, .data_out);
	
	initial begin
		clk <= 0;
		forever #(period/2) clk <= ~clk;
	end
	
	integer i;
	integer k;
	initial begin
		reset = 1;
		Register = 0;
		WriteData = 0;
	 
					@(posedge clk);
		reset = 0; @(posedge clk);
	 
		for(k=0; k<2; k++) begin
			for (i=0; i<2; i++) begin
				Register = k; @(posedge clk);
				WriteData = i; @(posedge clk);
				
			end
		end
	#10;
   $stop;
	end
endmodule
//
//vlog Enable.sv
//vsim Enable_testbench
//add wave *
//run -all