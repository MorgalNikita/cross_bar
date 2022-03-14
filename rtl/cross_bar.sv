//=================================================
// Cross-bar 2x2 masters/slaves
//=================================================
module cross_bar(
	input			clk,			//GLOBAL CLK
	input			resetn,			//GLOBAL RST

	input			master_1_req,	//MASTER 1 INTERFACE
	input		[31:0]	master_1_addr,
	input			master_1_cmd,
	input		[31:0]	master_1_wdata,
	output	logic		master_1_ack,
	output	logic	[31:0]	master_1_rdata,

	input			master_2_req,	//MASTER 2 INTERFACE
	input		[31:0]	master_2_addr,
	input  			master_2_cmd,
	input  		[31:0]	master_2_wdata,
	output	logic   	master_2_ack,
	output	logic	[31:0]	master_2_rdata,

	output	logic		slave_1_req,	//SLAVE 1 INTERFACE
	output	logic	[31:0] 	slave_1_addr,
	output	logic		slave_1_cmd,
	output	logic	[31:0]	slave_1_wdata,
	input			slave_1_ack,
	input		[31:0]	slave_1_rdata,

	output	logic		slave_2_req,	//SLAVE 2 INTERFACE
	output	logic	[31:0]	slave_2_addr,
	output	logic 		slave_2_cmd,
	output	logic	[31:0]	slave_2_wdata,
	input			slave_2_ack,
	input		[31:0]	slave_2_rdata
);


logic [1:0] 	req;
logic [1:0] 	grnt;
logic 		req_m1;
logic		req_m2;
logic 		slave_1_read_ok;
logic 		slave_2_read_ok;
logic 		slave_1_read_ok_shift;
logic 		slave_2_read_ok_shift;

//=================================================
// Supports registers (read transfers)
//=================================================
always_ff @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		slave_1_read_ok			<= 0;
		slave_2_read_ok			<= 0;
	end
	else begin
		if ((!slave_1_cmd && slave_1_req && slave_1_ack) && (!slave_2_cmd && slave_2_req && slave_2_ack)) begin
			slave_1_read_ok	<= 1;
			slave_2_read_ok	<= 1;
		end
		else if (!slave_1_cmd && slave_1_req && slave_1_ack)
			slave_1_read_ok	<= 1;
		else if (!slave_2_cmd && slave_2_req && slave_2_ack)
			slave_2_read_ok	<= 1;
		else begin
			slave_1_read_ok	<= 0;
			slave_2_read_ok	<= 0;
		end
	end
end
//=================================================
// One pulse supports registers (read transfers)
//=================================================
always_ff @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		slave_1_read_ok_shift	<= 0;
		slave_2_read_ok_shift	<= 0;
	end
	else begin
		if (slave_1_read_ok && slave_2_read_ok) begin
			slave_1_read_ok_shift <= 1;
			slave_2_read_ok_shift <= 1;
		end
		else if (slave_1_read_ok)
			slave_1_read_ok_shift <= 1;
		else if (slave_2_read_ok)
			slave_2_read_ok_shift <= 1;
		else begin
			slave_1_read_ok_shift <= 0;
			slave_2_read_ok_shift <= 0;
		end
	end
end
//=================================================
// Cross-bar common logic
//=================================================
always_ff @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		master_1_ack	<= 0;
		master_1_rdata	<= 0;
		master_2_ack	<= 0;
		master_2_rdata	<= 0;
		slave_1_req	<= 0;
		slave_1_addr	<= 0;
		slave_1_cmd	<= 0;
		slave_1_wdata	<= 0;
		slave_2_req	<= 0;
		slave_2_addr	<= 0;
		slave_2_cmd	<= 0;
		slave_2_wdata	<= 0;
	end
	else begin
