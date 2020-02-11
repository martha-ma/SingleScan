/*=============================================================================
# FileName    :	feed.v
# Author      :	author
# Email       :	email@email.com
# Description :	
                读数头每圈有44个周期信号
                每个周期信号时间：333.333/44 = 7.57ms
                每个周期信号时钟计数：7.57ms/8ns = 946996
                
                2r/s 每个间隙信号时钟计数：1420454
                3r/s 每个间隙信号时钟计数：946996
                4r/s 每个间隙信号时钟计数：710227
                5r/s 每个间隙信号时钟计数：568181
                6r/s 每个间隙信号时钟计数：473484
                7r/s 每个间隙信号时钟计数：405844
                8r/s 每个间隙信号时钟计数：355113
                9r/s 每个间隙信号时钟计数：315656
                10r/s 每个间隙信号时钟计数：284090
                15r/s 每个间隙信号时钟计数：189393

                2018.12.21  根据圈数计数器的平均值来调整电机的大概速度，不要求精确
                8r/s  每圈信号时钟计数：15625000
                9r/s  每圈信号时钟计数：13888888
                10r/s 每圈信号时钟计数：12500000
                12r/s 每圈信号时钟计数：10416666
                14r/s 每圈信号时钟计数： 8928571
                15r/s 每圈信号时钟计数： 8333333
                
                2018.12.24 更改速度反馈方式
                (Vi-Vo)*p + Vo

                TODO: 反馈系数需要上位机设置
# Version     :	1.0
# LastChange  :	2018-10-08 14:47:59
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module feed
(
    input   wire                clk,
    input   wire                rst_n,
    /*port*/

    input   wire [31:00]        motor_speed,    // 上位机预设的电机速度  N r/s

    input   wire                real_zero_flag,
    input   wire [31:00]        cycle_cnt,

    input   wire [07:00]        step_cnt,
    input   wire [31:00]        sub_cnt,
    input   wire                feed_valid,
    input   wire [31:00]        speed_cnt,
    
    output  reg  [15:00]        high_cnt,   // 高电平计数器
    output  reg  [15:00]        low_cnt     // 
);
localparam              UNIT_VALUE = 5;
localparam              SPEED_OFFSET_RANGE = 50000;
parameter               TIME_CNT = 6250000*8;  // 50ms
reg     [15:00]             duty_cnt;
reg     [31:00]             expect_speed;
reg     [31:00]             time_cnt;
wire                        timeout_flag /* synthesis keep */;
assign                      timeout_flag = (time_cnt == 0);
reg     [31:00]             diff_value;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        time_cnt <= TIME_CNT;
    else
    begin
        if(time_cnt == 0)
            time_cnt <= TIME_CNT;
        else
            time_cnt <= time_cnt - 1'b1;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        duty_cnt <= 460;
        expect_speed <= 8300000;
    end
    else
    begin
        case (motor_speed)
        16'd08: 
        begin
            duty_cnt <= 290;
            expect_speed <= 13800000;
        end
        16'd09: 
            begin
                duty_cnt <= 300;
                expect_speed <= 13800000;
            end
        16'd10: 
        begin
            duty_cnt <= 340;
            expect_speed <= 12500000;
        end
        16'd11: 
        begin
            duty_cnt <= 360;
            expect_speed <= 11000000;
        end
        16'd12: 
        begin
            duty_cnt <= 380;
            expect_speed <= 10400000;
        end
        16'd13: 
        begin
            duty_cnt <= 400;
            expect_speed <= 9600000;
        end
        16'd14: 
        begin
            duty_cnt <= 420;
            expect_speed <= 9000000;
        end
        16'd15: 
        begin
            duty_cnt <= 460;
            expect_speed <= 8300000;
        end
        default: 
        begin
            duty_cnt <= 460;
            expect_speed <= 8300000;
        end
        endcase
    end
end


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        high_cnt <= 400;
    end
    else if(timeout_flag)
    begin
        //high_cnt <= duty_cnt;
        
        /* 
         * 电机处于没有转动状态, 逐步增加高电平时间
         */
        if(cycle_cnt == 0)
        begin
            if(high_cnt <= 470)        // 最大占空比不超过40%
                high_cnt <= high_cnt + UNIT_VALUE;
        end
        /*
         * 计数值越大，速度越慢
         */
        else 
        begin
            if (cycle_cnt < expect_speed) // 电机需要减速
            begin
                if( ((expect_speed - cycle_cnt)>>14) > duty_cnt)  // 计算出来结果大于duty_cnt
                    high_cnt <= 100;
                else
                    high_cnt <= duty_cnt - ((expect_speed - cycle_cnt)>>14);   // 比例系数1/
            end
            /*
            * 如果实际间隙计数值 大于 设定值，说明转动速度小于设定值
            */
            else if(cycle_cnt > expect_speed )  // 电机需要加速
            begin
                if( ((cycle_cnt - expect_speed)>>14) > duty_cnt)  // 计算出来结果大于duty_cnt
                    high_cnt <= 550;  // 最大PWM宽度
                else
                    high_cnt <= duty_cnt + ((cycle_cnt - expect_speed)>>14);
            end
        end
    end
end

always @ (*)
begin
    low_cnt = 5000 - high_cnt;
end

endmodule
