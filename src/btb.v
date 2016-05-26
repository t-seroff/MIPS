//2^7 table entries
`define TABLE_ENTRIES 7
`define TABLE_ENTRIES_SIZE 128

`define GLOBAL_BITS 4
`define GLOBAL_SIZE 4

`define STRONGLY_TAKEN 2'b11
`define WEAKLY_TAKEN 2'b10
`define WEAKLY_NOT_TAKEN 2'b01
`define STRONGLY_NOT_TAKEN 2'b00

module btb(input clk, reset,
		   input [31:0] PCF, 
		   input [31:0] branch_address_in,
		   input [31:0] predicted_address_in,
		   input btb_write,
		   input state_change,
		   input state_write,
		   input branch_e,
		   output entry_found, 
		   output [31:0] predicted_pc);
		   
//global history predictor
reg [`GLOBAL_BITS-1:0] global_history;

//BTB table entries
reg [31:0] branchPCs[`TABLE_ENTRIES_SIZE-1:0][`GLOBAL_BITS-1:0];
reg [31:0] predictedPCs[`TABLE_ENTRIES_SIZE-1:0][`GLOBAL_BITS-1:0];
reg [1:0] predictionStates[`TABLE_ENTRIES_SIZE-1:0][`GLOBAL_BITS-1:0];

//fetch stage: check if branch is in the BTB and output predicted address
assign entry_found = (PCF == branchPCs[PCF[`TABLE_ENTRIES-1:0]][global_history]);
assign predicted_pc = predictedPCs[PCF[`TABLE_ENTRIES-1:0]][global_history];

//for reset
integer i, j;

always@(negedge clk) begin
	//reset
	if(reset) begin
		for(j = 0; j < `GLOBAL_SIZE; j=j+1) begin
			for(i = 0; i < `TABLE_ENTRIES_SIZE; i = i+1) begin
				branchPCs[i][j] <= 1; //will never match because instructions are words
				predictedPCs[i][j] <= 1;
				predictionStates[i][j] <= `STRONGLY_NOT_TAKEN;
			end
		end
		global_history = `STRONGLY_NOT_TAKEN; 
	end else begin
		//writing a new entry to BTB
		if(btb_write) begin
			branchPCs[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] <=  branch_address_in;
			predictedPCs[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] <= predicted_address_in;
			predictionStates[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] <=  `WEAKLY_TAKEN;
		end
		//changing the state of an entry
		if(state_write) begin
			if(state_change == 1) begin
			//taken
				if(predictionStates[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] != `STRONGLY_TAKEN)
					predictionStates[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] = predictionStates[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] + 1;
			end else begin
			//not taken
				if(predictionStates[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] != `STRONGLY_NOT_TAKEN)
					predictionStates[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] = predictionStates[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] - 1;
			end
			
			//after state change, update entry
			case(predictionStates[branch_address_in[`TABLE_ENTRIES-1:0]][global_history])
				`STRONGLY_TAKEN: predictedPCs[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] = predicted_address_in;
				`WEAKLY_TAKEN: predictedPCs[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] = predicted_address_in;
				`WEAKLY_NOT_TAKEN: predictedPCs[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] = branch_address_in + 4;
				`STRONGLY_NOT_TAKEN: predictedPCs[branch_address_in[`TABLE_ENTRIES-1:0]][global_history] = branch_address_in + 4;
			endcase
		end
		//changing the state of global history predictor
		if(branch_e) begin
			if(state_change == 1) begin
			//taken
				if(global_history != `STRONGLY_TAKEN)
					global_history = global_history + 1;
			end else begin
			//not taken
				if(global_history != `STRONGLY_NOT_TAKEN)
					global_history = global_history - 1;
			end
		end
	end
end

endmodule
