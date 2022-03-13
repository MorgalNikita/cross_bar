quit -sim

vlib work
vlog  rtl/master_cpu.v
vlog  rtl/slave_ram.v
vlog  rtl/cross_bar.v
vlog  rtl/round_robin.v
vlog  tb/tb.v

vsim -novopt tb

add wave -position end  sim:/tb/clk
add wave -position end  sim:/tb/resetn


add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_req
add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_cmd
add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_addr
add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_wdata
add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_rdata
add wave -position end -radix hex  -group MASTER_1 sim:/tb/master_1_ack

add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_req
add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_cmd
add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_addr
add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_wdata
add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_rdata
add wave -position end -radix hex  -group MASTER_2 sim:/tb/master_2_ack

add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_req
add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_cmd
add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_addr
add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_wdata
add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_rdata
add wave -position end -radix hex  -group SLAVE_1 sim:/tb/slave_1_ack

add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_req
add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_cmd
add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_addr
add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_wdata
add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_rdata
add wave -position end -radix hex  -group SLAVE_2 sim:/tb/slave_2_ack



add wave -position end   -radix hex  -group ROUND_ROBIN sim:/tb/cross_bar/round_robin_inst/grnt
add wave -position end  sim:/tb/cross_bar/slave_2_read_ok_shift
add wave -position end  sim:/tb/cross_bar/slave_2_read_ok
add wave -position end  sim:/tb/cross_bar/slave_1_read_ok_shift
add wave -position end  sim:/tb/cross_bar/slave_1_read_ok

run 2 ns