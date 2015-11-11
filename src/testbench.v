
module testbench;
reg clk;
reg reset;
top topModule(clk, reset);
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
		#10
		clk = 1;
		#10
		clk = 0;
	end
end

endmodule 