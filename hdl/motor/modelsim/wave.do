onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/clk
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/rst_n
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/real_zero_flag
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/virtual_zero_flag
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/wheel_fall
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/sub_cnt
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/speed_cnt
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/valid_angle
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/step_cnt
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/time_cnt
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/time_flag
add wave -noupdate -color {Blue Violet} -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/cur_angle
add wave -noupdate -color {Blue Violet} -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/step_angle
add wave -noupdate -color {Blue Violet} -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/quotient
add wave -noupdate -color {Orange Red} -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/angle_range
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/diff_value
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/delay
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/s2
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/denom
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/numer
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/quotient_r
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/valid_cnt
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/cs
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/ns
add wave -noupdate -radix unsigned /motor_top_tb/motor_topEx01/angle_validEx01/state_cnt
add wave -noupdate -radix ascii /motor_top_tb/motor_topEx01/angle_validEx01/cs_STRING
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {26879521777 ps} 0} {{Cursor 2} {67266532000 ps} 1}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {26845366468 ps} {26947905532 ps}
