quit -sim

vlib work
vlog -sv rtl/master_cpu.sv
vlog -sv rtl/slave_ram.sv
vlog -sv rtl/cross_bar.sv
vlog -sv rtl/round_robin.sv
vlog -sv rtl/interface.sv
vlog -sv tb/tb.sv

vsim -novopt tb

add wave -position end  sim:/tb/clk
add wave -position end  sim:/tb/resetn


add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_i/m_s_req
add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_i/m_s_cmd
add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_i/m_s_addr
add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_i/m_s_wdata
add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_i/s_m_rdata
add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_i/s_m_ack


add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_i/m_s_req
add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_i/m_s_cmd
add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_i/m_s_addr
add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_i/m_s_wdata
add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_i/s_m_rdata
add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_i/s_m_ack


add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_i/m_s_req
add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_i/m_s_cmd
add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_i/m_s_addr
add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_i/m_s_wdata
add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_i/s_m_rdata
add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_i/s_m_ack


add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_i/m_s_req
add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_i/m_s_cmd
add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_i/m_s_addr
add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_i/m_s_wdata
add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_i/s_m_rdata
add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_i/s_m_ack




add wave -position end   -radix hex  -group ROUND_ROBIN sim:/tb/cross_bar/round_robin_inst/grnt

run 2 ns
