/*=============================================================================
# FileName    :   adt7301_top.v
# Author      :   author
# Email       :   email@email.com
# Description :   以固定时间间隔输出采用温度值
# Version     :  1.0
# LastChange  :   2018-10-22 16:16:03
# ChangeLog   :   
=============================================================================*/

`timescale  1 ns/1 ps

module adt7301_top #
(
    //  时钟周期计数值
    parameter               CYCLE_TIME = 200_000_000 //1.5s以上读一次
//parameter               CYCLE_TIME = 20_000
)
(
    input   wire                clk,
    input   wire                rst_n,
    input   wire                adt7301_din,
//    input   wire [167:0]        distance_para,
    input   wire                read_flag,
    input   wire [15:0]         APD_HIGH_DEFAUT,
    input   wire [7:0]          FEEDBACK_TEM_1,
    input   wire [7:0]          FEEDBACK_TEM_2,
    input   wire [7:0]          APD_TEM_POINT,
    /*port*/
    output  wire                m_axis_tvalid,
    input   wire                m_axis_tready,
    output  wire [15:00]        tem_count,
    output  reg                 set_en,
    output  reg  [15:00]        da_count,

    /*port*/
    output  wire                adt7301_cs_n,
    output  wire                adt7301_sclk,
    output  wire                adt7301_dout
);

    wire                       read_temp_flag;
    wire                       tem_count_en;
    reg                        enable;
    reg                        set_en_up/*synthesis keep*/;
    wire                       set_en_h/*synthesis keep*/;
    wire                       flag;
    wire        [15:00]        da_count_h;
    reg         [9:0]          INITIAL_COUNT;
     
     
    reg         [31:00]        time_cnt;
    wire        [15:00]        m_axis_tdata;

    assign    flag=((APD_HIGH_DEFAUT[9:0]<=680)&&(APD_HIGH_DEFAUT[9:0]>=400))?1'b1:1'b0;
    

always @ (posedge clk or negedge rst_n)  //比较器值设计
begin
    if(~rst_n)
        set_en_up<=1'b0;
    else if(read_flag && APD_HIGH_DEFAUT[15])
        set_en_up<=1'b1;
    else
        set_en_up<=1'b0;

end


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        set_en<=1'b0;
    else
    begin
        if(set_en_up || set_en_h)
            set_en<=1'b1;
        else
            set_en<=1'b0;
    end
end

reg [15:00] tmp_data;

always @ (posedge clk)
    tmp_data <= {1'b1,3'd0,APD_HIGH_DEFAUT[9:0],2'd0};


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        da_count<=16'd0;
    else
    begin
        if(set_en_up)
            da_count<= tmp_data;
        else if(set_en_h)
            da_count<=da_count_h;
    end
end    
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        INITIAL_COUNT<=APD_HIGH_DEFAUT[9:0];
    else
    begin
        if((APD_HIGH_DEFAUT[15]==0)&& read_flag && flag)
            INITIAL_COUNT<=APD_HIGH_DEFAUT[9:0];
    end
end        
    
     
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        time_cnt <= 0;
    else if(time_cnt == CYCLE_TIME)
        time_cnt <= 0;
    else
        time_cnt <= time_cnt + 1'b1;
end

assign    read_temp_flag = (time_cnt == (CYCLE_TIME>>1)) ? 1'b1 : 1'b0;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        enable<=1'b0;
    else if((time_cnt>((CYCLE_TIME>>1)-100))&&(time_cnt<(CYCLE_TIME>>1)+100))
        enable <= 1'b1;
    else
        enable <= 1'b0;
end





adt7301_core adt7301_coreEx01
(
    .clk              (  clk                  ),
    .rst_n            (  rst_n                ),
    .data_in          (  adt7301_din          ),
    .read_temp_flag   (  read_temp_flag       ),
    .enable           (  enable               ),
    .m_axis_tvalid    (  m_axis_tvalid        ),
    .m_axis_tready    (  m_axis_tready        ),
    .m_axis_tdata     (  m_axis_tdata         ),
    .cs_n             (  adt7301_cs_n         ),
    .sclk             (  adt7301_sclk         ),
    .dout             (  adt7301_dout         )
);
cal_tem cal_temEX01(
    .clk              (   clk                 ),
    .rst              (   rst_n               ),
    .m_axis_tdata     (   m_axis_tdata        ),
    .m_axis_tvalid    (   m_axis_tvalid       ),
    .tem_count_en     (   tem_count_en        ),
    .tem_count        (   tem_count           )
);
high_v high_vEx01(
    .clk              (   clk                 ),
    .rst              (   rst_n               ),
    .m_axis_tvalid    (   tem_count_en        ),//tem_count_en
    .tem_count        (   tem_count           ),
    .INITIAL_COUNT    (   INITIAL_COUNT       ),
    .TEM_K            (   FEEDBACK_TEM_1      ),//低于25度
    .TEM_KH           (   FEEDBACK_TEM_2      ),//高于25度
    .POINT_TEM        (   APD_TEM_POINT       ),
    .set_en           (   set_en_h            ),          
    .da_count         (   da_count_h          )
);
endmodule
