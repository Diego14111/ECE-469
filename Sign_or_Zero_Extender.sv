`timescale 1ns/10ps
module Sign_or_Zero_Extender #(parameter WIDTH = 9) (Sign_Extended, bits, Enable);
	output logic [63:0] Sign_Extended;
	input logic [WIDTH-1:0] bits;
	input logic Enable;
	logic sign_bit;

	and #0.05 Zero_or_Sign (sign_bit, bits[WIDTH - 1], Enable); //if true it does sign extend if false it does a zero extend
	assign Sign_Extended[WIDTH - 1:0] = bits;

	// uses generate to extend the sign/zero bit
	genvar i;
	generate
		for(i = WIDTH; i < 64; i++) begin : sign_or_zero_extender
			assign Sign_Extended[i] = sign_bit;
		end
	endgenerate

endmodule

module Sign_or_Zero_Extender_testbench;
    parameter WIDTH = 6;
    logic [63:0] Sign_Extended;
    logic [WIDTH-1:0] bits;
    logic Enable;

    Sign_or_Zero_Extender #(.WIDTH(WIDTH)) dut (Sign_Extended, bits, Enable);

    initial begin
        Enable = 1; //Sign Extender active
        #100;
        bits = 6'b100000;
        #100;
        bits = 6'b011010;
        #100;
        Enable = 0; //Zero Extender active
        #100;
        bits = 6'b100000;
        #100;
        bits = 6'b011010;
        #100;
    end
endmodule