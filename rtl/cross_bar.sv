//=================================================
// Cross-bar 2x2 masters/slaves
//=================================================
module cross_bar(
    input                                              clk,            //GLOBAL CLK
    input                                              resetn,         //GLOBAL RST

    master_slave_interface.master_interface            master_1,       //MASTER-1 SIDE CROSS-BAR
    master_slave_interface.master_interface            master_2,       //MASTER-2 SIDE CROSS-BAR
    master_slave_interface.slave_interface             slave_1,        //SLAVE-1 SIDE CROSS-BAR
    master_slave_interface.slave_interface             slave_2         //SLAVE-2 SIDE CROSS-BAR
);




logic                  master_1_req;    //MASTER 1 INTERFACE
logic        [31:0]    master_1_addr;
logic                  master_1_cmd;
logic        [31:0]    master_1_wdata;
logic                  master_1_ack;
logic        [31:0]    master_1_rdata;

logic                  master_2_req;    //MASTER 2 INTERFACE
logic        [31:0]    master_2_addr;
logic                  master_2_cmd;
logic        [31:0]    master_2_wdata;
logic                  master_2_ack;
logic        [31:0]    master_2_rdata;

logic                  slave_1_req;    //SLAVE 1 INTERFACE
logic        [31:0]    slave_1_addr;
logic                  slave_1_cmd;
logic        [31:0]    slave_1_wdata;
logic                  slave_1_ack;
logic        [31:0]    slave_1_rdata;

logic                  slave_2_req;    //SLAVE 2 INTERFACE
logic        [31:0]    slave_2_addr;
logic                  slave_2_cmd;
logic        [31:0]    slave_2_wdata;
logic                  slave_2_ack;
logic        [31:0]    slave_2_rdata;


logic [1:0]   req;
logic [1:0]   grnt;
logic         req_m1;
logic         req_m2;
logic         slave_1_read_ok;
logic         slave_2_read_ok;
logic         slave_1_read_ok_shift;
logic         slave_2_read_ok_shift;

//=================================================
// Supports registers (read transfers)
//=================================================
always_ff @(posedge clk or negedge resetn) begin
    if(!resetn) begin
        slave_1_read_ok        <= 0;
        slave_2_read_ok        <= 0;
    end
    else begin
        if ((!slave_1_cmd && slave_1_req && slave_1_ack) && (!slave_2_cmd && slave_2_req && slave_2_ack)) begin
            slave_1_read_ok    <= 1;
            slave_2_read_ok    <= 1;
        end
        else if (!slave_1_cmd && slave_1_req && slave_1_ack)
            slave_1_read_ok    <= 1;
        else if (!slave_2_cmd && slave_2_req && slave_2_ack)
            slave_2_read_ok    <= 1;
        else begin
            slave_1_read_ok    <= 0;
            slave_2_read_ok    <= 0;
        end
    end
end
//=================================================
// One pulse supports registers (read transfers)
//=================================================
always_ff @(posedge clk or negedge resetn) begin
    if(!resetn) begin
        slave_1_read_ok_shift    <= 0;
        slave_2_read_ok_shift    <= 0;
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
// Main cross-bar 2x2 logic
//=================================================
always_comb begin : blockName
         master_1_ack      = 0;
         master_1_rdata    = 0;
         master_2_ack      = 0;
         master_2_rdata    = 0;
         slave_1_req       = 0;
         slave_1_addr      = 0;
         slave_1_cmd       = 0;
         slave_1_wdata     = 0;
         slave_2_req       = 0;
         slave_2_addr      = 0;
         slave_2_cmd       = 0;
         slave_2_wdata     = 0;
//=================================================
// Check masters address
//=================================================
    case({master_1_addr[31],master_2_addr[31]})
        2'b00: begin
            case(grnt)
                2'b10:    begin
                slave_1_req     = master_2_req;
                slave_1_addr    = master_2_addr;
                slave_1_cmd     = master_2_cmd;
                slave_1_wdata   = master_2_wdata;
                master_2_ack    = slave_1_ack;
                master_2_rdata  = slave_1_rdata;
                master_1_ack    = 0;
                master_1_rdata  = 0;
                slave_2_req     = 0;
                slave_2_addr    = 0;
                slave_2_cmd     = 0;
                slave_2_wdata   = 0;
                end
                2'b01: begin
                slave_1_req     = master_1_req;
                slave_1_addr    = master_1_addr;
                slave_1_cmd     = master_1_cmd;
                slave_1_wdata   = master_1_wdata;
                master_1_ack    = slave_1_ack;
                master_1_rdata  = slave_1_rdata;
                master_2_ack    = 0;
                master_2_rdata  = 0;
                slave_2_req     = 0;
                slave_2_addr    = 0;
                slave_2_cmd     = 0;
                slave_2_wdata   = 0;
                end
                2'b00: begin
                    if (!master_1_cmd && master_2_cmd)
                    master_1_rdata = slave_1_rdata;
                    else if (!master_2_cmd && master_1_cmd)
                    master_2_rdata = slave_1_rdata;
                    else begin
                        master_1_rdata    = 0;
                        master_2_rdata    = 0;
                    end
                end
            endcase
        end
        2'b11: begin
            case(grnt)
                2'b10:    begin
                slave_2_req     = master_2_req;
                slave_2_addr    = master_2_addr;
                slave_2_cmd     = master_2_cmd;
                slave_2_wdata   = master_2_wdata;
                master_2_ack    = slave_2_ack;
                master_2_rdata  = slave_2_rdata;
                master_1_ack    = 0;
                master_1_rdata  = 0;
                slave_1_req     = 0;
                slave_1_addr    = 0;
                slave_1_cmd     = 0;
                slave_1_wdata   = 0;
                end
                2'b01: begin
                slave_2_req     = master_1_req;
                slave_2_addr    = master_1_addr;
                slave_2_cmd     = master_1_cmd;
                slave_2_wdata   = master_1_wdata;
                master_1_ack    = slave_2_ack;
                master_1_rdata  = slave_2_rdata;
                master_2_ack    = 0;
                master_2_rdata  = 0;
                slave_1_req     = 0;
                slave_1_addr    = 0;
                slave_1_cmd     = 0;
                slave_1_wdata   = 0;
                end
                2'b00: begin
                    if (!master_1_cmd && master_2_cmd)
                    master_1_rdata = slave_2_rdata;
                    else if (!master_2_cmd && master_1_cmd)
                    master_2_rdata = slave_2_rdata;
                    else begin
                        master_1_rdata    = 0;
                        master_2_rdata    = 0;
                    end
                end
            endcase
        end
