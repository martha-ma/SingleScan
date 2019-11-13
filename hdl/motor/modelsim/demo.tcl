quit -sim
.main clear

set env(ALTERA_LIB)         altera18.0_questasim_10.6c_lib
set env(LIB_PATH)           F:/crack/
vmap   $env(ALTERA_LIB)     $env(LIB_PATH)$env(ALTERA_LIB)

#工程所需要的文件
vlog -sv -incr  ../bench/motor_top_tb.sv
vlog -incr      ../src/angle_cal.v
vlog -incr      +define+DEBUG_FEED ../src/feed.v
#vlog -incr      ../src/feed.v
vlog -incr      ../src/filter_signal.v
vlog -incr      ../src/motor_info.v
vlog -incr      ../src/motor_top.v
vlog -incr      ../src/pwm_drive.v
vlog -incr      ../../../ip/mul/mul_ip.v

vlog -incr      ../../../ip/div_distance/div_distance.v


vsim -t ps -novopt  -L $env(ALTERA_LIB) work.motor_top_tb

log -r /*
radix 16

do wave.do

run 100ms