//=================================================
// Response read transfers
//=================================================
		if ((slave_2_read_ok || slave_1_read_ok) && (slave_2_ack  || slave_1_ack)) begin
			slave_1_req	<= 0;
			slave_1_addr	<= 32'hx;
			slave_1_cmd	<= 0;
			slave_1_wdata	<= 32'hx;
			slave_2_req	<= 0;
			slave_2_addr	<= 32'hx;
			slave_2_cmd	<= 0;
			slave_2_wdata	<= 32'hx;
			if ((master_1_addr[31] && slave_2_read_ok) && (!master_2_addr[31] && slave_1_read_ok)) begin
				master_1_ack 	<= 0;
				master_2_ack 	<= 0;
				master_1_rdata 	<= slave_2_rdata;
				master_2_rdata 	<= slave_1_rdata;
			end
			else if ((!master_1_addr[31] && slave_1_read_ok) && (master_2_addr[31] && slave_2_read_ok)) begin
				master_1_ack 	<= 0;
				master_2_ack 	<= 0;
				master_1_rdata 	<= slave_1_rdata;
				master_2_rdata 	<= slave_2_rdata;
			end
			else if (!master_1_addr[31] && slave_1_read_ok) begin
				master_1_ack 	<= 0;
				master_1_rdata 	<= slave_1_rdata;
				master_2_ack 	<= slave_2_ack;
				master_2_rdata 	<= slave_2_rdata;
			end
			else if (master_1_addr[31] && slave_2_read_ok) begin
				master_1_ack 	<= 0;
				master_1_rdata 	<= slave_2_rdata;
			end
			else if (!master_2_addr[31] && slave_1_read_ok) begin
				master_2_ack 	<= 0;
				master_2_rdata 	<= slave_2_rdata;
			end
			else if (master_2_addr[31] && slave_2_read_ok) begin
				master_2_ack <= 0;
				master_2_rdata <=slave_2_rdata;
			end
		end
		else if ((slave_2_read_ok || slave_1_read_ok) && (!master_1_cmd || !master_2_cmd) && (master_1_req || master_2_req)) begin
			if (|grnt) begin
				if (slave_2_read_ok && grnt[1] ) begin
					master_2_ack 	<= 0;
					master_2_rdata 	<= slave_2_rdata;
					slave_1_req	<= 0;
					slave_1_addr	<= 32'hx;
					slave_1_cmd	<= 0;
					slave_1_wdata	<= 32'hx;
					slave_2_req	<= 0;
					slave_2_addr	<= 32'hx;
					slave_2_cmd	<= 0;
					slave_2_wdata	<= 32'hx;
				end
				else if (slave_2_read_ok && grnt[0]) begin
					master_1_ack <= 0;
					master_1_rdata <=slave_2_rdata;
					slave_1_req	<= 0;
					slave_1_addr	<= 32'hx;
					slave_1_cmd	<= 0;
					slave_1_wdata	<= 32'hx;
					slave_2_req	<= 0;
					slave_2_addr	<= 32'hx;
					slave_2_cmd	<= 0;
					slave_2_wdata	<= 32'hx;
				end
				else if (slave_1_read_ok && grnt[0]) begin
					master_1_ack <= 0;
					master_1_rdata <=slave_1_rdata;
					slave_1_req	<= 0;
					slave_1_addr	<= 32'hx;
					slave_1_cmd	<= 0;
					slave_1_wdata	<= 32'hx;
					slave_2_req	<= 0;
					slave_2_addr	<= 32'hx;
					slave_2_cmd	<= 0;
					slave_2_wdata	<= 32'hx;
				end
				else if (slave_1_read_ok && grnt[1]) begin
					master_2_ack <= 0;
					master_2_rdata <=slave_1_rdata;
					slave_1_req	<= 0;
					slave_1_addr	<= 32'hx;
					slave_1_cmd	<= 0;
					slave_1_wdata	<= 32'hx;
					slave_2_req	<= 0;
					slave_2_addr	<= 32'hx;
					slave_2_cmd	<= 0;
					slave_2_wdata	<= 32'hx;
				end
			end
			else begin
				if ((master_1_addr[31] && slave_2_read_ok) && (!master_2_addr[31] && slave_1_read_ok)) begin
					master_1_ack 	<= 0;
					master_2_ack 	<= 0;
					master_1_rdata 	<= slave_2_rdata;
					master_2_rdata 	<= slave_1_rdata;
				end
				else if ((!master_1_addr[31] && slave_1_read_ok) && (master_2_addr[31] && slave_2_read_ok)) begin
					master_1_ack 	<= 0;
					master_2_ack 	<= 0;
					master_1_rdata 	<= slave_1_rdata;
					master_2_rdata 	<= slave_2_rdata;
				end
				else if ((!master_1_addr[31] && slave_2_read_ok && master_1_cmd) && (master_2_addr[31] && slave_2_read_ok)) begin
					master_1_ack	<= slave_1_ack;
					master_2_ack	<= slave_2_ack;
					master_2_rdata	<= slave_2_rdata;
				end
				else if (!master_1_addr[31] && slave_1_read_ok) begin
					master_1_ack 	<= 0;
					master_1_rdata 	<=slave_1_rdata;
				end
				else if (master_1_addr[31] && slave_2_read_ok) begin
					master_1_ack <= 0;
					master_1_rdata <=slave_2_rdata;
				end
				else if (!master_2_addr[31] && slave_1_read_ok) begin
					master_2_ack <= 0;
					master_2_rdata <=slave_2_rdata;
				end
				else if (master_2_addr[31] && slave_2_read_ok) begin
					master_2_ack <= 0;
					master_2_rdata <=slave_2_rdata;
				end
			end
		end
