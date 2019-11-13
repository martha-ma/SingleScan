///*=============================================================================
//# FileName    :       send_data.v
//# Author      :       author
//# Email       :       email@email.com
//# Description :   每隔10us发送一次数据。每次发送16bit数据
//# Version     :       1.0
//# LastChange  :       2018-05-25 15:56:36
//# ChangeLog   :
//=============================================================================*/
module send_test
(
    input                                       clk,
    input                                       rst_n,
    input                                       laser_enable,
    input       wire                    send_en,
    output         wire    send_data  //通过I/O口输出

);
reg  [15:0] cnt;


always@(posedge clk or negedge rst_n)   //将发送数据通过I/O口输出，以适应搭建结构的TTL
begin
    if(!rst_n)
    begin
        cnt<=16'd0;
    end
    else
    begin
        if(send_en)
        begin
            cnt<=16'd0;
        end

        else
            cnt<= cnt + 1'b1;
    end
end

assign send_data = (cnt <3) ? 1 : 0;

endmodule
