`timescale 1ns/10ps
module ALU_Add (result, overflow, carry_out, A, B);
	output logic [63:0] result;
	output logic overflow, carry_out;
	input logic [63:0] A, B;
	logic [64:0] Cin;
	logic op2;
	
	assign Cin[0] = 0;
	
	genvar i;
	generate
		for(i = 0; i < 64; i++) begin : ADDER
			Adder add1 (result[i], Cin[i + 1], A[i], B[i], Cin[i]);
		end
	endgenerate
	
	or #0.05 Carry_out_cheracker (carry_out, Cin[64], 0);
	xor #0.05 Overflow_checker (overflow, Cin[64], Cin[63]);
	
endmodule


module ALU_Add_testbench;
    logic [63:0] result;
    logic overflow, carry_out, negative, zero;
    logic [63:0] A, B;

    ALU_Add dut (result, overflow, carry_out, A, B);

    assign zero = ~|result;

    initial begin
        A = 64'h0000000000000000;
        B = 64'hFFFFFFFFFFFFFFFF;
        #20000;

        if ((result == (A + B)) && (zero == 0) && (carry_out == 0) && (overflow == 0))
            $display("Pass_1");
        else
            $display("Fail_1");

        A = 64'h7C3AED91B6F248D5;
        B = 64'h7C3AED91B6F248D5;
        #20000;

        if ((result == (A + B)) && (zero == 0) && (carry_out == 0) && (overflow == 1))
            $display("Pass_2");
        else
            $display("Fail_2");

        A = 64'h0123456789ABCDEF;
        B = 64'hA15F09C3E8724B6D;
        #20000;

        if ((result == (A + B)) && (zero == 0) && (carry_out == 0) && (overflow == 0))
            $display("Pass_3");
        else
            $display("Fail_3");

        A = 64'hFFFFFFFFFFFFFFFF;
        B = 64'h55AA55AA55AA55AA;
        #20000;

        if ((result == (A + B)) && (zero == 0) && (carry_out == 1) && (overflow == 0))
            $display("Pass_4");
        else
            $display("Fail_4");

        A = 64'h8000000000000000;
        B = 64'hFFFFFFFFFFFFFFFF;
        #20000;

        if ((result == (A + B)) && (zero == 0) && (carry_out == 1) && (overflow == 1))
            $display("Pass_5");
        else
            $display("Fail_5");

        $finish;
    end
endmodule
 