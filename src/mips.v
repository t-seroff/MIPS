// Pipelined MIPS processor
// instantiates a controller, datapath module and hazard control unit

module mips(input          clk, reset,		// From testbench, to data path
            output  [31:0] PCF,			// To instruction memory, from datapath
            input   [31:0] InstrF,			// From instruction memory, to datapath
            output         MemWriteM,			// To data memory, from datapath
            output  [31:0] ALUOutM, WriteDataM,	// To data memory, from datapath
            input   [31:0] ReadDataM, 		// From data memory, to datapath
            input          MemReady);			// From data memory, to datapath

  // Wires between everything
  wire BranchD;

  // Wires between control unit and datapath
  wire         RegWriteD, MemtoRegD, MemWriteD,
               ALUSrcD, RegDstD;
  wire [3:0]   ALUControlD;
  wire [31:0]  InstrD;
  wire startMultD, signedMultD;
  wire [1:0]   mfRegD;
  wire branchNE;
  //wire         MemWriteM;
  wire JumpD;

  controller c(InstrD[31:26], InstrD[5:0], 
               RegWriteD, MemtoRegD, MemWriteD,
               ALUControlD, ALUSrcD, RegDstD,
               BranchD, JumpD, startMultD, signedMultD, mfRegD, branchNE);
              
  // Wires between hazard/forwarding units and datapath
  wire MemtoRegE, RegWriteE;
  wire MemtoRegM, RegWriteM, RegWriteW;
  wire [4:0] RsD, RtD, RsE, RtE;
  wire [4:0] WriteRegE, WriteRegM, WriteRegW;
  wire StallF, StallD, FlushE;
  wire ForwardAD, ForwardBD;
  wire [1:0] ForwardAE, ForwardBE;
  wire multReady, startMultE;
  wire [1:0] mfRegE;
  wire StallE, StallM, FlushW;
  wire clrBufferD, FlushD;

  datapath dp(clk, reset, 
              RegWriteD, MemtoRegD, MemWriteD,	// from control unit
              ALUControlD, ALUSrcD, RegDstD,		// from control unit
              BranchD,                               // from control unit
              InstrD,					// to control unit
              PCF, InstrF,                           // to/from instruction memory
              ALUOutM, WriteDataM, 
              MemWriteM, ReadDataM,
              MemtoRegE, RegWriteE, MemtoRegM,
              RegWriteM, RegWriteW,
              RsD, RtD, RsE, RtE,
              WriteRegE, WriteRegM, WriteRegW,
              StallF, StallD, FlushE,
              ForwardAD, ForwardBD,
              ForwardAE, ForwardBE, JumpD,
	       startMultD, signedMultD, mfRegD,
	       multReady, mfRegE, startMultE, branchNE,
	       StallE, StallM, FlushW, clrBufferD, FlushD
              );    


  Hazard_detector hazard(clk, 
				BranchD,
				MemtoRegE,
				RegWriteE,
				MemtoRegM,
				RegWriteM,
				RegWriteW,
				RsD,
				RtD,
				RsE,
				RtE,
				WriteRegE,
				WriteRegM,
				WriteRegW,
				StallF,
				StallD,
				FlushE,
				multReady,
				mfRegD,
				startMultE,
				StallE,
				StallM,
				FlushW,
				MemReady,
				MemWriteM,
				clrBufferD,
				FlushD);
				
	Data_forwarding forward(clk, 
                    RegWriteM,
                    RegWriteW,
                    RsD,
                    RtD,
                    RsE,
                    RtE,
                    WriteRegM,
                    WriteRegW,
                    ForwardAD,
                    ForwardBD,
                    ForwardAE, 
                    ForwardBE);

   
endmodule


// Controller module
module controller(input   [5:0] op, funct,
                  output        RegWrite, MemtoReg,
                  output        MemWrite, 
                  output  [3:0] ALUControl,
                  output        ALUSrc, RegDst,
                  output        branch,
		   output 	  jump,
		   output        startMult, signedMult, 
		   output  [1:0] mfReg,
			output branchNE);

wire [3:0] aluop;

mainDecoder dec(op, MemtoReg, MemWrite, branch, ALUSrc, RegDst, RegWrite, jump, aluop, branchNE);
aluDecoder aluDec(funct, aluop, ALUControl, startMult, signedMult, mfReg);

// assuming that "branch" from single-cycle decoder equivalent to branchD in pipelined
endmodule


// Datapath
module datapath(input          clk, reset,
                input          RegWriteD, MemtoRegD,         
                input          MemWriteD,
                input   [3:0]  ALUControlD,
                input          ALUSrcD, RegDstD,
                input          BranchD,
                output  [31:0] InstrD,
                output  [31:0] PCF,
                input   [31:0] InstrF,
                output  [31:0] ALUOutM, WriteDataM,
                output         MemWriteM,
                input   [31:0] ReadDataM,
		 output MemtoRegE,
		 output RegWriteE,
		 output MemtoRegM,
		 output RegWriteM,
		 output RegWriteW,
		 output [4:0] RsD,
		 output [4:0] RtD,
		 output [4:0] RsE,
		 output [4:0] RtE,
		 output [4:0] WriteRegE,
		 output [4:0] WriteRegM,
		 output [4:0] WriteRegW,
		 input StallF,
		 input StallD,
		 input FlushE,
		 input ForwardAD,
		 input ForwardBD,
		 input [1:0] ForwardAE, 
		 input [1:0] ForwardBE,
		 input JumpD,
		 input startMultD, signedMultD, 
		 input [1:0] mfRegD,
		 output multReady,
		 output [1:0] mfRegE,
		 output startMultE,
		 input branchNE,
		 input StallE,
		 input StallM,
		 input FlushW,
		 output clrBufferD,
		 input FlushD);


