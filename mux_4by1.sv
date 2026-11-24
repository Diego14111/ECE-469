`timescale 1ns/10ps
module mux_4by1 #(parameter WIDTH = 64) (out, Sel, D0, D1, D2, D3);
	output logic [WIDTH - 1:0] out;
	input logic  [WIDTH - 1:0] D0, D1, D2, D3;
	input logic [1:0] Sel;
	logic [WIDTH - 1:0] y1, y2;
	logic notSel_1; 
	
	// control to pick the mux
	not #0.05 not0 (notSel_1, Sel[1]);
	
	mux_2by1 #(WIDTH) m1 (y1, Sel[0], D0, D1, notSel_1);
	mux_2by1 #(WIDTH) m2 (y2, Sel[0], D2, D3, Sel[1]);
	
	// uses generate to pass all the bits to out
	genvar i;
	generate
		for(i = 0; i < WIDTH; i++) begin : Z
			or #0.05 result (out[i], y1[i], y2[i]);
		end
	endgenerate

endmodule 

module mux_4by1_testbench;
	parameter WIDTH = 64;
    logic [63:0] out;
    logic  [63:0] D0, D1, D2, D3;
    logic [1:0] Sel;
	
	mux_4by1 dut (out, Sel, D0, D1, D2, D3);
	
	integer k;
	initial begin
		for(k=0; k<4; k++) begin
				Sel = k;
				D0 = 64'd57;
				D1 = 64'd89;
				D2 = 64'd100;
				D3 = 64'd17;
				#1000;
		end
	end
endmodule 