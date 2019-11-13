/*=============================================================================
# FileName    :	motor_info.v
# Author      :	author
# Email       :	email@email.com
# Description :	读数头
                电机零位无法直接根据反馈信号的高电平时间来判断，因为当电机速度很慢的时候，高电平的持续时间也会很长
                假设先不管零位电平时间，获得一个当前速度下反馈高电平时间的大概平均值，超过这个时间的才算零位

                电机零位后9个下降沿是测距零位
# Version     :	1.0
# LastChange  :	2018-10-08 17:51:19
# ChangeLog   :	
=============================================================================*/
module motor_info 
(
    input   wire                clk,
    input   wire                rst_n,

    input   wire                motor_enable,
    input   wire                pulse_sig,

    output  wire                real_zero_flag,
    output  wire                virtual_zero_flag,
    output  wire                wheel_fall,
    output  wire                motor_block,   // 使能电机转动时, 电机不转
    output  wire                valid_region_finish,   // 270°比较区域以及结束, 此标志有效后才能加载新的区域数据

    output  wire [31:00]        cycle_cnt,
    output  wire [07:00]        degree_para,
    output  reg  [07:00]        step_cnt,
    output  reg  [31:00]        sub_cnt,
    output  reg  [31:00]        speed_cnt,
    output  wire                feed_valid         // 有效期间，计算电机反馈速度，跳过物理零点
);

wire                        valid_region_finish_w;
reg     [07:00]             motor_step_cnt;

reg    [1:0]            pulse_sig_r;
wire                    pulse_sig_rise;
wire                    pulse_sig_fall /* synthesis keep */;

reg     [31:00]             pulse_high_cnt;
reg     [31:00]             pulse_low_cnt;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        pulse_high_cnt <= 0;
    else if(pulse_sig_fall)
        pulse_high_cnt <= 0;
    else if(pulse_sig)
        pulse_high_cnt <= pulse_high_cnt + 1'b1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        pulse_low_cnt <= 0;
    else if(pulse_sig_fall)
        pulse_low_cnt <= 0;
    else if(~pulse_sig)
        pulse_low_cnt <= pulse_low_cnt + 1'b1;
end

assign          pulse_sig_rise = pulse_sig_r[1:0] == 2'b01;
assign          pulse_sig_fall = pulse_sig_r[1:0] == 2'b10;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        pulse_sig_r    <= 2'b00;
    else
        pulse_sig_r    <= {pulse_sig_r[0], pulse_sig};
end

