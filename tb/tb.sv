`timescale 1ps/1ps
//=================================================
// Top test module and global instance
//=================================================
module tb();

logic 	clk;
logic 	resetn;


//=================================================
// Clk pulse
//=================================================
initial begin
	clk = 0;
	resetn = 0;
	repeat(5) @(posedge clk);
	resetn = 1;
end
always #5 clk = ~clk;


logic  		master_1_req;
logic 	[31:0] 	master_1_addr;
logic		master_1_cmd;
logic 	[31:0]	master_1_wdata;
logic 		master_1_ack;
logic	[31:0]	master_1_rdata;

logic  		master_2_req;
logic 	[31:0] 	master_2_addr;
logic		master_2_cmd;
logic 	[31:0]	master_2_wdata;
logic 		master_2_ack;
logic	[31:0]	master_2_rdata;

logic  		slave_1_req;
logic 	[31:0] 	slave_1_addr;
logic		slave_1_cmd;
logic 	[31:0]	slave_1_wdata;
logic 		slave_1_ack;
logic	[31:0]	slave_1_rdata;

logic  		slave_2_req;
logic 	[31:0] 	slave_2_addr;
logic		slave_2_cmd;
logic 	[31:0]	slave_2_wdata;
logic 		slave_2_ack;
logic	[31:0]	slave_2_rdata;


//=================================================
// Global instance to testing 2x2 cross-bar
//=================================================
master_cpu  #(
	.RANDOMIZATION(5)
)
master_1(
	.clk		(clk		),
	.resetn		(resetn		),
	.master_1_req	(master_1_req	),
	.master_1_addr	(master_1_addr	),
	.master_1_cmd	(master_1_cmd	),
	.master_1_wdata	(master_1_wdata	),
	.master_1_ack	(master_1_ack	),
	.master_1_rdata	(master_1_rdata	)
);

master_cpu  #(
	.RANDOMIZATION(10)
)
master_2(
	.clk		(clk		),
	.resetn		(resetn		),
	.master_1_req	(master_2_req	),
	.master_1_addr	(master_2_addr	),
	.master_1_cmd	(master_2_cmd	),
	.master_1_wdata	(master_2_wdata	),
	.master_1_ack	(master_2_ack	),
	.master_1_rdata	(master_2_rdata	)
);
slave_ram slave_1
(
	.clk		(clk		),
	.resetn		(resetn		),
	.slave_1_req	(slave_1_req	),
	.slave_1_addr	(slave_1_addr	),
	.slave_1_cmd	(slave_1_cmd	),
	.slave_1_wdata	(slave_1_wdata	),
	.slave_1_ack	(slave_1_ack	),
	.slave_1_rdata	(slave_1_rdata	)
);
slave_ram slave_2(
	.clk		(clk		),
	.resetn		(resetn		),
	.slave_1_req	(slave_2_req	),
	.slave_1_addr	(slave_2_addr	),
	.slave_1_cmd	(slave_2_cmd	),
	.slave_1_wdata	(slave_2_wdata	),
	.slave_1_ack	(slave_2_ack	),
	.slave_1_rdata	(slave_2_rdata	)
);
cross_bar cross_bar(
	.clk		(clk		),
	.resetn		(resetn		),
	.master_1_req	(master_1_req	),
	.master_1_addr	(master_1_addr	),
	.master_1_cmd	(master_1_cmd	),
	.master_1_wdata	(master_1_wdata	),
	.master_1_ack	(master_1_ack	),
	.master_1_rdata	(master_1_rdata	),

	.master_2_req	(master_2_req	),
	.master_2_addr	(master_2_addr	),
	.master_2_cmd	(master_2_cmd	),
	.master_2_wdata	(master_2_wdata	),
	.master_2_ack	(master_2_ack	),
	.master_2_rdata	(master_2_rdata	),

	.slave_1_req	(slave_1_req	),
	.slave_1_addr	(slave_1_addr	),
	.slave_1_cmd	(slave_1_cmd	),
	.slave_1_wdata	(slave_1_wdata	),
	.slave_1_ack	(slave_1_ack	),
	.slave_1_rdata	(slave_1_rdata	),

	.slave_2_req	(slave_2_req	),
	.slave_2_addr	(slave_2_addr	),
	.slave_2_cmd	(slave_2_cmd	),
	.slave_2_wdata	(slave_2_wdata	),
	.slave_2_ack	(slave_2_ack	),
	.slave_2_rdata	(slave_2_rdata	)
);

endmodule
