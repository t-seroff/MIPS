// Top level system including MIPS and memories

module top(input clk, reset);

  wire [31:0] pc, readdata, instr;
  wire [31:0] writedata, dataadr;
  wire        memwrite;
  wire        MemReady;
  
  // processor and memories are instantiated here 
  (* dont_touch = "true" *) mips mips(clk, reset, pc, instr, memwrite, dataadr, writedata, readdata, MemReady);
  (* dont_touch = "true" *) Inst_memory imem(pc[7:2], instr);
  (* dont_touch = "true" *) Data_memory dmem(clk, reset, memwrite, dataadr, writedata, readdata, MemReady);

endmodule
