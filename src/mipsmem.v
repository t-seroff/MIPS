// External memories used by MIPS single-cycle processor

// Todo: Implement data memory
module dmem(input          clk, we,
            input   [31:0] a, wd,
            output  [31:0] rd);

// **PUT YOUR CODE HERE**
            
endmodule


// Instruction memory (already implemented)
module imem(input   [5:0]  a,
            output  [31:0] rd);

  reg [31:0] RAM[63:0];

  initial
    begin
      $readmemh("memfile.dat",RAM); // initialize memory with test program. Change this with memfile2.dat for the modified code
    end

  assign rd = RAM[a]; // word aligned
endmodule

