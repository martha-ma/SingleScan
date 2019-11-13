/*=============================================================================
# FileName    :	generate_send_enable.v
# Author      :	author
# Email       :	email@email.com
# Description :	nios置位enable信号后，输出周期（3.33us）的信号，altgx根据此信号同步发送和接收数据
# Version     :	1.0
# LastChange  :	2018-05-28 16:33:33
# ChangeLog   :	
=============================================================================*/
`timescale  1 ns/1 ps

module generate_pulse
(
    input   wire                clk,
    input   wire                rst,
    input   wire                enable,

    output  reg                 cycle_pulse
);

// 3.333us / 8ns = 416.625
localparam              CYCLE_CNT = 416;

reg     [07:00]             cnt;

always @ (posedge clk or negedge rst)
begin
    if(~rst)
        cnt <= 0;
    else if(enable)
    begin
        if(cnt >= CYCLE_CNT)
            cnt <= 0;
        else
            cnt <= cnt + 1'b1;
    end
    else
        cnt <= 0;
end

always @ (posedge clk or negedge rst)
begin
    if(~rst)
        cycle_pulse <= 0;
    else if(cnt == CYCLE_CNT)
        cycle_pulse <= 1;
    else
        cycle_pulse <= 0;
end

endmodule
