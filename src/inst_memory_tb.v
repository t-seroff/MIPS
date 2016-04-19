module inst_memory_tb(output correct);
reg [5:0] address;
wire [31:0] Read_data;
Inst_memory uut(address, Read_data);

reg [31:0] RAM[63:0];

initial begin
	//read same file Inst_memory is initialized with
	$readmemh("memfile.dat",RAM);
	//confirm all reads are equal
	for(address = 0; address < 32; address = address + 1) begin
		#10;
	end
	$stop;
end

assign correct = Read_data == RAM[address];

endmodule
