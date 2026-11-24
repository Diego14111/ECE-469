// Instruction ROM.  Supports reads only, but is initialized based upon the file specified.
// All accesses are 32-bit.  Addresses are byte-addresses, and must be word-aligned (bottom
// two words of the address must be 0).
//
// Default program. Simulation can override it with +BENCHMARK=<file.arm>.
`define BENCHMARK "./test01_AddiB.arm"
//`define BENCHMARK "./test02_AddsSubs.arm"
//`define BENCHMARK "./test03_CbzB.arm"
//`define BENCHMARK "./test04_LdurStur.arm"
//`define BENCHMARK "./test05_Blt.arm"
//`define BENCHMARK "./test06_BlBr.arm"
//`define BENCHMARK "./test10_forwarding.arm"
//`define BENCHMARK "./test11_Sort.arm"
//`define BENCHMARK "./test12_Fibonacci.arm"

`timescale 1ns/10ps

// How many bytes are in our memory?  Must be a power of two.
`define INSTRUCT_MEM_SIZE		1024
	
module instructmem (
	input		logic		[63:0]	address,
	output	logic		[31:0]	instruction,
	input		logic					clk	// Memory is combinational, but used for error-checking
	);

	// Force %t's to print in a nice format.
	initial $timeformat(-9, 2, " ns", 10);

	// Make sure size is a power of two and reasonable.
	initial assert((`INSTRUCT_MEM_SIZE & (`INSTRUCT_MEM_SIZE-1)) == 0 && `INSTRUCT_MEM_SIZE > 4);
	
	// Make sure accesses are reasonable.
	always_ff @(posedge clk) begin
		if (address !== 'x) begin // address or size could be all X's at startup, so ignore this case.
			assert(address[1:0] == 0);	// Makes sure address is aligned.
			assert(address + 3 < `INSTRUCT_MEM_SIZE);	// Make sure address in bounds.
		end
	end
	
	// The data storage itself.
	logic [31:0] mem [`INSTRUCT_MEM_SIZE/4-1:0];
	
	// Simulation-only override; synthesis still sees the constant default file.
	// synthesis translate_off
	string benchmark_file;
	integer benchmark_fd;
	logic benchmark_override;
	// synthesis translate_on
	initial begin
		// synthesis translate_off
		benchmark_file = `BENCHMARK;
		benchmark_override = $value$plusargs("BENCHMARK=%s", benchmark_file);
		benchmark_fd = $fopen(benchmark_file, "r");
		if (benchmark_fd == 0) $fatal(1, "Cannot open benchmark: %s", benchmark_file);
		$fclose(benchmark_fd);
		if (benchmark_override) begin
			$readmemb(benchmark_file, mem);
		end else begin
		// synthesis translate_on
			$readmemb(`BENCHMARK, mem);
		// synthesis translate_off
		end
		$display("Running benchmark: %s", benchmark_file);
		// synthesis translate_on
	end
	
	// Handle the reads.
	integer i;
	always_comb begin
		if (address + 3 >= `INSTRUCT_MEM_SIZE)
			instruction = 'x;
		else
			instruction = mem[address/4];
	end
		
endmodule

module instructmem_testbench ();

	parameter ClockDelay = 5000;

	logic		[63:0]	address;
	logic					clk;
	logic		[31:0]	instruction;
	
	instructmem dut (.address, .instruction, .clk);
	
	initial begin // Set up the clock
		clk <= 0;
		forever #(ClockDelay/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
		// Read every location, including just past the end of the memory.
		for (i=0; i <= `INSTRUCT_MEM_SIZE; i = i + 4) begin
			address <= i;
			@(posedge clk); 
		end
		$stop;
		
	end
endmodule
