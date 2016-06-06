module controller_tb();
	reg [5:0] op, funct;
	wire RegWrite, MemtoReg, MemWrite, ALUSrc, RegDst, branch, jump, startMult, signedMult;
        wire [3:0] ALUControl;
        wire [1:0] mfReg;

	controller uut(op, funct, RegWrite, MemtoReg,MemWrite, ALUControl, ALUSrc, RegDst,branch,jump, startMult, signedMult,mfReg);
	

	initial begin
		#10 op = 6'b000000; //r-type
		#10 funct = 6'b100000; // add
		#10 funct = 6'b100001; // addu
		#10 funct = 6'b100010; // sub
		#10 funct = 6'b100011; // subu
		#10 funct = 6'b100100; // and
		#10 funct = 6'b100101; // or
		#10 funct = 6'b100110; // xor
		#10 funct = 6'b100111; // xnor(using NOR's funct code)
		#10 funct = 6'b101010; // slt
		#10 funct = 6'b101011; // sltu
		#10 funct = 6'b010000; // mfhi
		#10 funct = 6'b010010; // mflo
		#10 funct = 6'b011000; // mult
		#10 funct = 6'b011001; // multu

		#10 op = 6'b100011; // lw
		#10 op = 6'b101011; // sw
		#10 op = 6'b000100; // beq
		#10 op = 6'b001000; // addi
		#10 op = 6'b000010; // j
		#10 op = 6'b000101; // bne
		#10 op = 6'b001001; // addiu
		#10 op = 6'b001100; // andi
		#10 op = 6'b001101; // ori
		#10 op = 6'b001110; // xori
		#10 op = 6'b001010; // slti
		#10 op = 6'b001011; // sltiu
		#10 op = 6'b001111; // lui
		#10 $stop;
	end


endmodule
