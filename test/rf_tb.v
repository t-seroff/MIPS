module rf_tb();
reg clk, write, reset;
reg[4:0] PR1, PR2, WR;
reg [31:0] WD;
wire[31:0] RD1, RD2;
regfile uut(clk, write,reset, PR1, PR2, WR, WD, RD1, RD2);


initial begin
	clk <= 1;
	reset <= 1;
	write <= 0;
	#12
	reset <= 0;
	
	WR <= 5;
	write <= 1;
	WD <= $random;
	#10
	WR <= 10;
	write <= 1;
	WD <= $random;
	#10
	write <= 0;

	PR1 <= 5;
	PR2 <= 10;
	#20 $stop;
end

always #5 clk <= ~clk;

endmodule 
