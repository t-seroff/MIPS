module multiplier_tb();
wire [63:0] s;
wire ready;
reg reset;
reg [31:0] a, b;
reg start, clk, is_signed;

multiplier uut(a, b,start, is_signed, clk, reset, s,ready);


initial begin
	clk <= 1;
	reset <= 1;
	#12
	reset <= 0;

	//test multiplying small numbers unsigned
	a <= 32'd2003;
	b <= 32'd99;
	start <= 1;
	is_signed <= 0;
	#10
	start <= 0;
	#400

	//test multiplying large numbers unsigned
	a <= 32'd123456789;
	b <= 32'd987654321;
	start <= 1;
	is_signed <= 0;
	#10
	start <= 0;
	#400

	//test multiplying signed
	a <= -602;
	b <= 5;
	start <= 1;
	is_signed <= 1;
	#10
	start <= 0;
	#400

	//test multiplying large numbers signed 
	a <= 4352455;
	b <= 2342342;
	start <= 1;
	is_signed <= 1;
	#10
	start <= 0;
	#400
	$stop;

end

always #5 clk = ~clk;

endmodule
