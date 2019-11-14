set_location_assignment PIN_K10 -to clk
set_location_assignment PIN_J10 -to "clk(n)"
set_instance_assignment -name IO_STANDARD LVDS -to clk
set_location_assignment PIN_AB21 -to pwr_rst
set_location_assignment PIN_AB20 -to pwm
set_location_assignment PIN_AB19 -to motor_direction
set_location_assignment PIN_AA9 -to LED1
set_location_assignment PIN_AA10 -to LED2

set_location_assignment PIN_AB18 -to readhead_sig
set_location_assignment PIN_H2 -to rx_datain[0]
set_location_assignment PIN_H1 -to "rx_datain[0](n)"

set_location_assignment PIN_F2 -to tx_dataout[0]
set_location_assignment PIN_F1 -to "tx_dataout[0](n)"

# nios接受数据引脚
set_location_assignment PIN_A13 -to spi_MISO
# nios输出数据引脚
set_location_assignment PIN_A14 -to spi_MOSI
set_location_assignment PIN_A11 -to spi_SS_n
set_location_assignment PIN_A12 -to spi_SCLK
# R2
set_location_assignment PIN_A16 -to w5500_rst
# E3
set_location_assignment PIN_AB4 -to scl
set_location_assignment PIN_AB5 -to sda


set_location_assignment PIN_AB11 -to ad5302_dout     
set_location_assignment PIN_AB13 -to ad5302_sclk     
set_location_assignment PIN_AB14 -to ad5302_sync_n   
set_location_assignment PIN_AB15 -to ad5302_ldac_n   