//=================================================
// Cross-bar detect slaves response
//=================================================
		else if(slave_2_ack  || slave_1_ack) begin
			case({slave_2_ack,slave_1_ack})
				2'b10: begin
					slave_2_req	<= 0;
					slave_2_addr	<= 32'hx;
					slave_2_cmd	<= 0;
					slave_2_wdata	<= 32'hx;
					if (|grnt) begin
						if (slave_2_ack && grnt[0]) begin
							master_1_ack	<= slave_2_ack;
							master_1_rdata	<= slave_2_rdata;
						end
						else	if (slave_2_ack && grnt[1]) begin
							master_2_ack	<= slave_2_ack;
							master_2_rdata	<= slave_2_rdata;
						end
					end
					else begin
						if (slave_1_ack && (slave_1_addr[31] == master_1_addr[31]))begin
							master_1_ack	<= slave_1_ack;
							master_1_rdata	<= slave_1_rdata;
						end
						else if (slave_1_ack && (slave_1_addr[31] == master_2_addr[31]))begin
							master_2_ack	<= slave_1_ack;
							master_2_rdata	<= slave_1_rdata;
						end
						else if (slave_2_ack && (slave_2_addr[31] == master_1_addr[31]))begin
							master_1_ack	<= slave_2_ack;
							master_1_rdata	<= slave_2_rdata;
						end
						else if (slave_2_ack && (slave_2_addr[31] == master_2_addr[31]))begin
							master_2_ack	<= slave_2_ack;
							master_2_rdata	<= slave_2_rdata;
							master_1_ack	<= slave_1_ack;
						end

					end
				end
				2'b01: begin
					slave_1_req	<= 0;
					slave_1_addr	<= 32'hx;
					slave_1_cmd	<= 0;
					slave_1_wdata	<= 32'hx;
					if (|grnt) begin
						if (slave_1_ack && grnt[0]) begin
							master_1_ack	<= slave_1_ack;
							master_1_rdata	<= slave_1_rdata;
						end
						else	if (slave_1_ack && grnt[1]) begin
							master_2_ack	<= slave_1_ack;
							master_2_rdata	<= slave_1_rdata;
						end
					end
					else begin
						if (slave_1_ack && (slave_1_addr[31] == master_1_addr[31]))begin
							master_1_ack	<= slave_1_ack;
							master_1_rdata	<= slave_1_rdata;
						end
						else if (slave_1_ack && (slave_1_addr[31] == master_2_addr[31]))begin
							master_2_ack	<= slave_1_ack;
							master_2_rdata	<= slave_1_rdata;
							master_1_ack	<= 0;
						end
						else if (slave_2_ack && (slave_2_addr[31] == master_1_addr[31]))begin
							master_1_ack	<= slave_2_ack;
							master_1_rdata	<= slave_2_rdata;
						end
						else if (slave_2_ack && (slave_2_addr[31] == master_2_addr[31]))begin
							master_2_ack	<= slave_2_ack;
							master_2_rdata	<= slave_2_rdata;
						end
					end
				end
				2'b11: begin
					slave_2_req	<= 0;
					slave_2_addr	<= 32'hx;
					slave_2_cmd	<= 0;
					slave_2_wdata	<= 32'hx;
					slave_1_req	<= 0;
					slave_1_addr	<= 32'hx;
					slave_1_cmd	<= 0;
					slave_1_wdata	<= 32'hx;
					if (|grnt) begin
						if (slave_2_ack && grnt[0]) begin
							master_1_ack	<= slave_2_ack;
							master_1_rdata	<= slave_2_rdata;
						end
						else	if (slave_2_ack && grnt[1]) begin
							master_2_ack	<= slave_2_ack;
							master_2_rdata	<= slave_2_rdata;
						end
						else	if (slave_1_ack && grnt[0]) begin
							master_1_ack	<= slave_1_ack;
							master_1_rdata	<= slave_1_rdata;
						end
						else	if (slave_1_ack && grnt[1]) begin
							master_2_ack	<= slave_1_ack;
							master_2_rdata	<= slave_1_rdata;
						end
					end
					else begin
						master_1_ack	<= 1;
						master_2_ack	<= 1;
						master_1_rdata	<= 32'bx;
						master_2_rdata  <= 32'bx;
					end
				end
			endcase
			end
			else if (master_2_ack || master_1_ack) begin
				slave_1_req	<= 0;
				slave_1_addr	<= 32'hx;
				slave_1_cmd	<= 0;
				slave_1_wdata	<= 32'hx;
				slave_2_req	<= 0;
				slave_2_addr	<= 32'hx;
				slave_2_cmd	<= 0;
				slave_2_wdata	<= 32'hx;
				if (master_1_ack && master_2_ack) begin
					master_1_ack <= 0;
					master_2_ack <= 0;
				end
				else if (master_2_ack) begin
					master_2_ack <= 0;
				end
				else if (master_1_ack) begin
					master_1_ack <= 0;
					if (master_2_req && master_2_cmd && !slave_2_ack && (grnt == 2'b00))begin
						slave_2_req	<= master_2_req;
						slave_2_addr	<= master_2_addr;
						slave_2_cmd	<= master_2_cmd;
						slave_2_wdata	<= master_2_wdata;
					end
				end
			end
//=================================================
// Ez mode (Different slaves from diferent masters)
//=================================================
		else if(master_1_addr[31] != master_2_addr[31]) begin
				case({master_1_addr[31],master_2_addr[31]})
					2'b10: begin
						slave_2_req	<= master_1_req;
						slave_2_addr	<= master_1_addr;
						slave_2_cmd	<= master_1_cmd;
						slave_2_wdata	<= master_1_wdata;
						master_1_ack	<= slave_2_ack;
						master_1_rdata	<= slave_2_rdata;

						slave_1_req	<= master_2_req;
						slave_1_addr	<= master_2_addr;
						slave_1_cmd	<= master_2_cmd;
						slave_1_wdata	<= master_2_wdata;
						master_2_ack	<= slave_1_ack;
						master_2_rdata	<= slave_1_rdata;
					end
					2'b01: begin
						slave_1_req	<= master_1_req;
						slave_1_addr	<= master_1_addr;
						slave_1_cmd	<= master_1_cmd;
						slave_1_wdata	<= master_1_wdata;
						master_1_ack	<= slave_1_ack;
						master_1_rdata	<= slave_1_rdata;

						slave_2_req	<= master_2_req;
						slave_2_addr	<= master_2_addr;
						slave_2_cmd	<= master_2_cmd;
						slave_2_wdata	<= master_2_wdata;
						master_2_ack	<= slave_2_ack;
						master_2_rdata	<= slave_2_rdata;
					end
				endcase
		end
//=================================================
// Hard mode (Mastes to 1 slave) round-robin works
//=================================================
		else if (master_1_addr[31] == master_2_addr[31] && |grnt) begin
				case({master_1_addr[31],master_2_addr[31]})
				2'b11: begin
						if(grnt[0]) begin
							slave_2_req	<= master_1_req;
							slave_2_addr	<= master_1_addr;
							slave_2_cmd	<= master_1_cmd;
							slave_2_wdata	<= master_1_wdata;
							master_1_ack	<= slave_2_ack;
							master_1_rdata	<= slave_2_rdata;
						end
						else if (grnt[1]) begin
							slave_2_req	<= master_2_req;
							slave_2_addr	<= master_2_addr;
							slave_2_cmd	<= master_2_cmd;
							slave_2_wdata	<= master_2_wdata;
							master_2_ack	<= slave_2_ack;
							master_2_rdata	<= slave_2_rdata;
						end
				end
				2'b00: begin
					if(grnt[0]) begin
						slave_1_req	<= master_1_req;
						slave_1_addr	<= master_1_addr;
						slave_1_cmd	<= master_1_cmd;
						slave_1_wdata	<= master_1_wdata;
						master_1_ack	<= slave_1_ack;
						master_1_rdata	<= slave_1_rdata;
					end
					else if (grnt[1]) begin
						slave_1_req	<= master_2_req;
						slave_1_addr	<= master_2_addr;
						slave_1_cmd	<= master_2_cmd;
						slave_1_wdata	<= master_2_wdata;
						master_2_ack	<= slave_1_ack;
						master_2_rdata	<= slave_1_rdata;
					end
				end
			endcase
		end
	end
end

//=================================================
// Round-robin req signals from masters
//=================================================
assign req_m1	=	(master_1_req && master_1_cmd)						? 	1:
			(master_1_req && !master_1_cmd)						?	1:
			(!master_1_req && (slave_1_read_ok_shift|| slave_2_read_ok_shift))	?	1:0;
assign req_m2	=	(master_2_req && master_2_cmd)						?	1:
			(master_2_req && !master_2_cmd)						?	1:
			(!master_2_req && (slave_2_read_ok_shift|| slave_1_read_ok_shift))	?	1:0;


assign req = ((master_1_addr[31] == master_2_addr[31])) ? {req_m2,req_m1} : 2'b0;

round_robin round_robin_inst
(
	.clk	(clk				),
	.resetn	(resetn				),
	.req	(req				),
	.grnt	(grnt				)
);

endmodule
