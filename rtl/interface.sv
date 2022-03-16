//=================================================
// Define interface
//=================================================
interface master_slave_interface;

logic           m_s_req;
logic   [31:0]  m_s_addr;
logic           m_s_cmd;
logic   [31:0]  m_s_wdata;
logic           s_m_ack;
logic   [31:0]  s_m_rdata;


//=================================================
// Modport for Master interface
//=================================================
modport master_interface
(
    output              m_s_req,
    output              m_s_addr,
    output              m_s_cmd,
    output              m_s_wdata,
    input               s_m_ack,
    input               s_m_rdata
);
//=================================================
// Modport for Slave interface
//=================================================
modport slave_interface
(
    input               m_s_req,
    input               m_s_addr,
    input               m_s_cmd,
    input               m_s_wdata,
    output              s_m_ack,
    output              s_m_rdata
);

endinterface

