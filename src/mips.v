// Single-cycle MIPS processor
// Instantiates a controller and a datapath module

module mips(input          clk, reset,
            output  [31:0] pc,
            input   [31:0] instr,
            output         memwrite,
            output  [31:0] aluout, writedata,
            input   [31:0] readdata);

  wire        memtoreg, branch,
               pcsrc, zero,
               alusrc, regdst, regwrite, jump;
  wire [2:0]  alucontrol;

  // ADDED: wire for zeroExtend signal
  wire zeroExtend;

  // ADDED: zeroExtend output from controller, input to datapath
  controller c(instr[31:26], instr[5:0], zero,
               memtoreg, memwrite, pcsrc,
               alusrc, regdst, regwrite, jump,
               alucontrol, zeroExtend);
  datapath dp(clk, reset, memtoreg, pcsrc,
              alusrc, regdst, regwrite, jump,
              alucontrol,
              zero, pc, instr,
              aluout, writedata, readdata, zeroExtend);
endmodule


// Controller module
module controller(input   [5:0] op, funct,
                  input         zero,
                  output        memtoreg, memwrite,
                  output        pcsrc, alusrc,
                  output        regdst, regwrite,
                  output        jump,
                  output  [2:0] alucontrol,
		   output zeroExtend); // ADDED: ZeroExtend output to datapath

wire [1:0] aluop;
wire branch;
wire branchNot; // ADDED: branchNot signal for bne operation

// ADDED: zeroExtend output from main decoder
mainDecoder dec(op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump, aluop, branchNot, zeroExtend);
aluDecoder aluDec(funct, aluop, alucontrol);

// Modification for branchNot here
wire zeroOut;
wire zeroNot;
not zeroNotGate(zeroNot, zero);
mux2 #(1) branchMux(zero, zeroNot, branchNot, zeroOut);
assign pcsrc = branch & zeroOut; // Changed from branch & zero

endmodule


// Datapath
module datapath(input          clk, reset,
                input          memtoreg, pcsrc,
                input          alusrc, regdst,
                input          regwrite, jump,
                input   [2:0]  alucontrol,
                output         zero,
                output  [31:0] pc,
                input   [31:0] instr,
                output  [31:0] aluout, writedata,
                input   [31:0] readdata,
		 input zeroExtend);	// ADDED: zeroExtend input from controller

wire [4:0] writereg;
wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
wire [31:0] signimm, signimmsh;
wire [31:0] srca, srcb;
wire [31:0] result;

// Determine next PC
reset_ff #(32) pcreg(clk, reset, pcnext, pc);
adder pcadd1(pc, 32'b100, pcplus4);
sl2 immsh(signimm, signimmsh);
adder pcadd2(pcplus4, signimmsh, pcbranch); 
mux2 #(32) pcbrmuc(pcplus4, pcbranch, pcsrc, pcnextbr);
wire [31:0] pcmuxd0;
assign pcmuxd0[31:0] = {pcplus4[31:28], instr[25:0], 2'b00};
mux2 #(32) pcmux(pcnextbr, pcmuxd0, jump, pcnext);

// Register file
regfile rf(clk, regwrite, instr[25:21], instr[20:16], writereg, result, srca, writedata);
mux2 #(5) wrmux(instr[20:16], instr[15:11], regdst, writereg);
mux2 #(32) resmux(aluout, readdata, memtoreg, result);
signext se(instr[15:0], signimm);

// ADDED: logic for zeroExtend
wire [31:0] zeroImm;
zeroext zext(instr[15:0], zeroImm);
wire [31:0] immOut;
mux2 #(32) immMux(signimm, zeroImm, zeroExtend, immOut);

// ALU
// ADDED: changed signimm to immOut to get signal from mux
mux2 #(32) srcbmux(writedata, immOut, alusrc, srcb); 
alu alu(srca, srcb, alucontrol, aluout, zero);

endmodule

