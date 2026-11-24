`timescale 1ns/10ps
module mux_32by1 (ReadData,ReadRegister,data_out);
	output logic [63:0] ReadData;
	input logic [4:0] ReadRegister;
	input logic [31:0] [63:0] data_out;
	logic inverted4, inverted3, mux1, mux2, mux3, mux4;
	logic [63:0] y1, y2, y3, y4;
	
	not #0.05 Inverted4 (inverted4, ReadRegister[4]);
	not #0.05 Inverted3 (inverted3, ReadRegister[3]);
	
	and #0.05 mux_1 (mux1, inverted4, inverted3);
	and #0.05 mux_2 (mux2, inverted4, ReadRegister[3]);
	and #0.05 mux_3 (mux3, ReadRegister[4], inverted3);
	and #0.05 mux_4 (mux4, ReadRegister[4], ReadRegister[3]);
	
	mux_8by1 m1 (y1, ReadRegister[2:0], data_out [7:0], mux1);
	mux_8by1 m2 (y2, ReadRegister[2:0], data_out [15:8], mux2);
	mux_8by1 m3 (y3, ReadRegister[2:0], data_out [23:16], mux3);
	mux_8by1 m4 (y4, ReadRegister[2:0], data_out [31:24], mux4);
	
	or #0.05 orout [63:0] (ReadData, y1, y2, y3, y4);

endmodule

module mux_32by1_testbench;
	logic [63:0] ReadData;
	logic [4:0] ReadRegister;
	logic [31:0] [63:0] data_out;
	
	mux_32by1 dut (.ReadRegister, .data_out, .ReadData);
	
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
//vlog mux_32by1.sv
//vsim work.mux_32by1_testbench
//add wave *
//run -all