`timescale 1ns/10ps
module mux_8by1 (ReadData, ReadRegister, data_out, muxx);
	output logic [63:0] ReadData;
	input logic [2:0] ReadRegister;
	input logic [7:0] [63:0] data_out;
	input logic muxx;
	logic sel2, sel1, sel0, out0, out1, out2, out3, out4, out5, out6, out7;
	logic [63:0] o0, o1, o2, o3, o4, o5, o6, o7, OR1, OR2, ORFINAL;
	
	not #0.05 Sel2 (sel2, ReadRegister[2]);
	not #0.05 Sel1 (sel1, ReadRegister[1]);
	not #0.05 Sel0 (sel0, ReadRegister[0]);
	
	and #0.05 Out0 (out0, sel2, sel1, sel0, muxx);
	and #0.05 Out1 (out1, sel2, sel1, ReadRegister[0], muxx);
	and #0.05 Out2 (out2, sel2, ReadRegister[1], sel0, muxx);
	and #0.05 Out3 (out3, sel2, ReadRegister[1], ReadRegister[0], muxx);
	and #0.05 Out4 (out4, ReadRegister[2], sel1, sel0, muxx);
	and #0.05 Out5 (out5, ReadRegister[2], sel1, ReadRegister[0], muxx);
	and #0.05 Out6 (out6, ReadRegister[2], ReadRegister[1], sel0, muxx);
	and #0.05 Out7 (out7, ReadRegister[2], ReadRegister[1], ReadRegister[0], muxx);
	
	and #0.05 O0 [63:0] (o0, {64{out0}}, data_out [0]);
	and #0.05 O1 [63:0] (o1, {64{out1}}, data_out [1]);
	and #0.05 O2 [63:0] (o2, {64{out2}}, data_out [2]);
	and #0.05 O3 [63:0] (o3, {64{out3}}, data_out [3]);
	and #0.05 O4 [63:0] (o4, {64{out4}}, data_out [4]);
	and #0.05 O5 [63:0] (o5, {64{out5}}, data_out [5]);
	and #0.05 O6 [63:0] (o6, {64{out6}}, data_out [6]);
	and #0.05 O7 [63:0] (o7, {64{out7}}, data_out [7]);
	
	or #0.05 or1 [63:0] (OR1, o0, o1, o2, o3);
	or #0.05 or2 [63:0] (OR2, o4, o5, o6, o7);
	or #0.05 orfinal [63:0] (ORFINAL, OR1, OR2);
	
	assign ReadData [63:0] = ORFINAL;
	
endmodule 

module mux_8by1_testbench;
	logic [63:0] ReadData;
	logic [2:0] ReadRegister;
	logic [7:0] [63:0] data_out;
	logic muxx;
	
	mux_8by1 dut (.ReadRegister, .data_out, .muxx, .ReadData);
	
	integer i;
	integer k;
	initial begin
		for(i=0; i<2; i++) begin
			muxx = i;
			for(k=0; k<8; k++) begin
				data_out[k] = k;
			end
			for(k=0; k<8; k++) begin
				ReadRegister = k;
			end
		end
	end
endmodule 
//Working
//vlog mux_8by1.sv
//vsim work.mux_8by1_testbench
//add wave *
//run -all