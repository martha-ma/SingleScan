`timescale  1 ns/1 ps

module calc_distance_top
(
    input                       clk,
    input                       rst_n,

    input        [07:00]        valid_num_threshold,
    input        [07:00]        dust_alarm_threshold,
    input        [15:00]        zero_distance_revise,
    input                       send_en,

    input                       valid_in,
    input        [15:00]        distance_in,
    input        [15:00]        gray_in,
    input        [07:00]        CORRECT_PULSE_WIDTH,
    input                       zero_flag, 
    input                       wheel_fall, 
    input        [07:00]        step_cnt,
    input        [07:00]        degree_para,   // 0.333°需要采集多少次数据

    output       [09:00]        dust_cnt,
    output       [15:00]        zero_value,
    output                      target_valid,
    output       [15:00]        target_pos,
    output       [15:00]        target_gray
);

wire                        tannis_change;
wire                        tannis1_left_wren;
wire                        tannis1_left_rden;
wire    [07:00]             tannis1_left_addr;
wire    [47:00]             tannis1_left_wrdata;
wire    [47:00]             tannis1_left_rddata;

wire                        tannis1_right_wren;
wire                        tannis1_right_rden;
wire    [07:00]             tannis1_right_addr;
wire    [47:00]             tannis1_right_wrdata;
wire    [47:00]             tannis1_right_rddata;

wire                        tannis2_left_wren;
wire                        tannis2_left_rden;
wire    [07:00]             tannis2_left_addr;
wire    [47:00]             tannis2_left_wrdata;
wire    [47:00]             tannis2_left_rddata;

wire                        tannis2_right_wren;
wire                        tannis2_right_rden;
wire    [07:00]             tannis2_right_addr;
wire    [47:00]             tannis2_right_wrdata;
wire    [47:00]             tannis2_right_rddata;

grid_division grid_divisionEx01
(
    .clk                     (    clk                     ),
    .rst_n                   (    rst_n                   ),
    .send_en                 (    send_en                 ),
    .valid_in                (    valid_in                ),
    .distance_in             (    distance_in             ),
    .gray_in                 (    gray_in                 ),

    .zero_flag               (    zero_flag               ),
    .wheel_fall              (    wheel_fall              ),
    .step_cnt                (    step_cnt                ),
    .degree_para             (    degree_para-0           ),

    .tannis_change           (    tannis_change           ),
    .tannis1_left_wren       (    tannis1_left_wren       ),
    .tannis1_left_rden       (    tannis1_left_rden       ),
    .tannis1_left_addr       (    tannis1_left_addr       ),
    .tannis1_left_wrdata     (    tannis1_left_wrdata     ),
    .tannis1_left_rddata     (    tannis1_left_rddata     ),

    .tannis2_left_wren       (    tannis2_left_wren       ),
    .tannis2_left_rden       (    tannis2_left_rden       ),
    .tannis2_left_addr       (    tannis2_left_addr       ),
    .tannis2_left_wrdata     (    tannis2_left_wrdata     ),
    .tannis2_left_rddata     (    tannis2_left_rddata     )
);

grid_ram grid_ramEx01
(
    .clock_a                 (    clk                     ),

    .rden_a                  (    tannis1_left_rden       ),
    .wren_a                  (    tannis1_left_wren       ),
    .address_a               (    tannis1_left_addr       ),
    .data_a                  (    tannis1_left_wrdata     ),
    .q_a                     (    tannis1_left_rddata     ),

    .clock_b                 (    clk                     ),

    .rden_b                  (    tannis1_right_rden      ),
    .wren_b                  (    tannis1_right_wren      ),
    .address_b               (    tannis1_right_addr      ),
    .data_b                  (    tannis1_right_wrdata    ),
    .q_b                     (    tannis1_right_rddata    )
);

grid_ram grid_ramEx02
(
    .clock_a                 (    clk                     ),

    .rden_a                  (    tannis2_left_rden       ),
    .wren_a                  (    tannis2_left_wren       ),
    .address_a               (    tannis2_left_addr       ),
    .data_a                  (    tannis2_left_wrdata     ),
    .q_a                     (    tannis2_left_rddata     ),

    .clock_b                 (    clk                     ),

    .rden_b                  (    tannis2_right_rden      ),
    .wren_b                  (    tannis2_right_wren      ),
    .address_b               (    tannis2_right_addr      ),
    .data_b                  (    tannis2_right_wrdata    ),
    .q_b                     (    tannis2_right_rddata    )
);

wire                        target_valid_s0  /* synthesis keep */;
wire    [15:00]             target_pos_s0   /* synthesis keep */;
wire    [15:00]             target_gray_s0   /* synthesis keep */;

wire                        target_valid_s1     /* synthesis keep */;
wire    [15:00]             target_pos_s1   /* synthesis keep */;
grid_statistical grid_statisticalEx01
(
    .clk                     (    clk                     ),
    .rst_n                   (    rst_n                   ),
    .valid_num_threshold     (    valid_num_threshold     ),
    .zero_flag               (    zero_flag               ),
    .step_cnt                (    step_cnt                ),
    .wheel_fall              (    wheel_fall              ),
    .tannis_change           (    tannis_change           ),

    .tannis1_right_wren      (    tannis1_right_wren      ),
    .tannis1_right_wrdata    (    tannis1_right_wrdata    ),
    .tannis1_right_rden      (    tannis1_right_rden      ),
    .tannis1_right_addr      (    tannis1_right_addr      ),
    .tannis1_right_rddata    (    tannis1_right_rddata    ),

    .tannis2_right_wren      (    tannis2_right_wren      ),
    .tannis2_right_wrdata    (    tannis2_right_wrdata    ),
    .tannis2_right_rden      (    tannis2_right_rden      ),
    .tannis2_right_addr      (    tannis2_right_addr      ),
    .tannis2_right_rddata    (    tannis2_right_rddata    ),
    .target_valid            (    target_valid_s0         ),
    .target_gray             (    target_gray             ),
	 
	.CORRECT_PULSE_WIDTH     (    CORRECT_PULSE_WIDTH     ),
    .target_pos              (    target_pos_s0           )
);

zero_distance zero_distanceEx01
(
    .clk                     (    clk                     ),
    .rst_n                   (    rst_n                   ),
    .zero_distance_revise    (    zero_distance_revise    ),
    .zero_flag               (    zero_flag               ),
    .data_in_valid           (    target_valid_s0         ),
    .data_in                 (    target_pos_s0           ),
    .data_out                (    zero_value              )
);

zero_revise zero_reviseEx01
(
    .clk                     (    clk                     ),
    .rst_n                   (    rst_n                   ),
    .zero_value              (    zero_value              ),
    .data_in_valid           (    target_valid_s0         ),
    .data_in                 (    target_pos_s0           ),
    .data_out_valid          (    target_valid_s1         ),
    .data_out                (    target_pos_s1           )
);


dust_alarm dust_alarmEx01
(
    .clk                     (    clk                     ),
    .rst_n                   (    rst_n                   ),
    .dust_alarm_threshold    (    dust_alarm_threshold    ),
    .zero_flag               (    zero_flag               ),
    .data_in_valid           (    target_valid_s1         ),
    .data_in                 (    target_pos_s1           ),
    .data_out_valid          (    target_valid            ),
    .data_out                (    target_pos              ),
    .dust_cnt                (    dust_cnt                )
);
endmodule
