onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/clk
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/send_en
add wave -noupdate -color Magenta /calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/valid_in
add wave -noupdate -color Magenta {/calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/valid_in_r0[8]}
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/distance_in
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/zero_flag
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/wheel_fall
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/step_cnt
add wave -noupdate -radix ascii /calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/TANNIS_CHANGE
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/target_valid
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/target_pos
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/target_gray
add wave -noupdate -divider grid
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/tannis_change
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/grid_degree33_cnt
add wave -noupdate -radix ascii /calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/cs_STRING
add wave -noupdate -radix ascii /calc_distance_toptb/calc_distance_topEx01/grid_divisionEx01/TANNIS_CHANGE
add wave -noupdate -divider statistical
add wave -noupdate -radix ascii /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/cs_STRING
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis1_right_addr
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis2_right_addr
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/cur_range_point_number
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/max_range_point_pos
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1660949681 ps} 0} {{Cursor 2} {2178880227 ps} 0}
quietly wave cursor active 2
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
configure wave -timeline 1
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {1050 us}
