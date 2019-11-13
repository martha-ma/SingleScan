/*=============================================================================
# FileName    :	angle_valid.v
# Author      :	author
# Email       :	email@email.com
# Description :	cur_angle = step_cnt*8*3600 + sub_cnt*3600 * 8/speed_cnt;   角度单位：秒
                3600 = (1<<11) + (1<<10) + (1<<9) + (1<<4)

                根据读数头反馈信号，在811个角度位置输出valid信号
# Version     :	1.0
# LastChange  :	2018-12-12 17:43:11
# ChangeLog   :	
=============================================================================*/


`timescale  1 ns/1 ps

module angle_valid
(
    input   wire                clk,
    input   wire                rst_n,
    /*port*/

    input   wire                real_zero_flag,
    input   wire                virtual_zero_flag,
    input   wire                wheel_fall,

    input   wire [31:00]        sub_cnt,
    input   wire [31:00]        speed_cnt,

    output  reg                 cycle_enable,
    output  wire                valid_angle  // motor每输出811次
);

localparam              START_POS = 5;
localparam              PHY_POS = 34;
localparam              END_POS = 37;

reg     [10:00]             step_cnt;
reg     [09:00]             time_cnt;
wire                        time_flag;
reg     [31:00]             cur_angle;
reg     [31:00]             diff_value;  // 物理零位的值暂时无法计算，以上一次
assign                  time_flag = &time_cnt;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        step_cnt <= 0;
    else if(virtual_zero_flag)
        step_cnt <= 0;
    else if(wheel_fall)
    begin
        if(step_cnt == 33)
            step_cnt <= step_cnt + 2;
        else
            step_cnt <= step_cnt + 1;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        time_cnt <= 0;
    else
        time_cnt <= time_cnt + 1'b1;
end

reg      [39:00]             delay;
reg      [31:00]             step_angle /* synthesis keep */;    // 大角度，乘法就可以计算出来
reg      [31:00]             s2 /* synthesis keep */;

wire     [31:00]             quotient /* synthesis keep */;      // 商
reg      [31:00]             denom /* synthesis keep */;         // 分母
reg      [31:00]             numer /* synthesis keep */;         // 分子

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        numer <= 0;
    else
        numer <= s2;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        denom <= 0;
    else
        denom <= speed_cnt;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cur_angle <= 0;
    else if(delay[35])    // ready 和 cur_angle同时准备好
    begin
        if((step_cnt == 35) )
            cur_angle <= cur_angle + (diff_value<<3);
        else
            cur_angle <= step_angle + (quotient<<3);
    end
end

// step_cnt*8*3600
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        step_angle <= 0;
    else
        step_angle <= ( ( (step_cnt<<11) + (step_cnt<<10) ) + ( (step_cnt<<9) + (step_cnt<<4) ) ) << 3;
end

// sub_cnt*3600
// 乘8的运算放到算出s2后，不然乘法器位宽不够了
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        s2 <= 0;
    else if(&time_cnt)
        s2 <= ( ( (sub_cnt<<11) + (sub_cnt<<10) ) + ( (sub_cnt<<9) + (sub_cnt<<4) ) );
end



div_distance div_distanceEx01
(
    .clock       (    clk          ),
    .denom       (    speed_cnt    ),
    .numer       (    s2           ),
    // 商
    .quotient    (    quotient     ),
    // 余数
    .remain      (                 )
);

/*
 * 除法器要32个latency
 */
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        delay <= 0;
    else
        delay[39:0] <= {delay[38:0], time_flag};             // 最先进来的数据在最高位
end

reg     [31:00]             quotient_r;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        quotient_r <= 0;
    else
        quotient_r <= quotient;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        diff_value <= 0;
    else if((step_cnt == 33) & (delay[32]))
         diff_value <= quotient - quotient_r;
end

////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
// 根据角度信息，找出符合要求的角度
reg     [31:00]             angle_range;
reg     [09:00]             valid_cnt;
localparam              START_ANGLE = 162000; //45*0.333*3600
localparam              END_ANGLE = 1134000; //315*3600

localparam              IDLE                = 0;
localparam              WAIT1               = 1;
localparam              WAIT2               = 2;
localparam              CHECK_NEED_ANGLE    = 3;
localparam              CALC_NEXT_ANGLE     = 4;
localparam              DELAY               = 5;
localparam              OVER                = 6;
(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[WAIT1]: cs_STRING = "WAIT1";
        cs[WAIT2]: cs_STRING = "WAIT2";
        cs[CHECK_NEED_ANGLE]: cs_STRING = "CHECK_NEED_ANGLE";
        cs[CALC_NEXT_ANGLE]: cs_STRING = "CALC_NEXT_ANGLE";
        cs[DELAY]: cs_STRING = "DELAY";
        cs[OVER]: cs_STRING = "OVER";
        default: cs_STRING = "XXXX";
    endcase
end
// synthesis translate_on

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cs <= 'd1;
    else
        cs <= ns;
end

always @(*)
begin
    ns = 'd0;
    case(1'b1)
        cs[IDLE]:
        begin
            if(virtual_zero_flag)
                ns[WAIT1] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[WAIT1]:
        begin
            if(step_cnt == 2)
                ns[WAIT2] = 1'b1;
            else
                ns[WAIT1] = 1'b1;
        end
        cs[WAIT2]:
        begin
            if(cur_angle > START_ANGLE)
                ns[CALC_NEXT_ANGLE] = 1'b1;
            else
                ns[WAIT2] = 1'b1;
        end
        cs[CALC_NEXT_ANGLE]:
        begin
            ns[CHECK_NEED_ANGLE] = 1'b1;
        end
        cs[CHECK_NEED_ANGLE]:
        begin
            if( time_flag & (cur_angle > (angle_range - 100)) )
                ns[DELAY] = 1'b1;
            else
                ns[CHECK_NEED_ANGLE] = 1'b1;
        end
        cs[DELAY]:
        begin
            if(state_cnt == 100)
            begin
                if(valid_cnt == 811)
                    ns[IDLE] = 1'b1;
                else
                    ns[CALC_NEXT_ANGLE] = 1'b1;
            end
            else
                ns[DELAY] = 1'b1;
        end
        default:
            ns[IDLE] = 1'b1;
    endcase
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        angle_range <= 0;
    else if(cs[IDLE])
        angle_range <= 0;
    else if(cs[WAIT1])
        angle_range <= START_ANGLE;
    else if(cs[CALC_NEXT_ANGLE])
        angle_range <= angle_range + 1199;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        valid_cnt <= 0;
    else if(cs[IDLE])
        valid_cnt <= 0;
    else if(cs[CALC_NEXT_ANGLE])
        valid_cnt <= valid_cnt + 1;
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
assign                  valid_angle = cs[CALC_NEXT_ANGLE];
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cycle_enable <= 0;
    else if(cs[WAIT1] & ns[WAIT2])
        cycle_enable <= 1;
    else if(cs[DELAY] & ns[IDLE])
        cycle_enable <= 0;
end

endmodule
