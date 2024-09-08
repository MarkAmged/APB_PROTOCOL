vlib work
vlog APB_Master.v APB_SLAVE.v APB_WRAPPER.v APB_tb.v
vsim -voptargs=+acc work.APB_tb
add wave *
run -all
#quit -sim