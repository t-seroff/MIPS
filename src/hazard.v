// hazard unit module

module Hazard_detector(input clk,
				  input BranchD,
				  input MemtoRegE,
				  input RegWriteE,
				  input MemtoRegM,
				  input RegWriteM,
				  input RegWriteW,
				  input [4:0] RsD,
				  input [4:0] RtD,
				  input [4:0] RsE,
				  input [4:0] RtE,
				  input [4:0] WriteRegE,
				  input [4:0] WriteRegM,
				  input [4:0] WriteRegW,
				  output StallF,
				  output StallD,
				  output FlushE,
				  input multReady,
				  input [1:0] mfReg,
				  input multStart,
				  output StallE,
				  output StallM,
				  output FlushW,
				  input MemReady,
				  input MemWriteM,
				  input clrBufferD,
				  output reg FlushD);
				  
	wire lwstall, branchstall, multstall, memstall;

	reg flushJump;
    //Stalls
        assign branchstall = (BranchD && RegWriteE && (WriteRegE == RsD || WriteRegE == RtD)) 
                            || (BranchD && MemtoRegM && (WriteRegM == RsD || WriteRegM == RtD));

        assign lwstall = ((RsD == RtE) || (RtD == RtE)) && MemtoRegE;
        
        assign multstall = (((mfReg == 2'b01) || (mfReg == 2'b10)) && (!multReady || multStart));

        assign memstall = (MemWriteM || MemtoRegM) && !(MemReady);
    
        assign StallF = lwstall || branchstall || multstall || memstall;
        assign StallD = lwstall || branchstall || multstall || memstall;
        assign FlushE = (lwstall || branchstall || multstall) && !memstall ;
        assign StallE = memstall;
        assign StallM = memstall;
        assign FlushW = memstall;
	  
	always @(*) begin
		if(clrBufferD && memstall) begin
			flushJump <= 1; 
			FlushD <= 0;
		end
		else if (clrBufferD && !memstall) begin
			FlushD <= 1;
		end

		if(flushJump && !memstall) begin
			flushJump <= 0; 
			FlushD <= 1;
		end
		else if (!clrBufferD) begin
			FlushD <= 0;
		end
		
	end
endmodule

module Data_forwarding(input clk,
				  input RegWriteM,
				  input RegWriteW,
				  input [4:0] RsD,
                  input [4:0] RtD,
				  input [4:0] RsE,
				  input [4:0] RtE,
				  input [4:0] WriteRegM,
				  input [4:0] WriteRegW,
				  output ForwardAD,
				  output ForwardBD,
				  output reg [1:0] ForwardAE, 
				  output reg [1:0] ForwardBE);
    
    always@(*) begin
        //Forwarding from Mem/Writeback to Execute stage
        //Forwarding SrcA(rs)
        if ((RsE != 0) && (RsE == WriteRegM) && RegWriteM) begin
            ForwardAE = 2'b10;
        end else if ((RsE != 0) && (RsE == WriteRegW) && RegWriteW) begin
            ForwardAE = 2'b01;
        end else begin
            ForwardAE = 2'b00;
        end
        //Forwarding SrcB(rt)
        if ((RtE != 0) && (RtE == WriteRegM) && RegWriteM) begin
            ForwardBE = 2'b10;
        end else if ((RtE != 0) && (RtE == WriteRegW) && RegWriteW) begin
            ForwardBE = 2'b01;
        end else begin
            ForwardBE = 2'b00;
        end
    end


	//Decode Stage forwarding
	assign ForwardAD = (RsD != 0) && (RsD == WriteRegM) && RegWriteM;
	assign ForwardBD = (RtD != 0) && (RtD == WriteRegM) && RegWriteM;

endmodule
