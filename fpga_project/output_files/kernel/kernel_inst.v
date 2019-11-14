	kernel u0 (
		.alarm_select_export     (<connected-to-alarm_select_export>),     //      alarm_select.export
		.clk_clk                 (<connected-to-clk_clk>),                 //               clk.clk
		.epcs_flash_dclk         (<connected-to-epcs_flash_dclk>),         //        epcs_flash.dclk
		.epcs_flash_sce          (<connected-to-epcs_flash_sce>),          //                  .sce
		.epcs_flash_sdo          (<connected-to-epcs_flash_sdo>),          //                  .sdo
		.epcs_flash_data0        (<connected-to-epcs_flash_data0>),        //                  .data0
		.laser_fifo_in_valid     (<connected-to-laser_fifo_in_valid>),     //     laser_fifo_in.valid
		.laser_fifo_in_data      (<connected-to-laser_fifo_in_data>),      //                  .data
		.laser_fifo_in_ready     (<connected-to-laser_fifo_in_ready>),     //                  .ready
		.power_led_export        (<connected-to-power_led_export>),        //         power_led.export
		.protocol_fifo_out_valid (<connected-to-protocol_fifo_out_valid>), // protocol_fifo_out.valid
		.protocol_fifo_out_data  (<connected-to-protocol_fifo_out_data>),  //                  .data
		.protocol_fifo_out_ready (<connected-to-protocol_fifo_out_ready>), //                  .ready
		.reset_reset_n           (<connected-to-reset_reset_n>),           //             reset.reset_n
		.scl_export              (<connected-to-scl_export>),              //               scl.export
		.sda_export              (<connected-to-sda_export>),              //               sda.export
		.spird_fifo_in_valid     (<connected-to-spird_fifo_in_valid>),     //     spird_fifo_in.valid
		.spird_fifo_in_data      (<connected-to-spird_fifo_in_data>),      //                  .data
		.spird_fifo_in_ready     (<connected-to-spird_fifo_in_ready>),     //                  .ready
		.spiwr_fifo_out_valid    (<connected-to-spiwr_fifo_out_valid>),    //    spiwr_fifo_out.valid
		.spiwr_fifo_out_data     (<connected-to-spiwr_fifo_out_data>),     //                  .data
		.spiwr_fifo_out_ready    (<connected-to-spiwr_fifo_out_ready>),    //                  .ready
		.status_led_export       (<connected-to-status_led_export>),       //        status_led.export
		.w5500_cs_export         (<connected-to-w5500_cs_export>),         //          w5500_cs.export
		.w5500_int_in_port       (<connected-to-w5500_int_in_port>),       //         w5500_int.in_port
		.w5500_int_out_port      (<connected-to-w5500_int_out_port>),      //                  .out_port
		.w5500_rst_export        (<connected-to-w5500_rst_export>)         //         w5500_rst.export
	);

