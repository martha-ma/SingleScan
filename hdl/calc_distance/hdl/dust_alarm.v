/*=============================================================================
# FileName    :	dust_alarm.v
# Author      :	author
# Email       :	email@email.com
# Description :	
# Version     :	1.0
# LastChange  :	2019-06-20 18:56:52
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module dust_alarm
(
    input                       clk,
    input                       rst_n,
    input        [07:00]        dust_alarm_threshold,

    input                       zero_flag,
    input                       data_in_valid,
    input        [15:00]        data_in,

    output  reg                 data_out_valid,
    output  reg  [15:00]        data_out,

    output  reg  [09:00]        dust_cnt
);

reg     [09:00]             dust_cnt_r0;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        dust_cnt_r0 <= 0;
    else if(zero_flag)
        dust_cnt_r0 <= 0;
    else if(data_in_valid)
    begin
        //if(data_in <= 8950)
        if(data_in <= dust_alarm_threshold)
            dust_cnt_r0 <= dust_cnt_r0 + 1'b1;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        dust_cnt <= 0;
    else if(zero_flag)
        dust_cnt <= dust_cnt_r0;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_out <= 0;
    else if(data_in_valid)
    begin
        if(data_in <= dust_alarm_threshold)
            data_out <= 16'hFFFF;
        else
            data_out <= data_in;
    end
end

always @ (posedge clk)
begin
    data_out_valid <= data_in_valid;
end

endmodule
