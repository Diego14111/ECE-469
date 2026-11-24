`timescale 1ns/10ps
	module regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);
	output logic [63:0] ReadData1, ReadData2;
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	input logic RegWrite, clk;
	logic reset;
	assign reset = 0;
	
	logic [31:0] Register;
	decoder_5by32 d (Register, WriteRegister, RegWrite);
	
	logic [31:0] [63:0] data_out;
	genvar i;
	generate 
		for (i = 0; i < 31; i++) begin : reg_loop
			register m (data_out[i], Register[i], WriteData, reset, clk);
		end
	endgenerate
	
	assign data_out[31] = 64'b0;
	
	mux_64by32by1 m1(ReadData1,ReadRegister1,data_out);
	mux_64by32by1 m2(ReadData2,ReadRegister2,data_out);
	
endmodule 
