module mainDecoder(	input [5:0] op, 
			output reg memtoreg,
			output reg memwrite,
			output reg branch,
			output reg alusrc,
			output reg regdst,
			output reg regwrite,
			output reg jump,
			output reg [1:0] aluop);
		
// Main decoder

reg [8:0] controls;
//assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} = controls;

always @ (*) begin
	case(op)
		6'b000000: controls <= 9'b110000010; // R-type
		6'b100011: controls <= 9'b101001000; // lw
		6'b101011: controls <= 9'b001010000; // sw
		6'b000100: controls <= 9'b000100001; // beq
		6'b001000: controls <= 9'b101000000; // addi
		6'b000010: controls <= 9'b000000100; // j
		default: controls <= 9'bxxxxxxxxx; // invalid opcode
	endcase
	regwrite = controls[8];	
	regdst = controls[7];
	alusrc = controls[6];
	branch = controls[5];
	memwrite = controls[4];
	memtoreg = controls[3];
	jump = controls[2];
	aluop = controls[1:0];
end
endmodule

module aluDecoder(	input [5:0] funct,
			input [1:0] aluop,
			output reg [2:0] alucontrol);
// ALU decoder
always @ (*) begin
	case (aluop)
		2'b00: alucontrol <= 3'b010; // add for lw, sw, addi
		2'b01: alucontrol <= 3'b110; // sub for beq
		default: case (funct)	     // R-type functions
			6'b100000: alucontrol <= 3'b010; // add
			6'b100010: alucontrol <= 3'b110; // sub
			6'b100100: alucontrol <= 3'b000; // and
			6'b100101: alucontrol <= 3'b001; // or
			6'b101010: alucontrol <= 3'b111; // slt
			default: alucontrol <= 3'bxxx; // invalid data in funct field
		endcase
	endcase
end
endmodule
