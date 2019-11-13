/*=============================================================================
# FileName    :	motor_top.v
# Author      :	author
# Email       :	email@email.com
# Description :	
# Version     :	1.0
# LastChange  :	2018-10-08 15:06:00
# ChangeLog   :	
=============================================================================*/
`timescale  1 ns/1 ps

module motor_top
(
    input   wire                clk,
    input   wire                rst_n,
    /*port*/
    input   wire                readhead_sig,

    input   wire                motor_enable,
    input   wire [31:00]        motor_speed,        // N round/s

    output  wire                pwm,

    output  wire                real_zero_flag,
    output  wire                virtual_zero_flag,
    output  wire                wheel_fall,
    output  wire                motor_block,   // 使能电机转动时, 电机不转
    output  wire                valid_region_finish,
    output  wire [07:00]        step_cnt,
    output  wire [31:00]        cycle_cnt,
    output  wire [07:00]        degree_para,

    output  wire                cycle_enable,
    output  wire                valid_angle
);

`ifdef  DEBUG_MOTOR
    reg     [31:00]             cnt;
    reg     [07:00]             step;

    assign                  wheel_fall = (cnt == 1);
    assign                  step_cnt = step;
    assign                  virtual_zero_flag = (step_cnt == 0) && (cnt == 1);
    assign                  degree_para = 60;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        cnt <= 0;
        step <= 0;
    end
    else
    begin
        if(cnt >= 185125)
        begin
            cnt <= 0;

            if(step >= 43)
                step <= 0;
            else
                step <= step + 1;
        end
        else
        begin
            cnt <= cnt + 1'b1;
        end
    end

end

`else
wire    [15:00]             high_cnt /* synthesis keep */;
wire    [15:00]             low_cnt /* synthesis keep */;
wire    [31:00]             sub_cnt;      // sub
wire    [31:00]             speed_cnt;

wire                        pulse_sig /* synthesis keep */;
pwm_drive pwm_driveEx01
(
    .clk                  (    clk                  ),
    .rst_n                (    rst_n                ),
    .enable               (    motor_enable          ),
    .high_cnt             (    high_cnt             ),
    .low_cnt              (    low_cnt              ),
    .pwm                  (    pwm                  )
);

filter_signal filter_signalEx01
(
    .clk                  (    clk                  ),
    .rst_n                (    rst_n                ),
    .data_in              (    readhead_sig         ),
    .data_out             (    pulse_sig            )
);

motor_info motor_infoEx01
(
    .clk                  (    clk                  ),
    .rst_n                (    rst_n                ),
    .motor_enable         (    motor_enable         ),
    .pulse_sig            (    pulse_sig            ),
    .real_zero_flag       (    real_zero_flag       ),
    .virtual_zero_flag    (    virtual_zero_flag    ),
    .wheel_fall           (    wheel_fall           ),
    .motor_block          (    motor_block          ),
    .valid_region_finish  (    valid_region_finish  ),
    .cycle_cnt            (    cycle_cnt            ),
    .degree_para          (    degree_para          ),
    .step_cnt             (    step_cnt             ),
    .sub_cnt              (    sub_cnt              ),
    .speed_cnt            (    speed_cnt            ),
    .feed_valid           (    feed_valid           )
);

feed feedEx01
(
    .clk                  (    clk                  ),
    .rst_n                (    rst_n                ),
    .motor_speed          (    motor_speed          ),
    .real_zero_flag       (    real_zero_flag       ),
    .cycle_cnt            (    cycle_cnt            ),
    .step_cnt             (    step_cnt             ),
    .sub_cnt              (    sub_cnt              ),
    .feed_valid           (    feed_valid           ),
    .speed_cnt            (    speed_cnt            ),
    .high_cnt             (    high_cnt             ),
    .low_cnt              (    low_cnt              )
);

// angle_valid angle_validEx01
// (
//     .clk                 (  clk                     ),
//     .rst_n               (  rst_n                   ),
//     .real_zero_flag      (  real_zero_flag          ),
//     .virtual_zero_flag   (  virtual_zero_flag       ),
//     .wheel_fall          (  wheel_fall &(&cycle_cnt)              ),
//     .sub_cnt             (  sub_cnt                 ),
//     .speed_cnt           (  speed_cnt               ),
//     .cycle_enable        (  cycle_enable            ),
//     .valid_angle         (  valid_angle             )
// );
`endif
endmodule
