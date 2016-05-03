// External memories used by MIPS single-cycle processor

// Data memory implementation
module Data_memory(input          clk, reset, write,
            input   [31:0] address, write_data,
            output  [31:0] Read_data,
            output reg     MemReady);

 (* ram_style = "block" *) reg [31:0] RAM[63:0];
reg [31:0] oldAddress;
reg [4:0]  count;

// Old read behavior
assign Read_data = RAM[address[31:2]];

//assign MemReady = 1'b1;
reg hasWritten;

always @(posedge clk) begin
	// Old write behavior
	if (write) begin
		RAM[address[31:2]] <= write_data;
	end

	if (reset) begin
		// Reset, init counter variables
		oldAddress <= 32'h00000000;
		count <= 5'b00000;
		MemReady <= 1'b0;
	end
	else if (address != oldAddress) begin
		// Address has changed, count up 20
		oldAddress <= address;
		count <= 5'b00001;
		MemReady <= 1'b0;
	end
	if (!reset) begin
		if (count < 20) begin
			count <= count + 1;
		end
		if (count == 20) begin
			MemReady <= 1'b1;

			// MORE REALISTIC R/W BEHAVIOR
			//Read_data <= RAM[address[31:2]];
			//if (write) begin
			//	RAM[address[31:2]] <= write_data;
			//end
		end
	end

end
            
endmodule


// Instruction memory (already implemented)
module Inst_memory(input   [5:0]  address,
            output  [31:0] Read_data);

   (* ram_style = "block" *) reg [31:0] RAM[63:0];

   initial
   begin
      $readmemh("memfile.dat",RAM); // initialize memory with test program. Change this with memfile2.dat for the modified code
   end

  assign Read_data = RAM[address]; // word aligned
endmodule

