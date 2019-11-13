/*=============================================================================
# FileName    :	zero_revise.v
# Author      :	author
# Email       :	email@email.com
# Description :	
# Version     :	1.0
# LastChange  :	2019-06-21 08:38:25
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module zero_revise
(
    input                       clk,
    input                       rst_n,
    input        [15:00]        zero_value,
    input                       data_in_valid,
    input        [15:00]        data_in,

    output  reg                 data_out_valid,
    output  reg  [15:00]        data_out
);


always @ (posedge clk)
begin
    data_out_valid <= data_in_valid;
end

always @ (posedge clk)
begin
    data_out <= (data_in > zero_value) ? (data_in - zero_value) : 16'hFFFF;
end

//assign                  data_out_valid = data_in_valid;
//assign                  data_out = (data_in > zero_value) ? data_in - zero_value : 16'hFFFF;

endmodule
