`timescale 1ns/10ps
module decoder_3by8 (Register, Write_Register, RegWrite);
	output logic [7:0] Register;
	input logic [2:0] Write_Register;
	input logic RegWrite;
	logic R0, R1, R2, R3, R4, R5, R6, R7;
	logic nC, nD, nE;
	
	not #0.05 nc (nC, Write_Register[2]);
	not #0.05 nd (nD, Write_Register[1]);
	not #0.05 ne (nE, Write_Register[0]);
	
	and #0.05 r0 (R0, nC, nD, nE, RegWrite);
	and #0.05 r1 (R1, nC, nD, Write_Register[0], RegWrite);
	and #0.05 r2 (R2, nC, Write_Register[1], nE, RegWrite);
	and #0.05 r3 (R3, nC, Write_Register[1], Write_Register[0], RegWrite);
	and #0.05 r4 (R4, Write_Register[2], nD, nE, RegWrite);
	and #0.05 r5 (R5, Write_Register[2], nD, Write_Register[0], RegWrite);
	and #0.05 r6 (R6, Write_Register[2], Write_Register[1], nE, RegWrite);
	and #0.05 r7 (R7, Write_Register[2], Write_Register[1], Write_Register[0], RegWrite);
	
	assign Register[0] = R0;
	assign Register[1] = R1;
	assign Register[2] = R2;
	assign Register[3] = R3;
	assign Register[4] = R4;
	assign Register[5] = R5;
	assign Register[6] = R6;
	assign Register[7] = R7;
	
endmodule

module decoder_3by8_testbench;
	logic [7:0] Register;
	logic [2:0] Write_Register;
	logic RegWrite;
	
	decoder_3by8 dut (.RegWrite, .Write_Register, .Register);
	
	integer i;
	integer k;
	initial begin
		for(k=0; k<2; k++) begin
			for (i=0; i<8; i++) begin
				RegWrite = k; #150;
				{Write_Register[2], Write_Register[1], Write_Register[0]} = i; #150;
			end
		end
	end
endmodule 

//vsim work.decoder_3by8_testbench
//add wave *
//run -all
// WOrking