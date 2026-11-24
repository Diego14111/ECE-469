`timescale 1ns/10ps
module decoder_5by32 (Register, Write_Register, RegWrite);
	output logic [31:0] Register;
	input logic [4:0] Write_Register;
	input logic RegWrite;
	logic nA, nB;
	logic d1,d2,d3,d4;
	
	not #0.05 na (nA, Write_Register[4]);
	not #0.05 nb (nB, Write_Register[3]);
	
	and #0.05 D1 (d1, nA, nB, RegWrite);
	and #0.05 D2 (d2, nA, Write_Register[3], RegWrite);
	and #0.05 D3 (d3, Write_Register[4], nB, RegWrite);
	and #0.05 D4 (d4, Write_Register[4], Write_Register[3], RegWrite);
	
	decoder_3by8 V1 (Register [7:0],Write_Register [2:0], d1);
	decoder_3by8 V2 (Register [15:8],Write_Register [2:0], d2);
	decoder_3by8 V3 (Register [23:16],Write_Register [2:0], d3);
	decoder_3by8 V4 (Register [31:24],Write_Register [2:0], d4);
	
endmodule

module decoder_5by32_testbench;
	logic [31:0] Register;
	logic [4:0] Write_Register;
	logic RegWrite;
	
	decoder_5by32 dut (.RegWrite, .Write_Register, .Register);
	
	integer i;
	integer k;
	initial begin
		for(k=0; k<2; k++) begin
			for (i=0; i<32; i++) begin
				RegWrite = k;
				Write_Register = i;
				#1000;
			end
		end
	end
endmodule 
//vsim work.decoder_5by32_testbench
//add wave *
//run -all
//Working