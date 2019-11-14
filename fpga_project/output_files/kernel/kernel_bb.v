
module kernel (
	alarm_select_export,
	clk_clk,
	epcs_flash_dclk,
	epcs_flash_sce,
	epcs_flash_sdo,
	epcs_flash_data0,
	laser_fifo_in_valid,
	laser_fifo_in_data,
	laser_fifo_in_ready,
	power_led_export,
	protocol_fifo_out_valid,
	protocol_fifo_out_data,
	protocol_fifo_out_ready,
	reset_reset_n,
	scl_export,
	sda_export,
	spird_fifo_in_valid,
	spird_fifo_in_data,
	spird_fifo_in_ready,
	spiwr_fifo_out_valid,
	spiwr_fifo_out_data,
	spiwr_fifo_out_ready,
	status_led_export,
	w5500_cs_export,
	w5500_int_in_port,
	w5500_int_out_port,
	w5500_rst_export);	

	input	[3:0]	alarm_select_export;
	input		clk_clk;
	output		epcs_flash_dclk;
	output		epcs_flash_sce;
	output		epcs_flash_sdo;
	input		epcs_flash_data0;
	input		laser_fifo_in_valid;
	input	[31:0]	laser_fifo_in_data;
	output		laser_fifo_in_ready;
	output		power_led_export;
	output		protocol_fifo_out_valid;
	output	[31:0]	protocol_fifo_out_data;
	input		protocol_fifo_out_ready;
	input		reset_reset_n;
	output		scl_export;
	inout		sda_export;
	input		spird_fifo_in_valid;
	input	[31:0]	spird_fifo_in_data;
	output		spird_fifo_in_ready;
	output		spiwr_fifo_out_valid;
	output	[31:0]	spiwr_fifo_out_data;
	input		spiwr_fifo_out_ready;
	output		status_led_export;
	output		w5500_cs_export;
	input		w5500_int_in_port;
	output		w5500_int_out_port;
	output		w5500_rst_export;
endmodule
