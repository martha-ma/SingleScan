/*=============================================================================
# FileName    :	send_data.v
# Author      :	author
# Email       :	email@email.com
# Description :	
# Version     :	1.0
# LastChange  :	2018-05-25 15:56:36
# ChangeLog   :	
=============================================================================*/
module send_data
(
    input                       clk,
    input   wire                rst_n,
    input   wire                send_en,
    output  wire                send_data
);

reg    [1:0]            send_en_r;
wire                    send_en_rise;
wire                    send_en_fall;

assign          send_en_rise = send_en_r[1:0] == 2'b01;
assign          send_en_fall = send_en_r[1:0] == 2'b10;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        send_en_r    <= 2'b00;
    else
        send_en_r    <= {send_en_r[0], send_en};
end


assign                  send_data = send_en_rise;
endmodule

