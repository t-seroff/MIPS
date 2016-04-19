module data_memory_tb();
reg clk, reset, write;
reg [31:0] address, write_data;
wire [31:0] Read_data;
Data_memory uut(clk, write, address, write_data, Read_data);

reg [31:0] RAM[63:0];
wire correct;

initial begin
	clk = 1;
	reset = 1;
	#12
	//perform some writes
	for(address = 0; address < 64; address = address + 4) begin
		write_data = $random;
		write = 1;
		RAM[address[31:2]] = write_data;
		
		#10;
	end
	write = 0;
	for(address = 0; address < 64; address = address + 4) begin
		#10;
	end
	$stop;
end

assign correct = (Read_data == RAM[address[31:2]]);

always #5 clk <= ~clk;

endmodule
