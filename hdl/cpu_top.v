`timescale  1 ns/1 ps

module cpu_top
(
    input   wire                clk_125m,
    input   wire                clk_100m,
    input   wire                rst_n,

    output  wire                scl,
    inout   wire                sda,
    input   wire [03:00]        alarm_select_io,
    output  wire [00:00]        cpu_test_io,
    output  wire                power_led,
    output  wire                status_led,

    input   wire                spi_MISO,
    output  wire                spi_MOSI,
    output  wire                spi_SCLK,
    output  wire                spi_SS_n,

    output  wire                epcq32_dclk,  // epcs_flash_controller_0_external.dclk
    output  wire                epcq32_sce,   //                                 .sce
    output  wire                epcq32_sdo,   //                                 .sdo
    input   wire                epcq32_data0, //                                 .data0

    output  wire                w5500_rst,
    output  wire                w5500_int,
    /*port*/

    input   wire                valid_region_finish,
    input   wire                region0_rden,
    input   wire [09:00]        region0_rdaddr,
    output  wire [17:00]        region0_rddata,

    input   wire                region1_rden,
    input   wire [09:00]        region1_rdaddr,
    output  wire [17:00]        region1_rddata,

    input   wire                region2_rden,
    input   wire [09:00]        region2_rdaddr,
    output  wire [17:00]        region2_rddata,

    output  wire [239:00]       laser_presdo,
    output  wire [61:00]        system_para,
    output  wire [89:00]        da_cycle_para,
    output  wire [215:00]       distance_para,

    input   wire [255:00]       fpga_status,
    input   wire [31:00]        motor_speed,

    output  wire                fifo_rdreq,
    input   wire [31:00]        fifo_rddata,
    input   wire [10:00]        fifo_usedw

);

wire                        protocol_fifo_out_valid;
wire [31:00]                protocol_fifo_out_data;
wire                        protocol_fifo_out_ready;

wire                        laser_fifo_in_ready /* synthesis keep */;
wire                        laser_fifo_in_valid /* synthesis keep */;
wire [31:00]                laser_fifo_in_data /* synthesis keep */;

wire                        spiwr_fifo_out_valid;
wire [31:00]                spiwr_fifo_out_data /* synthesis keep */;
wire                        spiwr_fifo_out_ready;

wire                        spird_fifo_in_ready  /* synthesis keep */;
wire                        spird_fifo_in_valid /* synthesis keep */;
wire [31:00]                spird_fifo_in_data /* synthesis keep */;

wire                        w5500_cs;

assign                  cpu_test_io[0] = w5500_int;

command_module  command_moduleEx01
(
    .clk                        (    clk_100m                   ),
    .clk_125m                   (    clk_125m                   ),
    .rst_n                      (    rst_n                      ),

    .protocol_fifo_out_valid    (    protocol_fifo_out_valid    ),
    .protocol_fifo_out_data     (    protocol_fifo_out_data     ),
    .protocol_fifo_out_ready    (    protocol_fifo_out_ready    ),

    .valid_region_finish        (    valid_region_finish        ),
    .region0_rden               (    region0_rden               ),
    .region0_rdaddr             (    region0_rdaddr             ),
    .region0_rddata             (    region0_rddata             ),
    .region1_rden               (    region1_rden               ),
    .region1_rdaddr             (    region1_rdaddr             ),
    .region1_rddata             (    region1_rddata             ),
    .region2_rden               (    region2_rden               ),
    .region2_rdaddr             (    region2_rdaddr             ),
    .region2_rddata             (    region2_rddata             ),
    .laser_presdo               (    laser_presdo               ),
    .system_para                (    system_para                ),
    .da_cycle_para              (    da_cycle_para              ),
    .distance_para              (    distance_para              )
);

`ifdef MODELSIM     // 仿真模式不加载nios软核
    assign                  laser_fifo_in_ready = 1;
`else
kernel kernelEx01
(
    .clk_clk                    (    clk_100m                   ),
    .reset_reset_n              (    1'b1                       ),

    .laser_fifo_in_valid        (    laser_fifo_in_valid        ),
    .laser_fifo_in_data         (    laser_fifo_in_data         ),
    .laser_fifo_in_ready        (    laser_fifo_in_ready        ),
    .protocol_fifo_out_valid    (    protocol_fifo_out_valid    ),
    .protocol_fifo_out_data     (    protocol_fifo_out_data     ),
    .protocol_fifo_out_ready    (    protocol_fifo_out_ready    ),

    .spird_fifo_in_valid        (    spird_fifo_in_valid        ),
    .spird_fifo_in_data         (    spird_fifo_in_data         ),
    .spird_fifo_in_ready        (    spird_fifo_in_ready        ),
    .spiwr_fifo_out_valid       (    spiwr_fifo_out_valid       ),
    .spiwr_fifo_out_data        (    spiwr_fifo_out_data        ),
    .spiwr_fifo_out_ready       (    spiwr_fifo_out_ready       ),

    .scl_export                 (    scl                        ),              //               scl.export
    .sda_export                 (    sda                        ),              //               sda.export

    .epcs_flash_dclk            (    epcq32_dclk                ),
    .epcs_flash_sce             (    epcq32_sce                 ),
    .epcs_flash_sdo             (    epcq32_sdo                 ),
    .epcs_flash_data0           (    epcq32_data0               ),

    .alarm_select_export        (    alarm_select_io            ),
    .w5500_cs_export            (    w5500_cs                   ),
    .w5500_int_in_port          (                               ),
    .w5500_int_out_port         (    w5500_int                  ),
    .w5500_rst_export           (    w5500_rst                  ),
    .power_led_export           (    power_led                  ),                       //                        power_led.export
    .status_led_export          (    status_led                 )
);
`endif

update2nios update2niosEx01
(
    .clk                        (    clk_100m                   ),
    .rst                        (    rst_n                      ),

    .fpga_status                (    fpga_status                ),

    .fifo_rdreq                 (    fifo_rdreq                 ),
    .fifo_rddata                (    fifo_rddata                ),
    .fifo_usedw                 (    fifo_usedw                 ),
    .laser_fifo_in_ready        (    laser_fifo_in_ready        ),
    .laser_fifo_in_valid        (    laser_fifo_in_valid        ),
    .laser_fifo_in_data         (    laser_fifo_in_data         )
);

fifo2spi_bridge_top fifo2spi_bridge_topEx01
(
    .clk                        (    clk_100m                  ),
    .rst                        (    rst_n                      ),
    .nios_cs                    (    w5500_cs                   ),
    .spiwr_fifo_out_valid       (    spiwr_fifo_out_valid       ),
    .spiwr_fifo_out_data        (    spiwr_fifo_out_data        ),
    .spiwr_fifo_out_ready       (    spiwr_fifo_out_ready       ),
    .spird_fifo_in_ready        (    spird_fifo_in_ready        ),
    .spird_fifo_in_valid        (    spird_fifo_in_valid        ),
    .spird_fifo_in_data         (    spird_fifo_in_data         ),
    .sclk                       (    spi_SCLK                   ),
    .scs                        (    spi_SS_n                   ),
    .mosi                       (    spi_MOSI                   ),
    .miso                       (    spi_MISO                   )
);
endmodule
