quit -sim
# 可以不手动建立library
#vlib    work
#vmap    work work

set env(ALTERA_LIB)         altera18.0_questasim_10.6c_lib
set env(LIB_PATH)           F:/crack/
vmap   $env(ALTERA_LIB)     $env(LIB_PATH)$env(ALTERA_LIB)

#工程所需要的文件
vlog -sv -incr ../bench/calc_distance_toptb.sv
vlog -incr ../hdl/*.v

vlog -incr ../ip/mod10/mod10.v
vlog -incr ../ip/grid_ram/grid_ram.v

vsim -t ps -novopt -L $env(ALTERA_LIB) work.calc_distance_toptb

log -r /* 
radix 16

do wave.do

run 1ms
