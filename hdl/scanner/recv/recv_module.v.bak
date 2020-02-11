/*=============================================================================
# FileName    : recv_module.v
# Author      : author
# Email       : email@email.com
# Description :
        1. 进行回波采集，采集25个周期数据，最大30m.
        2. 25个周期全回波采集。
# Version     : 1.0
# LastChange  : 2019-6-21 13:21:18
# ChangeLog   :
=============================================================================*/
module recv_module(
    input wire                              clk,
    input wire                              rst,
    input wire                              send_en,
    input wire              [15:0]          rx_dataout,
    input wire              [7:0]           DELAY_CNT,
    output reg              [399:0]         total_data,               //总共400个点
    output reg                              tola_en/*synthesis keep*/ //移位寄存器存满400个点后的使能信号
);



//localparam                                  DELAY_CNT = 1;          //发送延时接收


reg                         [3:0]           state;
reg                         [3:0]           state_in;
reg                                         recv_en;
reg                         [7:0]           cnt;
reg                         [31:0]          cnt_1;
reg                         [399:0]         total_data_1;
reg                         [1:0]           tola_en_state;

always @ ( posedge clk or negedge rst )                     //在发送驱动信号后，会和光源真正发出脉冲有延时
begin
    if(!rst)
    begin
        cnt <= 8'd0;
        state <= 4'd0;
        recv_en <= 1'b0;
    end
    else
    begin
        case(state)
            4'd0:
            begin
                recv_en <= 1'b0;
                cnt <= 8'd0;
                if(send_en)                              //使能信号
                begin
                    state <= state + 1'b1;
                end
            end

            4'd1:
            begin
                if(cnt < DELAY_CNT)                      // IP高速发送核延时
                begin
                    cnt <= cnt + 1'b1;
                end
                else
                begin
                    state <= state + 1'b1;
                    recv_en <= 1'b1;
                end
            end
            4'd2:
                begin
                    recv_en <= 1'b0;
                    state <= 4'd0;
                end
            default:state <= 4'd0;
        endcase
    end


end


always@(posedge clk or negedge rst)                           //移位计数器
begin
    if(!rst)
    begin
        cnt_1<=32'd0;
    end
    else
    begin
        if(recv_en)
            cnt_1<=32'd0;
    else
        cnt_1<=cnt_1+1'b1;
    end
end

always@(posedge clk or negedge rst)                           //移位寄存器
begin
    if(!rst)
    begin
    total_data_1<=400'd0;
    total_data<=400'd0;
    end
    else
    begin
        if(cnt_1<25)
            total_data_1<={rx_dataout[15:0],total_data_1[399:16]};
        else
            total_data<=total_data_1;
    end
end
   

always@(posedge clk or negedge rst)                           //移位完成使能
begin
    if(!rst)
    begin
        tola_en<=1'b0;
    end
    else if(tola_en_state==2'd1)
    begin    
        if(cnt_1==25)
            tola_en<=1'b1;
        else
            tola_en<=1'b0;
    end
    else
        tola_en<=1'b0;
end
always@(posedge clk or negedge rst)                           //如果不出光时，不出使能信号时，判断当前发送使能信号
begin
    if(!rst)
        tola_en_state<=2'd0;
    else
    begin
        if(recv_en)
            tola_en_state<=2'd1;
        else if(send_en)
            tola_en_state<=2'd0;
    end
end
   
               

endmodule
