# Clear transcript
transcript on
echo "--- Cleaning Cache and Starting Fresh Compilation ---"

# Delete the old work library to FORCE a fresh build
if {[file exists work]} {
    vdel -all -lib work
}

vlib work
vmap work work

# Compile files with coverage instrumentation
vlog +cover -work work *.v
vlog -sv +cover -work work *.sv

# Start simulation
vsim -voptargs="+acc" -coverage work.tb_cpu_top

# Add waveforms
add wave -position insertpoint sim:/tb_cpu_top/clk
add wave -position insertpoint sim:/tb_cpu_top/reset
add wave -group "RV32I Core" -radix hexadecimal sim:/tb_cpu_top/uut/pc_current
add wave -group "RV32I Core" -radix hexadecimal sim:/tb_cpu_top/uut/instruction
add wave -group "RV32I Core" -radix binary sim:/tb_cpu_top/uut/hazard_pc_write
add wave -group "APB Master" -radix hexadecimal sim:/tb_cpu_top/uut/apb_master_inst/*
add wave -group "APB Slave" -radix hexadecimal sim:/tb_cpu_top/uut/apb_slave_mem_inst/*

run -all

coverage report -file coverage_report.txt -byfile -detail -noannotate
echo "--- DV Run Complete. Coverage Report Generated ---"