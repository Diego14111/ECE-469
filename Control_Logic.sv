`timescale 1ns/10ps
module Control_Logic(ALU, RegALU, memtoReg, to_PC, Flag_enable, BL, RdtoReg, WrEn, Read_enable, RegWrite, RdtoPC, instruction, zero, negative, overflow);
	output logic [2:0] ALU;
	output logic [1:0] RegALU, memtoReg, to_PC;
	output logic BL, RdtoReg, WrEn, RegWrite, RdtoPC, Flag_enable, Read_enable;
	input logic [31:0] instruction;
	input  logic zero, negative, overflow;

	always_comb begin
		BL = 1'b0;
		RdtoReg = 1'b0;
		RegALU = 2'b00;
		memtoReg = 2'b00;
		WrEn = 1'b0;
		RegWrite = 1'b0;
		to_PC = 2'b00;
		RdtoPC = 1'b0;
		Flag_enable = 1'b0;
		ALU = 3'b010;
		Read_enable = 1'b0;
		if (instruction[31:22] == 10'b1001000100) begin // ADDI
			RegALU = 2'b01;      // Imm12
			RegWrite = 1'b1;
		end else if (instruction[31:21] == 11'b10101011000) begin // ADDS
			RegWrite = 1'b1;
			Flag_enable = 1'b1;
		end else if (instruction[31:21] == 11'b11101011000) begin // SUBS
			ALU = 3'b011;
			RegWrite = 1'b1;
			Flag_enable = 1'b1;
		end else if (instruction[31:26] == 6'b000101) begin // B
			to_PC = 2'b01;
		end else if (instruction[31:24] == 8'b01010100 &&
		                     instruction[4:0] == 5'b01011) begin // B.LT
			if (negative != overflow) begin
				to_PC = 2'b10;
			end
		end else if (instruction[31:26] == 6'b100101) begin // BL
			BL = 1'b1;
			memtoReg = 2'b10;
			RegWrite = 1'b1;
			to_PC = 2'b01;
		end else if (instruction[31:21] == 11'b11010110000) begin // BR
			RdtoReg = 1;
			RdtoPC = 1'b1;
		end else if (instruction[31:24] == 8'b10110100) begin // CBZ
			RdtoReg = 1'b1;
			ALU = 3'b000;
			if (zero) begin
				to_PC = 2'b10;
			end
		end else if (instruction[31:21] == 11'b11111000010) begin // LDUR
			RegALU = 2'b10;
			memtoReg = 2'b01;
			Read_enable = 1'b1;
			RegWrite = 1'b1;
		end else if (instruction[31:21] == 11'b11111000000) begin // STUR
			RdtoReg = 1'b1;
			RegALU = 2'b10;
			WrEn = 1'b1;
		end 
	end
endmodule 