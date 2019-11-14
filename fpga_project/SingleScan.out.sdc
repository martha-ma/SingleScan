## Generated SDC file "SingleScan.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.0.0 Build 614 04/24/2018 SJ Standard Edition"

## DATE    "Wed Jun 26 18:10:15 2019"

##
## DEVICE  "EP4CGX50CF23I7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {osc_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|rx_pma_clockout[0]} -source [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|pll0|auto_generated|pll1|icdrclk}] -duty_cycle 50/1 -multiply_by 1 -divide_by 4 -master_clock {altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|altpll:pll0|altpll_dk81:auto_generated|icdrclk} [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|receive_pma0|clockout}] 
create_generated_clock -name {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|receive_pcs0|recoveredclk} -source [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|receive_pma0|clockout}] -duty_cycle 50/1 -multiply_by 1 -divide_by 2 -master_clock {altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|rx_pma_clockout[0]} [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|receive_pcs0|recoveredclk}] 
create_generated_clock -name {rx_clkout} -source [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|receive_pcs0|recoveredclk}] -duty_cycle 50/1 -multiply_by 1 -master_clock {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|receive_pcs0|recoveredclk} [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|receive_pcs0|clkout}] 
create_generated_clock -name {altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|altpll:pll0|altpll_dk81:auto_generated|icdrclk} -source [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|pll0|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 20 -master_clock {osc_clk} [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|pll0|auto_generated|pll1|icdrclk}] 
create_generated_clock -name {altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|altpll:pll0|altpll_dk81:auto_generated|clk[0]} -source [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|pll0|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 20 -master_clock {osc_clk} [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|pll0|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|altpll:pll0|altpll_dk81:auto_generated|clk[1]} -source [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|pll0|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 5 -master_clock {osc_clk} [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|pll0|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|altpll:pll0|altpll_dk81:auto_generated|clk[2]} -source [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|pll0|auto_generated|pll1|inclk[0]}] -duty_cycle 25/1 -multiply_by 5 -master_clock {osc_clk} [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|pll0|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|tx_localrefclk[0]} -source [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|pll0|auto_generated|pll1|clk[1]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|altpll:pll0|altpll_dk81:auto_generated|clk[1]} [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|transmit_pma0|clockout}] 
create_generated_clock -name {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|transmit_pcs0|localrefclk} -source [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|transmit_pma0|clockout}] -duty_cycle 50/1 -multiply_by 1 -divide_by 2 -master_clock {altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|tx_localrefclk[0]} [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|transmit_pcs0|localrefclk}] 
create_generated_clock -name {altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|tx_coreclk_in[0]} -source [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|transmit_pcs0|localrefclk}] -duty_cycle 50/1 -multiply_by 1 -master_clock {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|transmit_pcs0|localrefclk} [get_pins {altgx_driveEx01|ALTGXEx01|ALTGX_alt_c3gxb_component|transmit_pcs0|clkout}] 
create_generated_clock -name {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {pll_100mEx01|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 2 -master_clock {osc_clk} [get_pins {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 5 -master_clock {osc_clk} [get_pins {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {rx_clkout}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {rx_clkout}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -rise_to [get_clocks {rx_clkout}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -fall_to [get_clocks {rx_clkout}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -rise_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -rise_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -fall_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -fall_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -rise_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -rise_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -fall_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -fall_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -rise_to [get_clocks {osc_clk}]  0.100  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -fall_to [get_clocks {osc_clk}]  0.100  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -rise_to [get_clocks {rx_clkout}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -rise_to [get_clocks {rx_clkout}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -fall_to [get_clocks {rx_clkout}] -setup 0.070  
set_clock_uncertainty -rise_from [get_clocks {osc_clk}] -fall_to [get_clocks {rx_clkout}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -rise_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -rise_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -fall_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -fall_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -rise_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -rise_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -fall_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -fall_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -rise_to [get_clocks {osc_clk}]  0.100  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -fall_to [get_clocks {osc_clk}]  0.100  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -rise_to [get_clocks {rx_clkout}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -rise_to [get_clocks {rx_clkout}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -fall_to [get_clocks {rx_clkout}] -setup 0.070  
set_clock_uncertainty -fall_from [get_clocks {osc_clk}] -fall_to [get_clocks {rx_clkout}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {rx_clkout}] -rise_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {rx_clkout}] -fall_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.160  
set_clock_uncertainty -rise_from [get_clocks {rx_clkout}] -rise_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {rx_clkout}] -fall_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {rx_clkout}] -rise_to [get_clocks {osc_clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {rx_clkout}] -rise_to [get_clocks {osc_clk}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {rx_clkout}] -fall_to [get_clocks {osc_clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {rx_clkout}] -fall_to [get_clocks {osc_clk}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {rx_clkout}] -rise_to [get_clocks {rx_clkout}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {rx_clkout}] -fall_to [get_clocks {rx_clkout}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {rx_clkout}] -rise_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {rx_clkout}] -fall_to [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  0.160  
set_clock_uncertainty -fall_from [get_clocks {rx_clkout}] -rise_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {rx_clkout}] -fall_to [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {rx_clkout}] -rise_to [get_clocks {osc_clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {rx_clkout}] -rise_to [get_clocks {osc_clk}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {rx_clkout}] -fall_to [get_clocks {osc_clk}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {rx_clkout}] -fall_to [get_clocks {osc_clk}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {rx_clkout}] -rise_to [get_clocks {rx_clkout}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {rx_clkout}] -fall_to [get_clocks {rx_clkout}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path  -from  [get_clocks {osc_clk}]  -to  [get_clocks {rx_clkout}]
set_false_path  -from  [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]  -to  [get_clocks {rx_clkout}]
set_false_path  -from  [get_clocks {rx_clkout}]  -to  [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]
set_false_path  -from  [get_clocks {rx_clkout}]  -to  [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]
set_false_path  -from  [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  -to  [get_clocks {rx_clkout}]
set_false_path  -from  [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]  -to  [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]
set_false_path  -from  [get_clocks {laser_send_topEx01|n1|altpll_component|auto_generated|pll1|clk[0]}]  -to  [get_clocks {pll_100mEx01|altpll_component|auto_generated|pll1|clk[0]}]
set_false_path -from [get_keepers {rst_module:rst_moduleEx01|rst_n_r}] -to [get_keepers {Ranging_distance:Ranging_distanceEx01|adt7301_top:adt7301_topEx01|high_v:high_vEx01|da_count[7]}]
set_false_path -from [get_keepers {cpu_top:cpu_topEx01|kernel:kernelEx01|kernel_nios2:nios2|kernel_nios2_cpu:cpu|A_mem_baddr[18]}] -to [get_keepers {cpu_top:cpu_topEx01|kernel:kernelEx01|kernel_onchip_memory:onchip_memory|altsyncram:the_altsyncram|altsyncram_s2h1:auto_generated|ram_block1a166~porta_we_reg}]
set_false_path -from [get_keepers {cpu_top:cpu_topEx01|kernel:kernelEx01|kernel_nios2:nios2|kernel_nios2_cpu:cpu|A_mem_baddr*}] 
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|jupdate}] -to [get_registers {*|alt_jtag_atlantic:*|jupdate1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rdata[*]}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read}] -to [get_registers {*|alt_jtag_atlantic:*|read1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read_req}] 
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rvalid}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|t_dav}] -to [get_registers {*|alt_jtag_atlantic:*|tck_t_dav}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|user_saw_rvalid}] -to [get_registers {*|alt_jtag_atlantic:*|rvalid0*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|wdata[*]}] -to [get_registers *]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write}] -to [get_registers {*|alt_jtag_atlantic:*|write1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_ena*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_pause*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_valid}] 
set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_0f9:dffpipe8|dffe9a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_ve9:dffpipe6|dffe7a*}]
set_false_path -to [get_pins -nocase -compatibility_mode {*|alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|clrn}]
set_false_path -from [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_nios2_oci_break:the_kernel_nios2_cpu_nios2_oci_break|break_readreg*}] -to [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_debug_slave_wrapper:the_kernel_nios2_cpu_debug_slave_wrapper|kernel_nios2_cpu_debug_slave_tck:the_kernel_nios2_cpu_debug_slave_tck|*sr*}]
set_false_path -from [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_nios2_oci_debug:the_kernel_nios2_cpu_nios2_oci_debug|*resetlatch}] -to [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_debug_slave_wrapper:the_kernel_nios2_cpu_debug_slave_wrapper|kernel_nios2_cpu_debug_slave_tck:the_kernel_nios2_cpu_debug_slave_tck|*sr[33]}]
set_false_path -from [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_nios2_oci_debug:the_kernel_nios2_cpu_nios2_oci_debug|monitor_ready}] -to [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_debug_slave_wrapper:the_kernel_nios2_cpu_debug_slave_wrapper|kernel_nios2_cpu_debug_slave_tck:the_kernel_nios2_cpu_debug_slave_tck|*sr[0]}]
set_false_path -from [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_nios2_oci_debug:the_kernel_nios2_cpu_nios2_oci_debug|monitor_error}] -to [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_debug_slave_wrapper:the_kernel_nios2_cpu_debug_slave_wrapper|kernel_nios2_cpu_debug_slave_tck:the_kernel_nios2_cpu_debug_slave_tck|*sr[34]}]
set_false_path -from [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_nios2_ocimem:the_kernel_nios2_cpu_nios2_ocimem|*MonDReg*}] -to [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_debug_slave_wrapper:the_kernel_nios2_cpu_debug_slave_wrapper|kernel_nios2_cpu_debug_slave_tck:the_kernel_nios2_cpu_debug_slave_tck|*sr*}]
set_false_path -from [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_debug_slave_wrapper:the_kernel_nios2_cpu_debug_slave_wrapper|kernel_nios2_cpu_debug_slave_tck:the_kernel_nios2_cpu_debug_slave_tck|*sr*}] -to [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_debug_slave_wrapper:the_kernel_nios2_cpu_debug_slave_wrapper|kernel_nios2_cpu_debug_slave_sysclk:the_kernel_nios2_cpu_debug_slave_sysclk|*jdo*}]
set_false_path -from [get_keepers {sld_hub:*|irf_reg*}] -to [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_debug_slave_wrapper:the_kernel_nios2_cpu_debug_slave_wrapper|kernel_nios2_cpu_debug_slave_sysclk:the_kernel_nios2_cpu_debug_slave_sysclk|ir*}]
set_false_path -from [get_keepers {sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1]}] -to [get_keepers {*kernel_nios2_cpu:*|kernel_nios2_cpu_nios2_oci:the_kernel_nios2_cpu_nios2_oci|kernel_nios2_cpu_nios2_oci_debug:the_kernel_nios2_cpu_nios2_oci_debug|monitor_go}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|receive_pcs0~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|receive_pcs0~OBSERVABLE_DIGITAL_RESET }] 20.000
set_max_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|cent_unit0~OBSERVABLEDPRIORESET }] 20.000
set_max_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|cent_unit0~OBSERVABLERXDIGITALRESET }] 20.000
set_max_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|cent_unit0~OBSERVABLETXDIGITALRESET }] 20.000
set_max_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|cent_unit0~OBSERVABLERXANALOGRESET }] 20.000
set_max_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|transmit_pcs0~OBSERVABLEQUADRESET }] 20.000
set_max_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|transmit_pcs0~OBSERVABLE_DIGITAL_RESET }] 20.000


#**************************************************************
# Set Minimum Delay
#**************************************************************

set_min_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|receive_pcs0~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|receive_pcs0~OBSERVABLE_DIGITAL_RESET }] 0.000
set_min_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|cent_unit0~OBSERVABLEDPRIORESET }] 0.000
set_min_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|cent_unit0~OBSERVABLERXDIGITALRESET }] 0.000
set_min_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|cent_unit0~OBSERVABLETXDIGITALRESET }] 0.000
set_min_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|cent_unit0~OBSERVABLERXANALOGRESET }] 0.000
set_min_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|transmit_pcs0~OBSERVABLEQUADRESET }] 0.000
set_min_delay -to [get_ports { altgx_drive:altgx_driveEx01|ALTGX:ALTGXEx01|ALTGX_alt_c3gxb:ALTGX_alt_c3gxb_component|transmit_pcs0~OBSERVABLE_DIGITAL_RESET }] 0.000


#**************************************************************
# Set Input Transition
#**************************************************************

