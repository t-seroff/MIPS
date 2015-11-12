// ALU from Lab 1 - unmodified
module alu(input [31:0] a, b, input [2:0] f, output [31:0] y, output zero);

reg [31:0] addB;	// signal fed to full adder
wire [31:0] addY;	// number from full adder
wire [31:0] aandb;	// A & (~)B
wire [31:0] aorb;	// A | (~)B
wire [31:0] asltb;	// A SLT B

fullAdder FA(a, addB, f[2], addY);

// Bitwise operations
assign aandb = (a & addB);
assign aorb = (a | addB);

// SLT from sign bit of adder result, zero extend
assign asltb[31:1] = 31'b0000000000000000000000000000000;
assign asltb[0] = (addY[31] == 1);

// Buffer for output
reg[31:0] y_out;
assign y = y_out;

// Maps B/~B as appropriate, output to correct function result
always @ * begin
case(f[2])
	0: addB = b;
	1: addB = ~b;
	default: addB = 32'h00000000;
endcase
case(f)
	0: y_out = aandb; 
	1: y_out = aorb;
	2: y_out = addY;
	4: y_out = aandb;
	5: y_out = aorb;
	6: y_out = addY;
	7: y_out = asltb;
	default: y_out = 32'h00000000;
endcase
end
assign zero = (y == 32'h00000000); // If output is zero, toggle zero
endmodule 

module fullAdder(input [31:0] a, b, input cin, output [31:0] y);
	assign y = a + b + cin;
endmodule