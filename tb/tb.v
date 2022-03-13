`timescale 1ps/1ps
module tb();

reg 			clk;
reg 			resetn;

initial begin
	clk = 0;
	resetn = 0;
	repeat(5) @(posedge clk);
	resetn = 1;
end
always #5 clk = ~clk;

wire  			master_1_req;
wire 	[31:0] 	master_1_addr;
wire			master_1_cmd;
wire 	[31:0]	master_1_wdata;
wire 			master_1_ack;
wire	[31:0]	master_1_rdata;

wire  			master_2_req;
wire 	[31:0] 	master_2_addr;
wire			master_2_cmd;
wire 	[31:0]	master_2_wdata;
wire 			master_2_ack;
wire	[31:0]	master_2_rdata;

wire  			slave_1_req;
wire 	[31:0] 	slave_1_addr;
wire			slave_1_cmd;
wire 	[31:0]	slave_1_wdata;
wire 			slave_1_ack;
wire	[31:0]	slave_1_rdata;

wire  			slave_2_req;
wire 	[31:0] 	slave_2_addr;
wire			slave_2_cmd;
wire 	[31:0]	slave_2_wdata;
wire 			slave_2_ack;
wire	[31:0]	slave_2_rdata;

master_cpu  #(
	.RANDOMIZATION(5)
)
master_1	(

	.clk			(clk			),
	.resetn			(resetn			),
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
master_2	(
	.clk			(clk			),
	.resetn			(resetn			),
	.master_1_req	(master_2_req	),
	.master_1_addr	(master_2_addr	),
	.master_1_cmd	(master_2_cmd	),
	.master_1_wdata	(master_2_wdata	),
	.master_1_ack	(master_2_ack	),
	.master_1_rdata	(master_2_rdata	)
);
slave_ram slave_1
(
	.clk			(clk			),
	.resetn			(resetn			),
	.slave_1_req	(slave_1_req	),
	.slave_1_addr	(slave_1_addr	),
	.slave_1_cmd	(slave_1_cmd	),
	.slave_1_wdata	(slave_1_wdata	),
	.slave_1_ack	(slave_1_ack	),
	.slave_1_rdata	(slave_1_rdata	)
);
slave_ram slave_2
(
	.clk			(clk			),
	.resetn			(resetn			),
	.slave_1_req	(slave_2_req	),
	.slave_1_addr	(slave_2_addr	),
	.slave_1_cmd	(slave_2_cmd	),
	.slave_1_wdata	(slave_2_wdata	),
	.slave_1_ack	(slave_2_ack	),
	.slave_1_rdata	(slave_2_rdata	)
);

cross_bar cross_bar
(
	.clk			(clk			),
	.resetn			(resetn			),
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
