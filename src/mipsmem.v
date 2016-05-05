// Memory used by MIPS single-cycle processor

 module Data_memory(input 	clk, reset, write,
		input [31:0]	data_address, write_data,
		input		read,
		output[31:0]	read_data,
		output memoryReady);

// Wires between cache and main memory
wire load, evict, main_mem_ready, wait_access;
wire [31:0] load_address, evicted_address;
wire [127:0] load_block, evicted_block;

cache_wb cache (clk, reset, read, write, main_mem_ready, data_address, write_data, load_block, load_address, read_data, evicted_block, evicted_address, evict, load, memoryReady, wait_access);

main_memory DRAM (clk, reset, load, wait_access, load_address, load_block, evict, evicted_address, evicted_block, main_mem_ready);

endmodule


// Data memory implementation
module main_memory(input   clk, reset, read, wait_access,
            input   [31:0] read_address,            
            output reg [127:0] read_data,
            input          write,
            input   [31:0] write_address,
            input   [127:0] write_data,
            output reg     MemReady);

reg [127:0] RAM[268435455:0];
reg        running;
reg [4:0]  count;
reg [4:0] wait_load;
// Old read behavior
//assign read_data = RAM[read_address[31:2]];

always @(posedge clk) begin
	// Old write behavior

	if (reset) begin
		// Reset, init counter variables
		count <= 5'b00000;
		MemReady <= 1'b1;
		running <= 1'b0;
		read_data <= 32'h00000000;
		wait_load = 0;
	end
	else if (wait_access && !(running)) begin
		running <= 1'b1;
		count <= 5'b00001;
		MemReady <= 1'b0;
	end
	else if (running) begin
		if (count < 20) begin
			count = count + 1;
		end
		if (count == 20) begin
			if(wait_load > 0) begin
				running = 0;
				MemReady <= 1'b1;
				wait_load = 0;
			end else begin
				if (write) begin
					RAM[write_address[31:4]] <= write_data;
				end
				if (read) begin
					read_data <= RAM[read_address[31:4]];
				end
				MemReady <= 1'b0;
				wait_load = wait_load+1;
			end
		end
	end

end
            
endmodule


// Instruction memory (already implemented)
module Inst_memory(input   [5:0]  address,
            output  [31:0] read_data);

   (* ram_style = "block" *) reg [31:0] RAM[1023:0];

   initial
   begin
      $readmemh("cachetest.dat",RAM); // initialize memory with test program. Change this with memfile2.dat for the modified code
   end

  assign read_data = RAM[address]; // word aligned
endmodule

