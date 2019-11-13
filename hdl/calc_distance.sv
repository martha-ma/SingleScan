/*=============================================================================
# FileName    :	calc_distance.v
# Author      :	author
# Email       :	email@email.com
# Description :	
                1. 距离单位：mm
                2. 没有目标时，不输出target_valid信号
                3. 输出的距离值:目标距离-零位距离
# Version     :	1.0
# LastChange  :	2018-10-11 17:53:18
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module calc_distance
(
    input   logic                clk,
    input   logic                rst_n,
    /*port*/

    input   logic                send_en,    // 高速收发器发送有效数据的使能信号 1
    input   logic                zero_flag,
    input   logic [15:00]        rx_dataout,

    output  logic                alarm_dust,   // 灰尘太多时报警
    output  logic                target_valid, // 本次最大量程结束时，如果有目标距离，才能提供此信号
    output  logic [31:00]        target_pos    // 
);

initial
begin
    target_valid = 0;
    target_pos = 0;
    repeat(10000000)
    begin
        wait(send_en);
        repeat(10)
        begin
            @(posedge clk);
        end
        target_valid = 1;
        target_pos = $urandom_range(1000, 1500);
        @(posedge clk);
        target_valid = 0;
    end
end
endmodule
