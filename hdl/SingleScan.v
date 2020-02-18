/*=============================================================================
# FileName    : SingleScan.v
# Author      : author
# Email       : email@email.com
# Description : 
# Version     : 1.0
# LastChange  : 2018-11-02 14:00:44
# ChangeLog   : 
=============================================================================*/
`timescale 1 ns/1 ns

module SingleScan
(
    input   wire                clk,
    input   wire                readhead_sig,
    input   wire                pwr_rst,
    input   wire                [0:0] rx_datain,

    output  wire                pwm,
    output  wire                LED1,
    output  wire                LED2,
    input   wire                spi_MISO,
    output  wire                spi_MOSI,
    output  wire                spi_SCLK,
    output  wire                spi_SS_n,

    output  wire                epcq32_dclk,
    output  wire                epcq32_sce,
    output  wire                epcq32_sdo,
    input   wire                epcq32_data0,

    output  wire                scl,
    inout   wire                sda,
    output  wire [02:00]        alarm_io,
    output  reg                 alarm_io3,
    input   wire [03:00]        alarm_select_io,  // 选择使用的报警区域组, 默认输入低电平

    output  wire [0:0]          tx_dataout,
    output  wire                send_test_pin,  // AB13

    //input   wire [33:00]        test_in_port,
    output  wire [32:00]        test_out_port,
    output  wire [00:00]        cpu_test_io,

    output  wire                ad5302_ldac_n,
    output  wire                ad5302_sync_n,
    output  wire                ad5302_sclk,
    output  wire                ad5302_dout,

    output  wire [0:0]          send_data,
    output  wire                ad5302_ldac_n_LD, 
    output  wire                ad5302_sync_n_LD, 
    output  wire                ad5302_sclk_LD,   
    output  wire                ad5302_dout_LD,  

    input   wire                adt7301_din,
    output  wire                adt7301_cs_n,
    output  wire                adt7301_sclk,
    output  wire                adt7301_dout,
    output  wire                HEN,

    output  wire                w5500_rst

);

wire    [255:00]            fpga_status;
reg     [11:00]             zero_pulse_width /* synthesis keep */;
wire    [31:00]             sys_temp /* synthesis keep */;
wire    [09:00]             dust_cnt /* synthesis keep */;
wire    [15:00]             zero_value /* synthesis keep */;     // 零位距离值
wire    [31:00]             cycle_cnt /* synthesis keep */;  // 单圈总计数值
wire    [07:00]             degree_para /* synthesis keep */; 

wire                        enable;
wire                        cycle_enable;
wire                        single_target_valid /* synthesis keep */;    // 单次计算结束时给出的标志位
wire    [17:00]             single_target_pos /* synthesis keep */;
wire                        target_valid /* synthesis keep */;    // 角度范围内的平均
wire    [15:00]             target_pos /* synthesis keep */;
wire    [15:00]             target_gray /* synthesis keep */;

wire                        target_1us_valid /* synthesis keep */;    // 角度范围内的平均
wire    [17:00]             target_1us_pos /* synthesis keep */;
wire    [17:00]             target_1us_gray /* synthesis keep */;

wire                        target_33_valid /* synthesis keep */;    // 角度范围内的平均
wire    [15:00]             target_33_pos /* synthesis keep */;
wire    [15:00]             target_33_gray /* synthesis keep */;

wire    [07:00]             step_cnt /* synthesis keep */;
// wire    [31:00]             speed_cnt /* synthesis keep */;

wire                        region0_rden;
wire    [09:00]             region0_rdaddr;
wire    [17:00]             region0_rddata;

wire                        region1_rden;
wire    [09:00]             region1_rdaddr;
wire    [17:00]             region1_rddata;

wire                        region2_rden;
wire    [09:00]             region2_rdaddr;
wire    [17:00]             region2_rddata;
wire    [61:00]             system_para;
wire    [239:00]            laser_presdo;
wire    [89:00]             da_cycle_para;
wire    [241:00]            distance_para;
wire                        gxb_pwrdn;

wire                        rst_n/* synthesis keep */;
wire    [15:00]             rx_dataout;

wire                        rx_clkout /* synthesis keep */;
wire                        tx_clkout /* synthesis keep */;
wire                        send_en;
wire                        wheel_fall;
wire                        motor_block;
wire                        valid_region_finish;
wire                        zero_flag /* synthesis keep */;
wire                        real_zero_flag /* synthesis keep */;
wire                        virtual_zero_flag /* synthesis keep */;
wire                        alarm_dust;

assign                  zero_flag = (step_cnt == 0);

wire                        set_en;

wire    [15:00]             tx_datain;


wire    [15:00]             zero_distance_revise /* synthesis keep */;
wire    [15:00]             zero_angle_revise /* synthesis keep */;
wire    [07:00]             gray_distance_revise1 /* synthesis keep */;  // 20
wire    [07:00]             gray_distance_revise2 /* synthesis keep */;  // 35
wire    [07:00]             gray_distance_revise3 /* synthesis keep */;
wire    [07:00]             gray_distance_revise4 /* synthesis keep */;
wire    [07:00]             gray_distance_revise5 /* synthesis keep */;
wire    [07:00]             laser_pulse_width /* synthesis keep */;      // 4
wire    [07:00]             laser_recv_delay;      // 8
wire    [07:00]             noise_diff_setting1 /* synthesis keep */;     // 200
wire    [07:00]             noise_diff_setting2 /* synthesis keep */;     // 200
wire    [15:00]             apd_volt_setting /* synthesis keep */;
wire    [09:00]             gray_inflection1 /* synthesis keep */;        // 14
wire    [09:00]             gray_inflection2 /* synthesis keep */;
wire    [09:00]             gray_inflection3 /* synthesis keep */;
wire    [09:00]             gray_inflection4 /* synthesis keep */;
wire    [15:00]             apd_vol_base /* synthesis keep */;

wire    [07:00]             temp_volt_cof1;
wire    [07:00]             temp_volt_cof2;
wire    [07:00]             temp_volt_inflection;
wire    [07:00]             valid_num_threshold;

wire    [07:00]             temp_distance_cof1;
wire    [07:00]             temp_distance_cof2;
wire    [07:00]             temp_distance_inflection;

wire    [07:00]             min_display_distance;
wire    [07:00]             first_noise_filter;
wire    [07:00]             dust_alarm_threshold /* synthesis keep */;

wire    [31:00]             laser_freq /* synthesis keep */;
wire    [07:00]             motor_speed /* synthesis keep */;
wire    [15:00]             min_target_size/* synthesis keep */;
wire    [09:00]             alarm_output_threshold/* synthesis keep */;

wire    [01:00]             hw_type;        // 1, NPN;  2, PNP
wire                        laser_enable /* synthesis keep */;
wire                        upload_en /* synthesis keep */;
wire                        motor_enable /* synthesis keep */;
wire                        dac_set_flag;
wire                        light_dac_set_flag;

wire                        clk_100m  /* synthesis keep */;
wire                        laser_enable_test /* synthesis keep */;
//assign laser_enable_test=((step_cnt <= 40)&&(step_cnt >= 20))?1'b0:1'b1;

pll_100m pll_100mEx01(
    .inclk0                 (    clk                    ),
    .locked                 (    locked                 ),
    .c0                     (    clk_100m               )
);

rst_module      rst_moduleEx01
(
    .clk                    (    clk                    ),
    .pwr_rst                (    pwr_rst                ),
    .sys_rst                (    1'b0                   ),

    .rst_n                  (    rst_n                  ),
    .gxb_pwrdn              (    gxb_pwrdn              )
);

laser_send_top laser_send_topEx01
(
    .clk                    (    clk                    ),
    .clk_125m               (    rx_clkout              ),
    .rst_n                  (    rst_n                  ),
    .laser_enable           (    laser_enable           ),
    .laser_presdo           (    laser_presdo           ),
    .send_data              (    send_data              ),
    .send_en                (    send_en                )
);

altgx_drive altgx_driveEx01
(
    .clk                    (    clk                    ),
    .rst_n                  (    rst_n                  ),
    .rx_datain              (    rx_datain              ),
    .tx_dataout             (    tx_dataout             ),
    .rx_clkout              (    rx_clkout              ),
    .tx_clkout              (    tx_clkout              ),
    .rx_dataout             (    rx_dataout             )
);
//                       按照通信协议, 从上到下排列
assign                  {
                                    alarm_output_threshold,
                                    min_target_size,
                                    valid_num_threshold,
                                    laser_recv_delay,   // 8bit
                                    zero_distance_revise,   // 16bit
                                    gray_distance_revise1,  // 8bit
                                    gray_distance_revise2,  // 8bit
                                    gray_distance_revise3,  // 8bit
                                    gray_distance_revise4,  // 8bit
                                    gray_distance_revise5,  // 8bit
                                    gray_inflection1,       // 8bit
                                    gray_inflection2,       // 8bit
                                    gray_inflection3,       // 8bit
                                    gray_inflection4,       // 8bit
                                    noise_diff_setting1,    // 8bit
                                    noise_diff_setting2,    // 8bit
                                    apd_volt_setting,       // 16bit
                                    temp_volt_cof1,         // 8bit
                                    temp_volt_cof2,         // 8bit
                                    temp_volt_inflection,   // 8bit
                                    
                                    temp_distance_cof1,     // 8bit
                                    temp_distance_cof2,     // 8bit
                                    temp_distance_inflection,   // 8bit

                                    min_display_distance,     // 8bit
                                    first_noise_filter,     // 8bit
                                    dust_alarm_threshold      // 8bit
                        } = distance_para;
 
assign                  {
                                    laser_freq,     // 32bit
                                    motor_speed,    // 8bit
                                    zero_angle_revise,  // 8bit

                                    hw_type,
                                    laser_enable,   // 1bit
                                    upload_en,      // 1bit
                                    motor_enable,   // 1bit
                                    dac_set_flag   // 1bit
                            } = system_para ;

Ranging_distance Ranging_distanceEx01
(
    .clk                    (    rx_clkout              ),
    .rst_n                  (    rst_n                  ),
    .da_cycle_para          (    da_cycle_para          ),
    .send_en                (    send_en                ),
    .rx_dataout             (    rx_dataout             ),
	 .laser_enable           (    laser_enable           ),
    .distance_para          (    distance_para          ),
    .sys_temp               (    sys_temp               ),
    .target_valid           (    target_1us_valid       ),
    .target_pos             (    target_1us_pos         ),
    .target_time_pluse      (    target_1us_gray        ),
    .dac_set_flag           (    dac_set_flag           ),
    .m_axis_tready          (    1'b1                   ),
    .adt7301_din            (    adt7301_din            ),
    .adt7301_cs_n           (    adt7301_cs_n           ),
    .adt7301_sclk           (    adt7301_sclk           ),
    .adt7301_dout           (    adt7301_dout           ),
    .ad5302_ldac_n          (    ad5302_ldac_n          ),
    .ad5302_sync_n          (    ad5302_sync_n          ),
    .ad5302_sclk            (    ad5302_sclk            ),
    .ad5302_dout            (    ad5302_dout            ),
    .HEN                    (    HEN                    ),
    .ad5302_ldac_n_LD       (    ad5302_ldac_n_LD       ),
    .ad5302_sync_n_LD       (    ad5302_sync_n_LD       ),
    .ad5302_sclk_LD         (    ad5302_sclk_LD         ),
    .ad5302_dout_LD         (    ad5302_dout_LD         )
);


motor_top motor_topEx01
(
    .clk                    (    rx_clkout              ),
    .rst_n                  (    rst_n                  ),
    .readhead_sig           (    readhead_sig           ),
    .motor_enable           (    motor_enable           ),
    .motor_speed            (    motor_speed            ),
    .pwm                    (    pwm                    ),
    .real_zero_flag         (    real_zero_flag         ),
    .virtual_zero_flag      (    virtual_zero_flag      ),
    .wheel_fall             (    wheel_fall             ),
    .motor_block            (    motor_block            ),
    .valid_region_finish    (    valid_region_finish    ),
    .step_cnt               (    step_cnt               ),
    .cycle_cnt              (    cycle_cnt              ),
    .degree_para            (    degree_para            ),
    .cycle_enable           (                           ),
    .valid_angle            (                           )
);

calc_distance_top calc_distance_topEx01
(
    .clk                    (    rx_clkout              ),
    .rst_n                  (    rst_n                  ),
    .send_en                (    send_en                ),
    .valid_num_threshold    (    valid_num_threshold    ),
    .dust_alarm_threshold   (    dust_alarm_threshold   ),
    .zero_distance_revise   (    zero_distance_revise   ),

    .valid_in               (    target_1us_valid       ),
    .distance_in            (    target_1us_pos         ),
    .gray_in                (    target_1us_gray        ),
    .zero_flag              (    virtual_zero_flag      ),
    .wheel_fall             (    wheel_fall             ),
    .step_cnt               (    step_cnt               ),
    .degree_para            (    degree_para            ),
    .CORRECT_PULSE_WIDTH    (    noise_diff_setting2    ),
    .dust_cnt               (    dust_cnt               ),
    .zero_value             (    zero_value             ),
    .target_valid           (    target_33_valid        ),
    .target_pos             (    target_33_pos          ),
    .target_gray            (    target_gray            )
);

data_select data_selectEx01
(
    .clk                    (    rx_clkout              ),
    .rst_n                  (    rst_n                  ),
    .zero_flag              (    virtual_zero_flag      ),
    .angle_offset           (    zero_angle_revise      ),
    .min_display_distance   (    min_display_distance   ),

    .data_in_valid          (    target_33_valid        ),
    .data_in                (    target_33_pos          ),

    .cycle_enable           (    cycle_enable           ),
    .data_out_valid         (    target_valid           ),
    .data_out               (    target_pos             )
);

compare_region compare_regionEx01
(
    .clk                    (    rx_clkout              ),
    .rst_n                  (    rst_n                  ),
    .hw_type                (    hw_type                ),
    .upload_en              (    upload_en              ),
    .cycle_enable           (    cycle_enable           ),
    .target_valid           (    target_valid           ),
    .target_pos             (    target_pos             ),
	 .min_target_size        (    min_target_size        ),
    .alarm_output_threshold (    alarm_output_threshold ),
    .region0_rden           (    region0_rden           ),
    .region0_rdaddr         (    region0_rdaddr         ),
    .region0_rddata         (    region0_rddata         ),
    .region1_rden           (    region1_rden           ),
    .region1_rdaddr         (    region1_rdaddr         ),
    .region1_rddata         (    region1_rddata         ),
    .region2_rden           (    region2_rden           ),
    .region2_rdaddr         (    region2_rdaddr         ),
    .region2_rddata         (    region2_rddata         ),
    .alarm_io               (    alarm_io               )//区域报警端口
);

always @ (*)
begin
    // NPN, 默认状态下IO要输出高电平， 经过三极管后才会变成需要的低电平
    // 有报警信息后IO要输出低电平,  经过三极管后才会变成需要的高电平
    if(hw_type == 1) 
    begin
        // laser_freq[0] = 1， 发生了4个报警信息任意一个
        if(laser_freq[0])
            alarm_io3 = 0;
        else
            alarm_io3 = ~(step_cnt == 10);
    end
    else            // PNP
    begin
        if(laser_freq[0])
            alarm_io3 = 1;
        else
            alarm_io3 = (step_cnt == 10);
    end
end

wire                        fifo_rdreq;
wire    [31:00]             fifo_rddata;
wire    [10:00]             fifo_usedw;
wire                        w5500_int;
wire                        power_led;
wire                        status_led;

pos_buffer pos_bufferEx01
(
    .clk                    (    rx_clkout              ),
    .clk_100m               (    clk_100m               ),
    .rst                    (    rst_n                  ),
    .update_enable          (    upload_en              ),
    .cycle_enable           (    cycle_enable           ),
    .target_valid           (    target_valid           ),
    .target_pos             (    target_pos             ),
    .target_gray            (    target_gray            ),

    .fifo_rdreq             (    fifo_rdreq             ),
    .fifo_rddata            (    fifo_rddata            ),
    .fifo_usedw             (    fifo_usedw             )
);

reg     [20:00]             test_cnt;

always @ (posedge rx_clkout or negedge rst_n)
begin
    if(~rst_n)
        test_cnt <= 0;
    else if(wheel_fall)
        test_cnt <= 0;
    else
        test_cnt <= test_cnt + 1'b1;
end
assign                  test_out_port = test_cnt;

always @ (posedge rx_clkout)
begin
    if(virtual_zero_flag)
        zero_pulse_width <= target_1us_gray;
end
//assign                  test_out_port = target_valid + target_pos;
assign                  fpga_status = { 
                                    96'd0, 
                                    17'd0, zero_pulse_width, alarm_io, 
                                    upload_en, sys_temp[30:00], 
                                    22'd0, dust_cnt, 
                                    16'd0, zero_value, 
                                    motor_block, cycle_cnt[30:00]
                                };
assign                  LED1 = power_led;
assign                  LED2 = status_led;

cpu_top cpu_topEx01
(
    .clk_125m               (    rx_clkout              ),
    .clk_100m               (    clk_100m               ),
    .rst_n                  (    rst_n                  ),
    .scl                    (    scl                    ),
    .sda                    (    sda                    ),
    .power_led              (    power_led              ),                       //                        power_led.export
    .status_led             (    status_led             ),
    .cpu_test_io            (    cpu_test_io            ),
    .alarm_select_io        (    alarm_select_io        ),
    .spi_MISO               (    spi_MISO               ),
    .spi_MOSI               (    spi_MOSI               ),
    .spi_SCLK               (    spi_SCLK               ),
    .spi_SS_n               (    spi_SS_n               ),

    .epcq32_dclk            (    epcq32_dclk            ),
    .epcq32_sce             (    epcq32_sce             ),
    .epcq32_sdo             (    epcq32_sdo             ),
    .epcq32_data0           (    epcq32_data0           ),

    .w5500_rst              (    w5500_rst              ),
    .w5500_int              (    w5500_int              ),

    .valid_region_finish    (    valid_region_finish    ),
    .region0_rden           (    region0_rden           ),
    .region0_rdaddr         (    region0_rdaddr         ),
    .region0_rddata         (    region0_rddata         ),
    .region1_rden           (    region1_rden           ),
    .region1_rdaddr         (    region1_rdaddr         ),
    .region1_rddata         (    region1_rddata         ),
    .region2_rden           (    region2_rden           ),
    .region2_rdaddr         (    region2_rdaddr         ),
    .region2_rddata         (    region2_rddata         ),

    .fpga_status            (    fpga_status            ),

    .laser_presdo           (    laser_presdo           ),
    .system_para            (    system_para            ),
    .da_cycle_para          (    da_cycle_para          ),
    .distance_para          (    distance_para          ),
    .fifo_rdreq             (    fifo_rdreq             ),
    .fifo_rddata            (    fifo_rddata            ),
    .fifo_usedw             (    fifo_usedw             )
);

endmodule
