// External memories used by MIPS single-cycle processor

// Data memory implementation
module dmem(input          clk, we,
            input   [31:0] a, wd,
            output  [31:0] rd);

// 64 bit storage of 32-bit words
reg [31:0] RAM[63:0];

// Always read
assign rd = RAM[a[31:2]];

always @(posedge clk) begin
	// Write if enabled
	if (we) begin
		RAM[a[31:2]] <= wd;
	end
end
            
endmodule


// Instruction memory (already implemented)
module imem(input   [5:0]  a,
            output  [31:0] rd);

  reg [31:0] RAM[63:0];

  initial
    begin
      $readmemh("memfile2.dat",RAM); // Initialize memory with program
    end

  assign rd = RAM[a]; // word aligned
endmodule

