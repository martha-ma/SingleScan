`timescale  1 ns/1 ps

module motor_test
(
    input   wire                clk,
    input   wire                readhead_sig,
    /*port*/
    output  wire                pwm,
    output  wire                test_port
);

wire [15:0]         step_cnt;        // step
wire [31:0]         sub_cnt;      // sub
wire [31:0]         speed_cnt;
wire                        angle_valid;

wire                        clk_125m /* synthesis keep */;

//pll pllEx01
//(
    //.inclk0  (  clk      ),
    //.c0      (  clk_125m          ),
    //.locked  (        )
//);
motor_top motor_topEx01
(
    .clk                (    clk             ),
    .rst_n              (    rst_n                 ),
    .readhead_sig       (    readhead_sig          ),
    .motor_enable        (    1'b1                  ),
    .motor_speed        (    motor_speed           ),
    .pwm                (    pwm                   ),
    .real_zero_flag     (    real_zero_flag        ),
    .virtual_zero_flag  (    virtual_zero_flag     ),
    .wheel_edge         (    wheel_edge            ),
    .step_cnt           (    step_cnt              )
);

assign                  test_port = (&step_cnt) & (&sub_cnt) & (&speed_cnt) & angle_valid;
endmodule
