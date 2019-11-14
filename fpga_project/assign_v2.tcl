set_location_assignment PIN_K10 -to clk
set_location_assignment PIN_J10 -to "clk(n)"
set_instance_assignment -name IO_STANDARD LVDS -to clk
set_location_assignment PIN_AB21 -to pwr_rst
set_location_assignment PIN_A18  -to pwm
set_location_assignment PIN_AB19 -to motor_direction
set_location_assignment PIN_A7 -to LED1
set_location_assignment PIN_A8 -to LED2

set_location_assignment PIN_AB18 -to readhead_sig
set_location_assignment PIN_H2 -to rx_datain[0]
set_location_assignment PIN_H1 -to "rx_datain[0](n)"

set_location_assignment PIN_F2 -to tx_dataout[0]
set_location_assignment PIN_F1 -to "tx_dataout[0](n)"

# nios接受数据引脚
set_location_assignment PIN_A15 -to spi_MISO
# nios输出数据引脚
set_location_assignment PIN_A14 -to spi_MOSI
set_location_assignment PIN_A17 -to spi_SS_n
set_location_assignment PIN_A16 -to spi_SCLK
# R2
set_location_assignment PIN_A12 -to w5500_rst
# E3
set_location_assignment PIN_AB4 -to scl
set_location_assignment PIN_AB5 -to sda


set_location_assignment PIN_A5   -to ad5302_dout     
set_location_assignment PIN_A4   -to ad5302_sclk     
set_location_assignment PIN_A3   -to ad5302_sync_n   
set_location_assignment PIN_A6   -to ad5302_ldac_n   

set_location_assignment PIN_D3   -to epcq32_dclk
set_location_assignment PIN_J4   -to epcq32_sce
set_location_assignment PIN_D1   -to epcq32_sdo
set_location_assignment PIN_K4   -to epcq32_data0

set_location_assignment PIN_P22   -to adt7301_cs_n
set_location_assignment PIN_N22   -to adt7301_din
set_location_assignment PIN_T22   -to adt7301_dout
set_location_assignment PIN_R22   -to adt7301_sclk

set_location_assignment PIN_AA7 -to alarm_io[0]
set_location_assignment PIN_Y7 -to alarm_io[1]
set_location_assignment PIN_W7 -to alarm_io[2]
