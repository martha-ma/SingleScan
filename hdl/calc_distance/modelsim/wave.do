onerror {resume}
quietly virtual function -install /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01 -env /calc_distance_toptb/calc_distance_topEx01/zero_reviseEx01 { &{/calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/before_info[31], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/before_info[30], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/before_info[29], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/before_info[28], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/before_info[27], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/before_info[26], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/before_info[25], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/before_info[24] }} before_num
quietly virtual function -install /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01 -env /calc_distance_toptb/calc_distance_topEx01/zero_reviseEx01 { &{/calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/middle_info[31], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/middle_info[30], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/middle_info[29], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/middle_info[28], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/middle_info[27], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/middle_info[26], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/middle_info[25], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/middle_info[24] }} middle_num
quietly virtual function -install /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01 -env /calc_distance_toptb/calc_distance_topEx01/zero_reviseEx01 { &{/calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/after_info[31], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/after_info[30], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/after_info[29], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/after_info[28], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/after_info[27], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/after_info[26], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/after_info[25], /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/after_info[24] }} after_num
quietly WaveActivateNextPane {} 0
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/clk
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/rst_n
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/valid_num_threshold
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/zero_flag
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/wheel_fall
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/step_cnt
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis_change
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis1_right_wren
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis1_right_wrdata
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis1_right_addr
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis1_right_rden
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis1_right_rddata
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis2_right_wren
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis2_right_wrdata
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis2_right_addr
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis2_right_rden
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis2_right_rddata
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/target_valid
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/target_gray
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/target_pos
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis_change_r
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis_change_rise
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/tannis_change_fall
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/cur_range_point_number
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/max_range_point_pos
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/before_num
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/middle_num
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/after_num
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/before_info
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/middle_info
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/after_info
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/distance_data
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/cs
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/ns
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/state_cnt
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/state_cnt_n
add wave -noupdate -radix ascii /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/cs_STRING
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/ram_data_valid_r0
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/ram_data_valid_r1
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/ram_data_valid_r2
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/ram_data_cnt
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/denom
add wave -noupdate -radix unsigned /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/pos_numer
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/gray_numer
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/target_pos_r0
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/target_gray_r0
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/target_valid_r0
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/target_valid_r1
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/target_valid_r2
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/expect_number
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/diff_number
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/diff_flag
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/wheel_fall_r0
add wave -noupdate /calc_distance_toptb/calc_distance_topEx01/grid_statisticalEx01/real_num
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {64268702 ps} 0} {{Cursor 2} {997056961 ps} 0}
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
configure wave -timeline 1
configure wave -timelineunits us
update
WaveRestoreZoom {63756006 ps} {64781398 ps}
