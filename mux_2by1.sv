`timescale 1ns/10ps
module mux_2by1 #(parameter WIDTH = 64) (out, Sel, D0, D1, Enable);
	output logic [WIDTH - 1:0] out; 
	input logic Sel, Enable;
	input logic [WIDTH - 1:0] D0, D1;
	logic [WIDTH - 1:0] out0, out1;
	logic notSel;
	
	//control logic to set the logic to pick the out
	not #0.05 Sel0 (notSel, Sel);
	
	//uses generate to set the bits into out
	genvar i;
	generate
		for(i = 0; i < WIDTH; i++) begin : Z
			and #0.05 Out0 (out0 [i], notSel, D0 [i], Enable);
			and #0.05 Out1 (out1 [i], Sel, D1 [i], Enable);
			or #0.05 OrFinal (out[i], out0[i], out1[i]);
		end
	endgenerate
	 
endmodule

module mux_2by1_testbench;
	parameter WIDTH = 64;
    logic [WIDTH - 1:0] out;
	 logic Sel, Enable;
    logic [WIDTH - 1:0] D0, D1;
	
	mux_2by1 dut (out, Sel, D0, D1, Enable);
	
	integer k;
	initial begin
	Enable = 1;
	#300
		for(k=0; k<2; k++) begin
				Sel = k;
				D0 = 64'd57;
				D1 = 64'd89;
				#300;
		end
	end
endmodule 