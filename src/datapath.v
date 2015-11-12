// Datapath modules

// Register file
module regfile(	input reg clk,
		input reg we3,
		input reg [4:0] ra1, ra2, wa3,
		input reg [31:0] wd3,
		output [31:0] rd1, rd2);
reg [31:0] rf [31:0];

always @ (posedge clk) begin
	if (we3) begin
		rf[wa3] <= wd3;
	end
end

assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule

// Adder
module adder(	input reg [31:0] a, b,
		output [31:0] y);
assign y = a + b;
endmodule

// Bitshift left by 2
module sl2(	input reg [31:0] a,
		output [31:0] y);
assign y = {a[29:0], 2'b00};
endmodule

// Sign extension
module signext(	input reg [15:0] a,
		output [31:0] y);
assign y = {{16{a[15]}}, a};
endmodule

// Variable-width resettable flip-flop
module reset_ff #(parameter WIDTH = 8)(
		input reg clk, reset,
		input reg [(WIDTH-1):0] d,
		output reg [(WIDTH-1):0] q);
always @ (posedge clk, posedge reset)
	if (reset) begin
		q <= 0;
	end
	else begin
		q <= d;
	end
endmodule

// Variable-width 2:1 multiplexer
module mux2 #(parameter WIDTH = 8)(
		input reg [(WIDTH-1):0] d0,
		input reg [(WIDTH-1):0] d1,
		input reg s,
		output [(WIDTH-1):0] y);
assign y = s ? d1 : d0;
endmodule

// ADDED: zero extension module for ori operation
module zeroext(	input reg [15:0] a,
		output [31:0] y);
assign y = {16'b0000000000000000, a};
endmodule
