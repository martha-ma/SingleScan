/*=============================================================================
# FileName    :	test_data.v
# Author      :	author
# Email       :	email@email.com
# Description :	
# Version     :	1.0
# LastChange  :	2018-12-14 17:18:53
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module test_data
(
    input   wire                clk,
    input   wire                rst_n,
    input   wire                enable,

    output  reg  [31:00]        data
);


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data <= 10000;
    else if(data < 15000)
    begin
        if(enable)
            data <= data + 1'b1;
            //data <= 12000;
    end
    else
        data <= 10000;
end
endmodule
