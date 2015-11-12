// Testbench for MIPS processor
// Issues reset signal then cycles clock repeatedly
module tb;
reg clk;
reg reset;
top topModule(clk, reset); // Instantiate MIPS top module
reg i;

initial begin
	clk = 0;
	reset = 0;
	#10;
	reset = 1;
	clk = 1;
	#10
	reset = 0;
	clk = 0;
	for (i = 0; i < 16; i = i + 1) begin
		// Cycle clock
		#10
		clk = 1;
		#10
		clk = 0;
	end
end

endmodule 