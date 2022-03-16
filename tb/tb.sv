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


//=================================================
// Interface inst
//=================================================
master_slave_interface     	master_1_i();
master_slave_interface     	master_2_i();

master_slave_interface     	slave_1_i();
master_slave_interface		slave_2_i();

//=================================================
// Global instance to testing 2x2 cross-bar
//=================================================
master_cpu  #(
	.RANDOMIZATION(5)
)
master_1(
	.clk		(clk				),
	.resetn		(resetn				),
	.master		(master_1_i.master_interface	)
);

master_cpu  #(
	.RANDOMIZATION(10)
)
master_2(
	.clk		(clk				),
	.resetn		(resetn				),
	.master		(master_2_i.master_interface	)
);


slave_ram slave_1
(
	.clk		(clk				),
	.resetn		(resetn				),
	.slave		(slave_1_i.slave_interface	)
);

slave_ram slave_2
(
	.clk		(clk				),
	.resetn		(resetn				),
	.slave		(slave_2_i.slave_interface	)
);


cross_bar cross_bar(
	.clk		(clk				),
	.resetn		(resetn				),

	.master_1	(slave_1_i.master_interface	),
	.master_2	(slave_2_i.master_interface	),
	.slave_1	(master_1_i.slave_interface	),
	.slave_2	(master_2_i.slave_interface	)
);

endmodule
