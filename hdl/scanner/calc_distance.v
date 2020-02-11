/*=============================================================================
# FileName    : calc_distance.v
# Author      : author
# Email       : email@email.com
# Description :
        1. 距离单位：mm
        2. 进行距离计算机多回波距离及对应脉冲宽度输出。
        3. 输出的距离值:目标距离-零位距离
# Version     : 1.0
# LastChange  : 2018-10-11 17:53:18
# ChangeLog   :
=============================================================================*/

`timescale  1 ns/1 ps

module calc_distance
(
    input   wire                         clk,
    input   wire                         rst_n,
    /*port*/

    input   wire                         send_en,                //高速收发器发送有效数据的使能信号
    input   wire         [15:00]         rx_dataout,
	 input   wire                         laser_enable,
    /*
    * [7:0]                             NOISE_CNT             4    //初步噪声过滤脉冲宽度下限值
    * [15:8]                            WINDOW_CNT            50  //最小显示距离范围
    * [23:16]                           POINT_TEM             25   //温度矫正距离拐点
    * [31:24]                           CORRECT_TEM_2         ?    //温度矫正距离系数2
    * [39:32]                           CORRECT_TEM_1         4   //温度矫正距离系数1
    * [47:40]                           APD_TEM_POINT         25   //APD高压温度设置拐点
    * [55:48]                           FEEDBACK_TEM_2        38   //APD高压温度反馈系数2
    * [63:56]                           FEEDBACK_TEM_1        38   //APD高压温度反馈系数1
    * [79:64]                           APD_HIGH_DEFAUT       580   //APD高压默认值设置 
    * [87:80]                           CHANGE_TH_2           100  //噪点偏差阈值2 
    * [95:88]                           CHANGE_TH_1           150  //噪点偏差阈值1 
    * [103:96]                          POINT_CNT2            40   //灰度拐点设置2 
    * [111:104]                         POINT_CNT1            17   //灰度拐点设置1 POINT_CNT1 通信协议中拐点1
    * [119:112]                         CORRECT_CNT_N         37   //灰度距离矫正系数k3
    * [127:120]                         CORRECT_CNT_M         6   //灰度距离校正系数k2
    * [135:128]                         CORRECT_CNT_B         33   //灰度距离校正系数k1 
    * [151:136]                         ABSOLUTE_CNT          0  //测距零位修正 
    * [159:152]                         DELAY_CNT             8  //收发器延时 

    */ 
    //   input   wire         [167:00]        distance_para,
            
    input   wire         [15:0]          tem_count,   
	 
    input   wire                         set_en,           
    input   wire         [15:0]          dac_value_adjust,
    input   wire         [7:0]           DELAY_CNT, 
    input   wire         [15:0]          ABSOLUTE_CNT, 	
    input   wire         [7:0]           CORRECT_CNT_B,
    input   wire         [7:0]           CORRECT_CNT_M,
    input   wire         [7:0]           CORRECT_CNT_N,
    input   wire         [7:0]           CORRECT_CNT_5,
    input   wire         [9:0]           POINT_CNT1,   
    input   wire         [9:0]           POINT_CNT2,
    input   wire         [9:0]           POINT_CNT3,
    input   wire         [9:0]           POINT_CNT4,
    input   wire         [7:0]           CHANGE_TH_1,  
    input   wire         [7:0]           CHANGE_TH_2,
    input   wire         [7:0]           CORRECT_CNT_4,  
    input   wire         [7:0]           CORRECT_TEM_1,
    input   wire         [7:0]           CORRECT_TEM_2,
    input   wire         [7:0]           POINT_TEM,    
    input   wire         [7:0]           WINDOW_CNT, 
    input   wire         [7:0]           NOISE_CNT,      
    input   wire         [9:0]           dac_max,
    input   wire         [9:0]           dac_min,
    output  wire         [11:00]         target_time_pluse,
    output  wire                         target_valid,           // 本次最大量程结束时，如果有目标距离，才能提供此信号
    output  wire         [17:00]         target_pos              // 最大测量距离（mm）
);
 

    wire                                tola_en;
    wire                [399:0]         total_data;             //200ns,400点
	 
	 	 
recv_module recv_moduleEx01(                                    //接收数据模块

    .clk             (    clk                   ),
    .rst             (    rst_n                 ),
	 .laser_enable    (    laser_enable          ),
    .DELAY_CNT       (    DELAY_CNT             ),
    .send_en         (    send_en               ),
    .rx_dataout      (    rx_dataout            ),
    .total_data      (    total_data            ),
    .tola_en         (    tola_en               )
    );


final_diatance final_diatanceEx01(                       //计算1us一次原始距离值
    .clk             (    clk                   ),
    .rst             (    rst_n                 ),
    .tola_en         (    tola_en               ),
    .total_data      (    total_data            ),
    .dac_value       (    dac_value_adjust      ),
    .ABSOLUTE_CNT    (    ABSOLUTE_CNT          ),
    .CORRECT_CNT_B   (    CORRECT_CNT_B         ),
    .CORRECT_CNT_M   (    CORRECT_CNT_M         ),
    .CORRECT_CNT_N   (    CORRECT_CNT_N         ),
    .CORRECT_CNT_5   (    CORRECT_CNT_5         ),
    .CORRECT_CNT_4   (    CORRECT_CNT_4         ),
    .POINT_CNT1      (    POINT_CNT1            ),
    .POINT_CNT2      (    POINT_CNT2            ),
    .POINT_CNT3      (    POINT_CNT3            ),
    .POINT_CNT4      (    POINT_CNT4            ),
    .CORRECT_TEM_1   (    CORRECT_TEM_1         ),
    .CORRECT_TEM_2   (    CORRECT_TEM_2         ),
    .CHANGE_TH_1     (    CHANGE_TH_1           ),       //当两台机器对照是最大脉冲宽度上限
    .POINT_TEM       (    POINT_TEM             ),
    .NOISE_CNT       (    NOISE_CNT             ),
    .set_en          (    set_en                ),
    .dac_max         (    dac_max               ),
    .dac_min         (    dac_min               ),
    .CHANGE_TH_2     (    CHANGE_TH_2           ),
    .tem_count       (    tem_count             ),
    .valid           (    target_valid          ),      //产生距离标志信号
    .time_pluse      (    target_time_pluse     ),      //输出脉冲宽度
    .distance        (    target_pos            )       //输出距离值
    );

endmodule