// FETCH STAGE
wire PCSrcD;
wire [31:0] PCPlus4F, PCbranchD;
wire [31:0] PCnext, PCnotjump;
wire [31:0] PCJump;

mux2 #(32) PCmux(PCPlus4F, PCbranchD, PCSrcD, PCnotjump);
mux2 #(32) PCJumpmux(PCnotjump, PCJump, JumpD, PCnext);

wire notStallF;
not stallFnot(notStallF, StallF);
reset_enable_ff #(32) PCreg(clk, reset, notStallF, PCnext, PCF); 

// PCF goes out to instruction memory, InstrF comes back from instruction memory
adder PCadd1(PCF, 32'b100, PCPlus4F);



// DECODE STAGE
wire [31:0] PCPlus4D;

wire notStallD;
not stallDnot(notStallD, StallD);

assign clrBufferD = PCSrcD | JumpD;

decode_buffer bufferD(clk, reset, FlushD, notStallD, InstrF, PCPlus4F, InstrD, PCPlus4D);

wire [31:0] ResultW;
wire [31:0] RD1D, RD2D;
wire [31:0] SignImmD, SignImmshD;
wire [31:0] RD1muxed, RD2muxed;
wire EqualD, EqualOrNotEqualD;

regfile rf(clk, RegWriteW, reset, InstrD[25:21], InstrD[20:16], WriteRegW, ResultW, RD1D, RD2D);
signext se(InstrD[15:0], SignImmD);
sl2 immsh(SignImmD, SignImmshD);
adder PCadd2(PCPlus4D, SignImmshD, PCbranchD); 

// Determine if branching:
mux2 #(32) PCmuxRD1(RD1D, ALUOutM, ForwardAD, RD1muxed);
mux2 #(32) PCmuxRD2(RD2D, ALUOutM, ForwardBD, RD2muxed);

// For Jump
assign PCJump = {PCPlus4D[31:28], InstrD[25:0], 2'b00};

equality equals(RD1muxed, RD2muxed, EqualD);
assign EqualOrNotEqualD = (branchNE) ? ~EqualD : EqualD;
and PCsrcand(PCSrcD, BranchD, EqualOrNotEqualD);

assign RsD = InstrD[25:21];
assign RtD = InstrD[20:16];
assign RdD = InstrD[15:11];

// EXECUTE STAGE
wire         signedMultE;
//wire [1:0]  mfRegE;
//wire        RegWriteE, MemtoRegE; 
wire        MemWriteE, ALUSrcE, RegDstE;
wire [3:0]  ALUControlE;
wire [31:0] ALUOutE;
wire [31:0] RD1E, RD2E;
wire [31:0] SignImmE;
wire [4:0]  RdE;

wire notStallE;
not stallEnot(notStallE, StallE);

execute_buffer bufferE(clk, reset, FlushE, notStallE,
	startMultD, signedMultD, mfRegD,
	RegWriteD, MemtoRegD, MemWriteD, ALUControlD,
	ALUSrcD, RegDstD, RD1D, RD2D, InstrD[25:21], InstrD[20:16], InstrD[15:11], SignImmD,
	startMultE, signedMultE, mfRegE,
	RegWriteE, MemtoRegE, MemWriteE, ALUControlE,
	ALUSrcE, RegDstE, RD1E, RD2E, RsE, RtE, RdE, SignImmE);
	

wire [31:0] srcaE, srcbE, WriteDataE;
// wire [4:0] WriteRegE - will be output anyways

mux2 #(5) WriteRegEmux(RtE, RdE, RegDstE, WriteRegE);

mux4 #(32) srcaEmux(RD1E, ResultW, ALUOutM, 32'h00000000, ForwardAE, srcaE);
mux4 #(32) WriteDataEmux(RD2E, ResultW, ALUOutM, 32'h00000000, ForwardBE, WriteDataE);
mux2 #(32) srcbEmux(WriteDataE, SignImmE, ALUSrcE, srcbE);

wire [31:0] ALUOut;
alu alu(srcaE, srcbE, ALUControlE, ALUOut);

wire [63:0] MultOut;
multiplier mult(srcaE, srcbE, startMultE, signedMultE, clk, reset, MultOut, multReady);

mux4 #(32) resultMux(ALUOut, MultOut[31:0], MultOut[63:32], 32'h00000000, mfRegE, ALUOutE);

// MEMORY STAGE

wire notStallM;
not stallMnot(notStallM, StallM);

memory_buffer bufferM(clk, reset, notStallM,
	RegWriteE, MemtoRegE, MemWriteE, ALUOutE, WriteDataE, WriteRegE,
	RegWriteM, MemtoRegM, MemWriteM, ALUOutM, WriteDataM, WriteRegM);

// (nothing actually needed here!)



// WRITEBACK STAGE
wire        MemtoRegW;
wire [31:0] ReadDataW, ALUOutW;


writeback_buffer bufferW(clk, reset, FlushW,
	RegWriteM, MemtoRegM, ReadDataM, ALUOutM, WriteRegM,
	RegWriteW, MemtoRegW, ReadDataW, ALUOutW, WriteRegW);

mux2 #(32)  resultmux(ALUOutW, ReadDataW, MemtoRegW, ResultW);


endmodule



