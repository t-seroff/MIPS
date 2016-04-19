// External memories used by MIPS single-cycle processor

// Data memory implementation
module Data_memory(input          clk, write,
            input   [31:0] address, write_data,
            output  [31:0] Read_data);

 (* ram_style = "block" *) reg [31:0] RAM[63:0];
assign Read_data = RAM[address[31:2]];
always @(posedge clk) begin
	if (write) begin
		RAM[address[31:2]] <= write_data;
	end
end
            
endmodule


// Instruction memory (already implemented)
module Inst_memory(input   [5:0]  address,
            output  [31:0] Read_data);

   (* ram_style = "block" *) reg [31:0] RAM[63:0];

  //initial
   // begin
   //   $readmemh("memfile.dat",RAM); // initialize memory with test program. Change this with memfile2.dat for the modified code
   // end

  assign Read_data = RAM[address]; // word aligned
endmodule

