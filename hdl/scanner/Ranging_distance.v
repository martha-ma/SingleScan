/*=============================================================================
# FileName    : Ranging_distance.v
# Author      : author
# Email       : email@email.com
# Description :
        1. 距离测量顶层文件
        2. 将回波信号采集，进行距离测量，周期1us。
        3. 对测距值进行灰度矫正，温度距离矫正，以及多回波采取输出。
        4. 对光源调制DA的控制。
        5. 对高压随温度变化的DA控制。
        6. 对温度传感器芯片的控制。
# Version     : 1.0
# LastChange  : 2019-6-21 13:21:18
# ChangeLog   :
=============================================================================*/
module Ranging_distance(
	input   wire                         clk,
	input   wire                         rst_n,
	input   wire                         send_en,                //高速收发器发送有效数据的使能信号
   input   wire         [15:00]         rx_dataout,
	input   wire         [89:00]         da_cycle_para,
	input   wire         [207:00]        distance_para,
	input   wire                         adt7301_din,
	input   wire                         m_axis_tready,
	input   wire                         dac_set_flag,
	input   wire                         laser_enable,
   output  wire                         target_valid,           // 本次最大量程结束时，如果有目标距离，才能提供此信号
   output  wire         [17:00]         target_pos,
	output  wire         [11:00]         target_time_pluse,

	output  wire         [31:00]         sys_temp,
	output  wire                         adt7301_cs_n,
   output  wire                         adt7301_sclk,
   output  wire                         adt7301_dout,
	output  wire                         ad5302_ldac_n,
   output  wire                         ad5302_sync_n,
   output  wire                         ad5302_sclk,
   output  wire                         ad5302_dout,
	output  wire                         HEN,
	
	output  wire                         ad5302_ldac_n_LD, 
	output  wire                         ad5302_sync_n_LD, 
	output  wire                         ad5302_sclk_LD,   
	output  wire                         ad5302_dout_LD   
	
);

   wire                                set_en;
   wire                [15:0]          da_count;
   wire                [15:0]          dac_value;


   wire                [7:0]           DELAY_CNT;
   wire                [15:0]          ABSOLUTE_CNT;
   wire                [7:0]           CORRECT_CNT_M;
   wire                [7:0]           CORRECT_CNT_B;
   wire                [7:0]           CORRECT_CNT_N;
   wire                [7:0]           CORRECT_CNT_4;
	wire                [7:0]           CORRECT_CNT_5;
   wire                [9:0]           POINT_CNT1;
   wire                [9:0]           POINT_CNT2;
	wire                [9:0]           POINT_CNT3;
	wire                [9:0]           POINT_CNT4;
   wire                [7:0]           CHANGE_TH_1;
   wire                [7:0]           CHANGE_TH_2;
   wire                [15:0]          APD_HIGH_DEFAUT;
   wire                [7:0]           FEEDBACK_TEM_1;
   wire                [7:0]           FEEDBACK_TEM_2;
   wire                [7:0]           APD_TEM_POINT;
   wire                [7:0]           CORRECT_TEM_1;
   wire                [7:0]           CORRECT_TEM_2;
   wire                [7:0]           POINT_TEM;
   wire                [7:0]           WINDOW_CNT;
   wire                [7:0]           NOISE_CNT;
   wire                [7:0]           dust_alarm_threshold;
	wire                [9:0]           dac_max;
	wire                [9:0]           dac_min;
assign {
         DELAY_CNT,
         ABSOLUTE_CNT,
         CORRECT_CNT_M,
         CORRECT_CNT_B,
         CORRECT_CNT_N,
			CORRECT_CNT_4,
			CORRECT_CNT_5,
         POINT_CNT1,
         POINT_CNT2,
			POINT_CNT3,
			POINT_CNT4,
         CHANGE_TH_1,
         CHANGE_TH_2,
         APD_HIGH_DEFAUT,
         FEEDBACK_TEM_1,
         FEEDBACK_TEM_2,
         APD_TEM_POINT,
         CORRECT_TEM_1,
         CORRECT_TEM_2,
         POINT_TEM,
         WINDOW_CNT,
         NOISE_CNT,
         dust_alarm_threshold
        }=distance_para;


	  
		  
		  