localparam              IDLE        = 0;
localparam              START1      = 1;  // 先跳过两个边沿，防止低电平计数错误
localparam              START2      = 2;
localparam              SKIP        = 3;
localparam              WORK        = 4;
(* KEEP = "TRUE" *)reg     [WORK:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[START1]: cs_STRING = "START1";
        cs[START2]: cs_STRING = "START2";
        cs[SKIP]: cs_STRING = "SKIP";
        cs[WORK]: cs_STRING = "WORK";
        default: cs_STRING = "XXXX";
    endcase
end
// synthesis translate_on

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cs <= 'd1;
    else
        cs <= ns;
end

always @(*)
begin
    ns = 'd0;
    if(~motor_enable)
        ns[IDLE] = 1'b1;
    else
    begin
        case(1'b1)
            cs[IDLE]:
            begin
                if(pulse_sig_fall)
                    ns[START1] = 1'b1;
                else
                    ns[IDLE] = 1'b1;
            end
            cs[START1]:
            begin
                if(pulse_sig_rise)
                    ns[START2] = 1'b1;
                else
                    ns[START1] = 1'b1;
            end
            cs[START2]:
            begin
                if(pulse_high_cnt > (pulse_low_cnt + (pulse_low_cnt>>1)))  // 电机零位时的高电平脉冲时间较长
                    ns[SKIP] = 1'b1;
                else
                    ns[START2] = 1'b1;
            end
            cs[SKIP]:
            begin
                if(pulse_sig_fall)  // 等待高电平的下降沿，说明零位的高脉冲已经结束
                    ns[WORK] = 1'b1;
                else
                    ns[SKIP] = 1'b1;
            end
            cs[WORK]:
            begin
                if(motor_block )       // 电机堵转或者禁止电机运转的时候返回IDLE状态
                    ns[IDLE] = 1'b1;
                else if(motor_step_cnt >= 43)
                    ns[START2] = 1'b1;
                else
                    ns[WORK] = 1'b1;
            end
            default:
                ns[IDLE] = 1'b1;
        endcase
    end
end


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        state_cnt <= 0;
    else if (cs != ns)
        state_cnt <= 0;
    else
        state_cnt <= state_cnt + 1'b1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        motor_step_cnt <= 0;
    else if(cs[WORK])
    begin
        if(pulse_sig_fall)
            motor_step_cnt <= motor_step_cnt + 1'b1;
    end
    else
        motor_step_cnt <= 0;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        sub_cnt <= 0;
    else if(cs[WORK])
    begin
        if(pulse_sig_fall)
            sub_cnt <= 0;
        else
            sub_cnt <= sub_cnt + 1'b1;
    end
    else
        sub_cnt <= 0;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        //speed_cnt <= 0;
        speed_cnt <= 184365;  // 仿真时用到这个值
    else if(cs[WORK])
    begin
        if(pulse_sig_fall)
            speed_cnt <= sub_cnt;
    end
end

assign                  feed_valid = (motor_step_cnt >= 1) & (motor_step_cnt <= 42);
assign                  real_zero_flag = cs[START2] & ns[SKIP];
assign                  virtual_zero_flag = pulse_sig_fall & cs[WORK] & (motor_step_cnt == 8);
assign                  wheel_fall = pulse_sig_fall;

reg     [31:00]             cycle_cnt_r;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cycle_cnt_r <= 0;
    else if(real_zero_flag)
        cycle_cnt_r <= 0;
    else
        cycle_cnt_r <= cycle_cnt_r + 1'b1;
end

move_average #
(
    .WIDTH           (  32              ),
    .AVE_N           (  4              )
)
move_averageEx01
(
    .clk             (  clk                 ),
    .rst_n           (  rst_n               ),
    .enable          (  motor_enable        ),
    .data_in_valid   (  real_zero_flag      ),
    .data_in         (  cycle_cnt_r         ),
    .data_out_valid  (                      ),
    .data_out        (  cycle_cnt           )
);


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        step_cnt <= 0;
    else if(motor_enable)
    begin
        if(virtual_zero_flag)
            step_cnt <= 0;
        else if(wheel_fall)
            step_cnt <= step_cnt + 1'b1;
    end
    else
        step_cnt <= 0;
end

// 1000000000/2/8/20 = 3125000
reg     [31:00]             time_cnt;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        time_cnt <= 0;
    else if(motor_enable)
    begin
        if(pulse_sig_rise)
            time_cnt <= 0;
        else
        begin
            if(time_cnt <= 3125000)   // 电机很长时间没有转动
                time_cnt <= time_cnt + 1'b1;
        end
    end
    else
        time_cnt <= 0;
end
assign                  motor_block = motor_enable & (time_cnt >= 3125000) ? 1 : 0;

assign                  valid_region_finish_w = (step_cnt == 40);

reg    [1:0]            valid_region_finish_r;
wire                    valid_region_finish_rise;
wire                    valid_region_finish_fall;

assign                  valid_region_finish = valid_region_finish_rise;
assign          valid_region_finish_rise = valid_region_finish_r[1:0] == 2'b01;
assign          valid_region_finish_fall = valid_region_finish_r[1:0] == 2'b10;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        valid_region_finish_r    <= 2'b00;
    else 
        valid_region_finish_r    <= {valid_region_finish_r[0], valid_region_finish_w};
end

degree_info degree_infoEx01
(
    .clk         (  clk             ),
    .cycle_cnt   (  cycle_cnt       ),
    .degree_para (  degree_para     )
);
endmodule