//=================================================
// Simple transfers (defferent slaves)
//=================================================
        2'b10: begin
                slave_2_req     = master_1_req;
                slave_2_addr    = master_1_addr;
                slave_2_cmd     = master_1_cmd;
                slave_2_wdata   = master_1_wdata;
                master_1_ack    = slave_2_ack;
                master_1_rdata  = slave_2_rdata;

                slave_1_req     = master_2_req;
                slave_1_addr    = master_2_addr;
                slave_1_cmd     = master_2_cmd;
                slave_1_wdata   = master_2_wdata;
                master_2_ack    = slave_1_ack;
                master_2_rdata  = slave_1_rdata;
        end
        2'b01: begin
                slave_1_req     = master_1_req;
                slave_1_addr    = master_1_addr;
                slave_1_cmd     = master_1_cmd;
                slave_1_wdata   = master_1_wdata;
                master_1_ack    = slave_1_ack;
                master_1_rdata  = slave_1_rdata;

                slave_2_req     = master_2_req;
                slave_2_addr    = master_2_addr;
                slave_2_cmd     = master_2_cmd;
                slave_2_wdata   = master_2_wdata;
                master_2_ack    = slave_2_ack;
                master_2_rdata  = slave_2_rdata;
        end
    endcase
end

//=================================================
// Global inst interfaces
//=================================================
assign    master_1_req        = slave_1.m_s_req;
assign    master_1_addr       = slave_1.m_s_addr;
assign    master_1_cmd        = slave_1.m_s_cmd;
assign    master_1_wdata      = slave_1.m_s_wdata;
assign    slave_1.s_m_ack     = master_1_ack;
assign    slave_1.s_m_rdata   = master_1_rdata;


assign    master_2_req        = slave_2.m_s_req;
assign    master_2_addr       = slave_2.m_s_addr;
assign    master_2_cmd        = slave_2.m_s_cmd;
assign    master_2_wdata      = slave_2.m_s_wdata;
assign    slave_2.s_m_ack     = master_2_ack;
assign    slave_2.s_m_rdata   = master_2_rdata;


assign    slave_1_ack         = master_1.s_m_ack;
assign    slave_1_rdata       = master_1.s_m_rdata;
assign    master_1.m_s_req    = slave_1_req;
assign    master_1.m_s_addr   = slave_1_addr;
assign    master_1.m_s_cmd    = slave_1_cmd;
assign    master_1.m_s_wdata  = slave_1_wdata;


assign    slave_2_ack         = master_2.s_m_ack;
assign    slave_2_rdata       = master_2.s_m_rdata;
assign    master_2.m_s_req    = slave_2_req;
assign    master_2.m_s_addr   = slave_2_addr;
assign    master_2.m_s_cmd    = slave_2_cmd;
assign    master_2.m_s_wdata  = slave_2_wdata;
//=================================================
// Round-robin req signals from masters
//=================================================
assign req_m1    =    (master_1_req && master_1_cmd)                         ?     1:
                      (master_1_req && !master_1_cmd)                        ?     1:
                      (!master_1_req && (slave_1_read_ok|| slave_2_read_ok)) ?     1:0;
assign req_m2    =    (master_2_req && master_2_cmd)                         ?     1:
                      (master_2_req && !master_2_cmd)                        ?     1:
                      (!master_2_req && (slave_2_read_ok|| slave_1_read_ok)) ?     1:0;


assign req = ((master_1_addr[31] == master_2_addr[31])) ? {req_m2,req_m1} : 2'b0;

round_robin round_robin_inst
(
    .clk    (clk                ),
    .resetn (resetn             ),
    .req    (req                ),
    .grnt   (grnt               )
);

endmodule