calc_distance calc_distanceEx01                                 //距离测量，多回波输出
(
   .clk                  (    clk                         ),
   .rst_n                (    rst_n                       ),
   .send_en              (    send_en                     ),
	.dac_value_adjust     (    dac_value                   ),
   .rx_dataout           (    rx_dataout                  ),
	.laser_enable         (    laser_enable                ),
	.DELAY_CNT            (    DELAY_CNT                   ),
	.ABSOLUTE_CNT         (    ABSOLUTE_CNT                ),
	.CORRECT_CNT_B        (    CORRECT_CNT_B               ),
	.CORRECT_CNT_M        (    CORRECT_CNT_M               ),
	.CORRECT_CNT_N        (    CORRECT_CNT_N               ),
	.CORRECT_CNT_5        (    CORRECT_CNT_5               ),
	.POINT_CNT1           (    POINT_CNT1                  ),
	.POINT_CNT2           (    POINT_CNT2                  ),
	.POINT_CNT3           (    POINT_CNT3                  ),
	.POINT_CNT4           (    POINT_CNT4                  ),
	.CHANGE_TH_1          (    CHANGE_TH_1                 ),
	.CORRECT_CNT_4        (    CORRECT_CNT_4               ),
	.CORRECT_TEM_1        (    CORRECT_TEM_1               ),
	.CORRECT_TEM_2        (    CORRECT_TEM_2               ),
	.POINT_TEM            (    POINT_TEM                   ),
	.WINDOW_CNT           (    dust_alarm_threshold        ),
	.NOISE_CNT            (    NOISE_CNT                   ),
	.dac_max              (    dac_max                     ),
	.dac_min              (    dac_min                     ), 
	 
	.CHANGE_TH_2          (    CHANGE_TH_2                 ),
	.set_en               (    set_en                      ),
   .tem_count            (    sys_temp                    ),
	.target_time_pluse    (    target_time_pluse           ),
   .target_valid         (    target_valid                ),
   .target_pos           (    target_pos                  )
);
adt7301_top #                                                  //温度传感器控制
(
   .CYCLE_TIME              (    200_000_000       )
)
adt7301_topEx01(
   .clk                     (    clk                    ),
   .rst_n                   (    rst_n                  ),
   .m_axis_tready           (    1'b1                   ),
   .tem_count               (    sys_temp               ),
   .set_en                  (    set_en                 ),
   .da_count                (    da_count               ),
//   .distance_para           (    distance_para          ),
	.APD_HIGH_DEFAUT         (    APD_HIGH_DEFAUT        ),
	.FEEDBACK_TEM_1          (    FEEDBACK_TEM_1         ),
	.FEEDBACK_TEM_2          (    FEEDBACK_TEM_2         ),
	.APD_TEM_POINT           (    APD_TEM_POINT          ),
   .read_flag               (    dac_set_flag           ),
   .adt7301_din             (    adt7301_din            ),
   .adt7301_cs_n            (    adt7301_cs_n           ),
   .adt7301_sclk            (    adt7301_sclk           ),
   .adt7301_dout            (    adt7301_dout           )

);
ad5328_top ad5328_topEx01                                       //高压DA设置控制
(
   .clk                     (   clk                     ),
   .rst_n                   (   rst_n                   ),

   .dac_set                 (   set_en                  ),//set_en
   .dac_value               (   da_count                ),   // da_count    550          //{1'b0,3'd0,10'd500,2'd0}{1'b1,3'd0,10'd70,2'd0}  //1 高压，最大值1.9v，最大值600.默认值560   2 比较器，参考值1.2v, 70.
	
   .HEN                     (   HEN                     ),
   .ldac_n                  (   ad5302_ldac_n           ),
   .sync_n                  (   ad5302_sync_n           ),
   .sclk                    (   ad5302_sclk             ),
   .dout                    (   ad5302_dout             )
);

wire             dac_set;
compa_value compa_valueEx01(                                  //光源循环调制设置值
   .clk                    (    clk                     ),
   .rst                    (    rst_n                   ),
	.da_cycle_para          (    da_cycle_para           ),
	.laser_enable           (    laser_enable            ),
	.CHANGE_TH_2            (    155                     ),
   .dac_value              (    dac_value               ),
	.dac_max                (    dac_max                 ),
	.dac_min                (    dac_min                 ),
   .dac_set                (    dac_set                 )
);
ad5328_top ad5328_topEx02                                    //光源调制DA控制
(
   .clk                    (   clk                      ),
   .rst_n                  (   rst_n                    ),

   .dac_set                (   dac_set                  ),//set_en
   .dac_value              (   dac_value      			  ),   // da_count    550          //{1'b0,3'd0,10'd500,2'd0}{1'b1,3'd0,10'd70,2'd0}  //0 高压，最大值1.9v，最大值600.默认值560   1 比较器，参考值1.2v, 70.
    
	 
   .ldac_n                 (   ad5302_ldac_n_LD         ),
   .sync_n                 (   ad5302_sync_n_LD         ),
   .sclk                   (   ad5302_sclk_LD           ),
   .dout                   (   ad5302_dout_LD           )
);

endmodule
