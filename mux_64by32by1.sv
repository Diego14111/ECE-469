`timescale 1ns/10ps
module mux_64by32by1 (ReadData,ReadRegister,data_out);
	output logic [63:0] ReadData;
	input logic [4:0] ReadRegister;
	input logic [31:0] [63:0] data_out;
	
	// mux_32by1 already selects a complete 64-bit word.
	mux_32by1 m32 (ReadData, ReadRegister, data_out);
endmodule 

module mux_64by32by1_testbench;
	logic [63:0] ReadData;
	logic [4:0] ReadRegister;
	logic [31:0] [63:0] data_out;
	
	mux_64by32by1 dut (.ReadRegister, .data_out, .ReadData);
	
	integer k;
	initial begin
		for(k=0; k<32; k++) begin
			data_out[k] = k;
		end
		for(k=0; k<32; k++) begin
			ReadRegister = k; #1000;
		end
	end
endmodule 
//Working
//vlog mux_64by32by1.sv
//vsim work.mux_64by32by1_testbench
//add wave *
//run -all