
module master_cpu#(
parameter RANDOMIZATION = 1
)
(
	input 				clk,
	input 				resetn,
	output reg 			master_1_req,
	output reg	[31:0] 	master_1_addr,
	output reg			master_1_cmd,
	output 		[31:0]	master_1_wdata,
	input 				master_1_ack,
	input  		[31:0]	master_1_rdata
);

	reg [31:0]	mem_master_1 [0:31];
	initial $readmemh("tb/mem_master_1.txt", mem_master_1);
	reg [31:0] 	master_1_couneter;
	reg 		master_1_read_flag;
	assign master_1_wdata = (master_1_cmd) ? mem_master_1[master_1_addr[4:0]] : 32'hx;

	always @(posedge clk) begin
		if(master_1_read_flag)begin
		master_1_read_flag	<=	1'b0;
		mem_master_1[master_1_addr[4:0]] <= master_1_rdata;
		end
	end
//=================================================
// Global Reset
//=================================================
	always @(posedge clk or negedge resetn) begin
		if (!resetn) begin
			master_1_req		<=	1'b0;
			master_1_addr		<=	1'b0;
			master_1_cmd		<=	1'b0;
			master_1_couneter	<=	32'b0;
			master_1_read_flag	<=	1'b0;
		end
//=================================================
// Write Logic
//=================================================
		else if (!master_1_ack && master_1_req && (master_1_cmd == 1)) begin
			master_1_req 		<=	master_1_req;
			master_1_cmd 		<=	1'b1;
			master_1_addr		<=	master_1_addr;
			master_1_couneter	<=	32'h0;

		end
		else if (!master_1_ack && master_1_req && (master_1_cmd == 0)) begin
			master_1_req 		<=	master_1_req;
			master_1_cmd 		<=	1'b0;
			master_1_addr		<=	master_1_addr;
			master_1_couneter	<=	master_1_couneter + 1;
		end
		else if (!master_1_ack && resetn) begin
			master_1_req 		<=	1;
			master_1_cmd 		<=	$urandom_range(RANDOMIZATION, 0);
			master_1_addr[31]	<=	$urandom_range(RANDOMIZATION, 0);
			master_1_addr[30:0]	<=	31'h0 + $urandom_range(RANDOMIZATION + 25, 0);
		end
		else if (master_1_ack && master_1_req && master_1_cmd) begin
			master_1_cmd 		<=	$urandom_range(RANDOMIZATION, 0);
			master_1_addr[31]	<=	$urandom_range(RANDOMIZATION, 0);
			master_1_addr[30:0]	<=	31'h0 + $urandom_range(RANDOMIZATION + 25, 0);
		end
//=================================================
// Read Logic
//=================================================
		else if (master_1_ack && master_1_req && !master_1_cmd && (master_1_couneter !=0) ) begin
			master_1_req 		<=	0;
			master_1_cmd 		<=	1'b0;
			master_1_addr		<=	master_1_addr;
			master_1_read_flag	<= 	1'b1;
		end
	end

endmodule