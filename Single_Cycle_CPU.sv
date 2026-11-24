`timescale 1ns/10ps
module Single_Cycle_CPU(clk, reset);
	input logic reset, clk;
	logic [31:0] instruction;
	logic [63:0] PC, next_PC, Null;
	assign Null = 64'b0;

	//Control Logic
	logic BL, RdtoReg, WrEn, RegWrite, RdtoPC, Flag_enable, Read_enable;
	logic [1:0] RegALU, memtoReg, to_PC;
	logic [2:0] ALU_OP;
	logic zero, negative, overflow, carry_out;
	logic new_overflow, old_overflow;
	logic new_negative, old_negative;
	logic new_zero, old_zero, new_carry_out, old_carry_out;
	Control_Logic C1 (ALU_OP, RegALU, memtoReg, to_PC, Flag_enable, BL, RdtoReg, WrEn, Read_enable, RegWrite, RdtoPC, instruction, zero, old_negative, old_overflow);

	//uses a mux and flag enable to determine if it should update the overflow bit and store it in a flipflop to save it incase a later instruction needs to access it
	mux_2by1 #(1) overflow_mux (new_overflow, Flag_enable, old_overflow, overflow, 1'b1); //muxes the old zero (aka the zero that we have saved in the flipflop and if the flag is anabled then the newone gets passed into the new flag)
	D_FF overflow_flip_flop (old_overflow, new_overflow, reset, clk); //saves the new flag into a flip flop incase its needed later

	mux_2by1 #(1) negative_mux (new_negative, Flag_enable, old_negative, negative, 1'b1);
	D_FF negative_flip_flop (old_negative, new_negative, reset, clk);

	// Retain all four ADDS/SUBS flags through later instructions.
	mux_2by1 #(1) zero_mux (new_zero, Flag_enable, old_zero, zero, 1'b1);
	D_FF zero_flip_flop (old_zero, new_zero, reset, clk);
	
	mux_2by1 #(1) carry_mux (new_carry_out, Flag_enable, old_carry_out, carry_out, 1'b1);
	D_FF carry_flip_flop (old_carry_out, new_carry_out, reset, clk);

	//Register file to store and access the register
	logic [4:0]  Rd, Rn, Rm, Aa, Ab, Aw;
	logic [63:0] Da, Db, Dw;
	assign Rd = instruction[4:0];
	assign Rn = instruction[9:5];
	assign Rm = instruction[20:16];
	assign Aa = Rn;
	mux_2by1 #(5) Mux1 (Aw, BL, Rd, 5'd30, 1'b1);
	mux_2by1 #(5) Mux2 (Ab, RdtoReg, Rm, Rd, 1'b1);
	regfile REGFILE (Da, Db, Dw, Aa, Ab, Aw, RegWrite, clk);

	//-------------------------------Instructions DATA path ---------------------------------------------------------------
	instructmem Instructions (PC, instruction, clk);
	logic [25:0] Imm26;
	logic [27:0] Imm26_Shifted;
	logic [63:0] Sign_Extended_Imm26;
	assign Imm26 = instruction[25:0];
	// Reserve two extra bits, shift, then sign-extend as in the lab specification.
	Shifter #(28, 2) Shift_1 (Imm26_Shifted, {2'b00, Imm26});
	Sign_or_Zero_Extender #(28) Sing_2 (Sign_Extended_Imm26, Imm26_Shifted, 1'b1);

	logic [18:0] Imm19;
	logic [20:0] Imm19_Shifted;
	logic [63:0] Sign_Extended_Imm19;
	assign Imm19 = instruction[23:5];
	Shifter #(21, 2) Shift_2 (Imm19_Shifted, {2'b00, Imm19});
	Sign_or_Zero_Extender #(21) Sing_3 (Sign_Extended_Imm19, Imm19_Shifted, 1'b1);

	logic [63:0] to_PC_Result;
	mux_4by1 #(64) Mux5 (to_PC_Result, to_PC, 64'd4, Sign_Extended_Imm26, Sign_Extended_Imm19, Null);

	logic Carry_Null_1;
	logic Overflow_Null_1;
	logic [63:0] Adder_out_1;
	ALU_Add Adder_1 (Adder_out_1, Overflow_Null_1, Carry_Null_1, PC, to_PC_Result);

	mux_2by1 #(64) mux_6 (next_PC, RdtoPC, Adder_out_1, Db, 1'b1);

	logic Carry_Null_2;
	logic Overflow_Null_2;
	logic [63:0] Adder_out_2;
	ALU_Add Adder_2 (Adder_out_2, Overflow_Null_2, Carry_Null_2, PC, 64'd4); //PC = PC + 4 and goes into register X30 if the signal is on

	//saves the instructions in flip flops and updates the PC instructions every time a instruction is ran and it needs to update
	genvar i;
	generate
		for(i = 0; i < 64 ; i++) begin : PC_Update
			D_FF P_C (PC[i], next_PC[i], reset, clk);
		end
	endgenerate

	//--------------------------------------------- DATA path ---------------------------------------------------------------

	//extending sign bits for Imm12
	logic [11:0] Imm12;
	logic [63:0] Imm12_Zero_Extended;
	assign Imm12 = instruction[21:10];
	Sign_or_Zero_Extender #(12) Sign (Imm12_Zero_Extended, Imm12, 1'b0);

	//extending 0 bits for Imm9
	logic [8:0] Imm9;
	logic [63:0] Imm9_Sign_Extended;
	assign Imm9  = instruction[20:12];
	Sign_or_Zero_Extender #(9) Sign_1 (Imm9_Sign_Extended, Imm9, 1'b1);

	logic [63:0] RegALU_Result;
	mux_4by1 #(64) Mux3 (RegALU_Result, RegALU, Db, Imm12_Zero_Extended, Imm9_Sign_Extended, Null);

	//Executes in ALU
	logic [63:0] ALU_out;
	alu ALU1 (ALU_out, negative, zero, overflow, carry_out, Da, RegALU_Result, ALU_OP);

	//Memory for the LDUR/Stur to write into or take out data
	logic [63:0] read_data;
	datamem meme (.address(ALU_out), .write_enable(WrEn), .read_enable(Read_enable), .write_data(Db), .clk(clk), .xfer_size(4'b1000), .read_data(read_data));

	//to Rd register
	mux_4by1 #(64) Mux4 (Dw, memtoReg, ALU_out, read_data, Adder_out_2, Null); //memtoReg Mux

endmodule

module Single_Cycle_CPU_testbench();
	parameter ClockDelay = 100;
	parameter MaxCycles = 10000;
	logic clk, reset;
	logic done = 0, passed = 0;
	logic halted = 0, checks_available = 0;
	integer cycles = 0, errors = 0;
	integer i;
	string benchmark_name;
	logic [63:0] executing_pc;
	logic [31:0] executing_instruction;

	Single_Cycle_CPU dut (.clk, .reset);

	initial begin
		clk = 0;
		// Let run -all return naturally when the test has completed.
		while (!done) begin
			#(ClockDelay/2);
			if (!done) clk = ~clk;
		end
	end

	task automatic check_reg(input integer index, input logic [63:0] expected);
		if (dut.REGFILE.data_out[index] !== expected) begin
			errors++;
			$display("FAIL X%0d: expected %0d, got %0d", index,
				$signed(expected), $signed(dut.REGFILE.data_out[index]));
		end
	endtask

	task automatic check_mem(input integer address, input logic [63:0] expected);
		logic [63:0] actual;
		integer byte_index;
		for (byte_index = 0; byte_index < 8; byte_index++)
			actual[8*byte_index +: 8] = dut.meme.mem[address + byte_index];
		if (actual !== expected) begin
			errors++;
			$display("FAIL Mem[%0d]: expected %0d, got %0d", address,
				$signed(expected), $signed(actual));
		end
	endtask

	task automatic check_results;
		checks_available = 1;
		check_reg(31, 64'd0);
		if (benchmark_name == "test01_AddiB.arm" || benchmark_name == "./test01_AddiB.arm") begin
			for (integer n = 0; n < 5; n++) check_reg(n, n);
		end
		else if (benchmark_name == "test02_AddsSubs.arm" || benchmark_name == "./test02_AddsSubs.arm") begin
			check_reg(0, 1); check_reg(1, -64'sd1); check_reg(2, 2);
			check_reg(3, -64'sd3); check_reg(4, -64'sd2); check_reg(5, -64'sd5);
			check_reg(6, 0); check_reg(7, -64'sd6);
			if ({dut.old_negative, dut.old_zero, dut.old_overflow, dut.old_carry_out} !== 4'b1001) begin
				errors++;
				$display("FAIL stored flags: expected NZVC = 1001");
			end
		end
		else if (benchmark_name == "test03_CbzB.arm" || benchmark_name == "./test03_CbzB.arm") begin
			check_reg(0, 1); check_reg(1, 0); check_reg(2, 0);
			check_reg(3, 1); check_reg(4, 31); check_reg(5, 0);
		end
		else if (benchmark_name == "test04_LdurStur.arm" || benchmark_name == "./test04_LdurStur.arm") begin
			check_reg(0, 1); check_reg(1, 2); check_reg(2, 3); check_reg(3, 8);
			check_reg(4, 11); check_reg(5, 1); check_reg(6, 2); check_reg(7, 3);
			check_mem(0, 1); check_mem(8, 2); check_mem(16, 3);
		end
		else if (benchmark_name == "test05_Blt.arm" || benchmark_name == "./test05_Blt.arm") begin
			check_reg(0, 1); check_reg(1, 1);
		end
		else if (benchmark_name == "test06_BlBr.arm" || benchmark_name == "./test06_BlBr.arm") begin
			check_reg(0, 1); check_reg(1, 0); check_reg(2, 0); check_reg(3, 1);
			check_reg(4, 52); check_reg(5, 64); check_reg(29, 20); check_reg(30, 68);
		end
		else if (benchmark_name == "test10_forwarding.arm" || benchmark_name == "./test10_forwarding.arm") begin
			check_reg(0, 0); check_reg(1, 8); check_reg(2, 0); check_reg(3, 5);
			check_reg(4, 7); check_reg(5, 2); check_reg(6, -64'sd2); check_reg(7, -64'sd2);
			check_reg(8, 0); check_reg(9, 1); check_reg(10, -64'sd4);
			check_reg(14, 5); check_reg(15, 8); check_reg(16, 9); check_reg(17, 1); check_reg(18, 99);
			check_mem(0, 8); check_mem(8, 5);
		end
		else if (benchmark_name == "test11_Sort.arm" || benchmark_name == "./test11_Sort.arm") begin
			for (integer n = 0; n < 10; n++) begin
				check_reg(11+n, n+1);
				check_mem(8*n, n+1);
			end
		end
		else if (benchmark_name == "test12_Fibonacci.arm" || benchmark_name == "./test12_Fibonacci.arm") begin
			check_reg(0, 6); check_reg(1, 8); check_reg(28, 8); check_reg(30, 196);
		end
		else checks_available = 0;
	endtask

	initial begin
		reset = 1;
		repeat (2) @(posedge clk);
		@(negedge clk);
		reset = 0;
		benchmark_name = dut.Instructions.benchmark_file;
		if ($value$plusargs("TEST_NAME=%s", benchmark_name)) begin end

		// Only a known B-to-self instruction is a halt; an unknown PC is a failure.
		while (!halted && errors == 0 && cycles < MaxCycles) begin
			@(posedge clk);
			executing_pc = dut.PC;
			executing_instruction = dut.instruction;
			if (!$isunknown(executing_pc) && executing_instruction === 32'h14000000 &&
					dut.next_PC === executing_pc) halted = 1;
			#1;
			cycles++;
			if ($isunknown(dut.PC) || $isunknown(dut.instruction)) begin
				errors++;
				$display("FAIL: unknown PC or instruction at cycle %0d", cycles);
			end
		end
		if (!halted && errors == 0) begin
			errors++;
			$display("FAIL: exceeded MaxCycles = %0d", MaxCycles);
		end
		if (halted && errors == 0) check_results();

		$display("Stored flags: N=%b Z=%b V=%b C=%b",
			dut.old_negative, dut.old_zero, dut.old_overflow, dut.old_carry_out);
		for (i = 0; i < 32; i++)
			$display("X%0d = %0d (0x%h)", i, $signed(dut.REGFILE.data_out[i]), dut.REGFILE.data_out[i]);
		for (i = 0; i < 1024; i += 8)
			if (dut.meme.mem[i] !== 8'bx)
				$display("Mem[%0d] = %0d", i, $signed({
					dut.meme.mem[i+7], dut.meme.mem[i+6], dut.meme.mem[i+5], dut.meme.mem[i+4],
					dut.meme.mem[i+3], dut.meme.mem[i+2], dut.meme.mem[i+1], dut.meme.mem[i]}));
		passed = halted && errors == 0 && checks_available;
		done = 1;
		if (passed)
			$display("RESULT: PASS benchmark=%s cycles=%0d PC=%0d", benchmark_name, cycles, dut.PC);
		else if (halted && errors == 0 && !checks_available)
			$display("RESULT: UNVERIFIED benchmark=%s cycles=%0d PC=%0d (add expected results to check_results)", benchmark_name, cycles, dut.PC);
		else
			$display("RESULT: FAIL benchmark=%s cycles=%0d PC=%0d errors=%0d", benchmark_name, cycles, dut.PC, errors);
		// done stops the clock; no breakpoint or simulator exit is needed.
	end
endmodule
// alu (result, negative, zero, overflow, carry_out, A, B, cntrl);
// regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);
// mux_4by1 (out, sel, D0, D1, D2, D3);
// mux_2by1 (out, Sel, D0, D1);
// datamem (address, write_enable, write_data, clk, xfer_size, read_data);
