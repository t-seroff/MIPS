module hazard_tb();
reg clk,BranchD,MemtoRegE,RegWriteE,MemtoRegM,RegWriteM, RegWriteW;
reg [4:0] RsD,RtD, RsE, RtE, WriteRegE, WriteRegM,WriteRegW;
wire StallF,StallD,FlushE;
				  reg multReady;
				  reg[1:0] mfReg;
				  reg multStart;

Hazard_detector uut(clk,BranchD,MemtoRegE,RegWriteE,
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
				  multReady, mfReg,
				 multStart);

initial begin 
	clk <= 1;
	//lwstall
	WriteRegE <= 15;
	RsD <= 15;
	RegWriteE <= 1;
	BranchD <= 1; 
	#20
	RegWriteE <= 0;

	#10
	MemtoRegE <= 1;
	RtE <= 15;
	#20
	MemtoRegE <= 0;

	#10
	mfReg <= 2'b01;
	multStart <= 1;
	multReady <= 0;
	#20
	$stop;
end


always #5 clk <= ~clk;


endmodule

module forward_tb();
reg clk, RegWriteM, RegWriteW;
reg [4:0] RsD, RtD, RsE, RtE, WriteRegM, WriteRegW;
wire ForwardAD,ForwardBD;
wire [1:0] ForwardAE, ForwardBE;

Data_forwarding uut(clk,RegWriteM, RegWriteW, RsD, RtD, RsE, RtE, WriteRegM,WriteRegW, ForwardAD,ForwardBD,ForwardAE, ForwardBE);

initial begin 
	clk <= 1;
	//(RsE != 0) && (RsE == WriteRegM) && RegWriteM)
	//fwrd srca
	RsE <= 5;
	WriteRegM <= 5;
	RegWriteM <= 1;
	#20
	RegWriteM <= 0;

	#10
	//((RtE != 0) && (RtE == WriteRegW) && RegWriteW)
	//fwrd srcb
	RtE <= 6;
	WriteRegW <= 6;
	RegWriteW <= 1;
	#20
	RegWriteW <= 0;
	

	//decode
	#10
	//(RsD != 0) && (RsD == WriteRegM) && RegWriteM;
	RsD <= 7;
	WriteRegM <= 7;
	RegWriteM <= 1;
	#20;
	$stop;
end


always #5 clk <= ~clk;


endmodule
