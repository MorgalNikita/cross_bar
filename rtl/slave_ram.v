//=================================================
// CROSS-BAR MODULE 2X2
//=================================================
module slave_ram(

	input                   clk,            //GLOBAL CLK
	input                   resetn,         //GLOBAL RST

	input                   slave_1_req,    //SLAVE INTERFACE
	input           [31:0]  slave_1_addr,
	input                   slave_1_cmd,
	input           [31:0]  slave_1_wdata,
	output logic            slave_1_ack,
	output logic    [31:0]  slave_1_rdata
);

    logic [31:0] mem_slave_1 [0:255];
    logic [31:0] timer;
    logic done;
    integer i;

 //=================================================
 // Initial memory
 //=================================================
initial begin
    for (i = 0;  i <= 255; i = i + 1)
        begin
            mem_slave_1[i] = $urandom_range(250000,0);
        end
end
 //=================================================
 // Random timer write/read memory
 //=================================================
always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
        timer <= 32'h0;
    end
    else begin
        if (slave_1_req && slave_1_cmd) begin
            timer <= timer + 1;
        end
        else if  (slave_1_req && !slave_1_cmd) begin
            timer <= timer - 1;
        end
    end
end
 //=================================================
 // Read Logic
 //=================================================
always_ff @(posedge clk or negedge resetn) begin
    if(!resetn) begin
        slave_1_ack     <= 0;
        slave_1_rdata   <= 0;
    end
    else if (!slave_1_req) begin
        slave_1_rdata   <= 32'hx;
        slave_1_ack     <= 0;
    end
    else if (slave_1_ack && !slave_1_cmd) begin
        slave_1_ack     <= 0;
        slave_1_rdata   <= mem_slave_1[slave_1_addr[7:0]];
    end
    else if (slave_1_ack && slave_1_cmd) begin
        slave_1_ack     <= 0;
        slave_1_rdata   <= 32'hx;
end
 //=================================================
 // Write Logic
 //=================================================
    else if (slave_1_req && slave_1_cmd && done) begin
        slave_1_ack <= 1;
        mem_slave_1[slave_1_addr[7:0]] <= slave_1_wdata;
        slave_1_rdata <= 32'hx;
    end
 //=================================================
 // Read Logic
 //=================================================
    else if (slave_1_req && !slave_1_cmd && done) begin
        slave_1_ack     <= 1;
        slave_1_rdata   <= 32'hx;
    end
end

assign done = (timer % $urandom_range(3,2) == 0) ? 1:0;

endmodule
