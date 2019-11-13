/*=============================================================================
# FileName    :	change_output.v
# Author      :	author
# Email       :	email@email.com
# Description :	
# Version     :	1.0
# LastChange  :	2019-06-12 15:36:19
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module change_output
(
    input                       clk,
    input                       rst_n,

    input                       change_flag,
    input                       data_in0,
    input                       data_in1,
    input                       data_in2,
    input                       data_in3,
    input                       data_in4,

    output  reg                 data_out
);

reg     [07:00]             cnt;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cnt <= 0;
    else if(change_flag)
    begin
        if(cnt >= 4)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end
end

always @(*)
begin
    case (cnt)
        0: data_out <= data_in0;
        1: data_out <= data_in1;
        2: data_out <= data_in2;
        3: data_out <= data_in3;
        4: data_out <= data_in4;
        default: data_out <= data_in0;
    endcase
end
endmodule
