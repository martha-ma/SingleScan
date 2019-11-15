/*=============================================================================
# FileName    : distance_module.v
# Author      : author
# Email       : email@email.com
# Description :
        1. 将采集的25周期的回波信号，进行并转串处理。
        2. 对串行数据进行分析，计算回波的上升下降沿，的到回波时刻，回波脉冲宽度，及回波初步距离。
        3. 对不同反射率的目标进行距离标校。
        4. 对温度距离进行矫正。
        5. 进行一周期内前五次回波距离及脉冲宽度的统计。
# Version     : 1.0
# LastChange  : 2019-6-21 13:21:18
# ChangeLog   :
=============================================================================*/
module distance_module(
    input  wire                             clk,
    input  wire                             rst,
    input  wire                             tola_en,
    input  wire     [399:0]                 total_data,             //存储400个点
    input  wire     [7:0]                   NOISE_CNT,              //噪声信号宽度
    input  wire     [7:0]                   CORRECT_CNT_N,
    input  wire     [7:0]                   CORRECT_CNT_B,            //不同反射率目标距离矫正系数
    input  wire     [7:0]                   CORRECT_CNT_M,
    input  wire     [7:0]                   CORRECT_CNT_5,
    input  wire     [7:0]                   CORRECT_CNT_4,
    input  wire     [9:0]                   POINT_CNT1,
    input  wire     [9:0]                   POINT_CNT2,
    input  wire     [9:0]                   POINT_CNT3,
    input  wire     [9:0]                   POINT_CNT4,
    input  wire     [7:0]                   CHANGE_TH_2,
    input  wire     [7:0]                   POINT_TEM,
    input  wire     [7:0]                   CORRECT_TEM_1,
    input  wire     [7:0]                   CORRECT_TEM_2,
    input  wire     [7:0]                   CHANGE_TH_1,
    input  wire                             set_en,
    input  wire     [15:0]                  tem_count,
    input  wire     [15:0]                  dac_value,
    input  wire     [9:0]                   dac_max,
    input  wire     [9:0]                   dac_min,
    output wire                             target_valid,         //有最大距离值时标志信号
    output wire     [39:0]                  mult_pluse,
    output wire     [79:0]                  mult_distance
    
    );

    wire                                    data_en,time_en,ad_en,far_en,temp_en,da_en;
    wire                                    serial_data;
    wire            [11:0]                  time_pluse;
    wire            [11:0]                  time_pluse_t;
    wire            [11:0]                  time_pluse_a;
    wire            [17:0]                  mid_distance;
    wire            [9:0]                   single_cnt;
    wire            [15:0]                  ad_distance;
    wire            [15:0]                  ad_distance_p;
    wire            [15:0]                  ad_distance_t;
    wire            [7:0]                   tem_per;
    wire            [17:0]                  da_distance;
parallel_serial parallel_serialEx01(                                                  //并行数据转为串行数据输出
    .clk                        (    clk             ),
    .rst                        (    rst             ),
    .parallel_data              (    total_data      ),
    .tola_en                    (    tola_en         ),
    .single_cnt                 (    single_cnt      ),
    .data_en                    (    data_en         ),
    .serial_data                (    serial_data     )
    );


peak_div peak_divEx01(                                                               //根据上升沿下降沿寻找峰值点,以及灰尘警报
    .clk                        (    clk             ),
    .rst                        (    rst             ),
    .q                          (    serial_data     ),
    .data_en                    (    data_en         ),
    .NOISE_CNT                  (    NOISE_CNT       ),
    .time_en                    (    time_en         ),
    .mid_distance               (    mid_distance    ),
    .UPP_WITH                   (    CHANGE_TH_1     ),
    .time_pluse                 (    time_pluse      ),
    .far_en                     (    far_en          )
    );
adjust_distance adjust_distanceEx01(                                          //对不同反射率的目标进行距离标校
    .clk                        (   clk              ),
    .rst                        (   rst              ),
    .time_pluse                 (   time_pluse       ),
    .time_en                    (   time_en          ),
    .mid_distance               (   mid_distance     ),
    .CORRECT_CNT_M              (   CORRECT_CNT_M    ),
    .POINT_CNT1                 (   POINT_CNT1       ),
    .POINT_CNT2                 (   POINT_CNT2       ),
    .POINT_CNT3                 (   POINT_CNT3       ),
    .POINT_CNT4                 (   POINT_CNT4       ),
    .CORRECT_CNT_N              (   CORRECT_CNT_N    ),
    .CORRECT_CNT_B              (   CORRECT_CNT_B    ),
    .CORRECT_CNT_5              (   CORRECT_CNT_5    ),
    .CORRECT_CNT_4              (   CORRECT_CNT_4    ),
    .ad_en                      (   ad_en            ),
    .time_pluse_a               (   time_pluse_a     ),
    .ad_distance                (   ad_distance_p    )
   );

	
tem_adjust tem_adjustEx01(                                                //对温度距离进行矫正
    .clk                        (   clk              ),
    .rst                        (   rst              ),
    .ad_en                      (   ad_en            ),
    .ad_distance                (   ad_distance_p    ),
    .time_pluse_a               (   time_pluse_a     ), 
    .POINT_TEM                  (   POINT_TEM        ),
    .CORRECT_TEM_1              (   CORRECT_TEM_1    ),
    .CORRECT_TEM_2              (   CORRECT_TEM_2    ),
//    .tem_per                    (  tem_per          ),
    .tem_per                    (   tem_count        ),
    .temp_en                    (   temp_en          ),
    .time_pluse_t               (   time_pluse_t     ), 
    .tem_distance               (   ad_distance      )
	);
da_adjust da_adjustEx01(
    .clk                        (	clk              ),
    .rst                        (	rst              ),
    .dac_value                  (	dac_value        ),
    .dac_max                    (   dac_max          ),
    .dac_min                    (   dac_min          ),
    .temp_en                    (	temp_en          ),
    .ad_distance                (	ad_distance      ),
    .da_en                      (	da_en            ),
    .da_distance                (	da_distance      )
);

max_distance max_distanceEx01(                                                       //进行前五次回波距离及脉冲宽度的统计
    .clk                        (    clk             ),
    .rst                        (    rst             ),
//  .mid_distance               (    mid_distance    ),
    .ad_distance                (    da_distance     ),
    .time_pluse                 (    time_pluse_t    ),
    .data_en                    (    data_en         ),
    .far_en                     (    far_en          ),
    .ad_en                      (    da_en           ),
//	.ad_en                      (    ad_en           ),
    .single_cnt                 (    single_cnt      ),

    .target_valid               (    target_valid    ),
    .mult_pluse                 (    mult_pluse      ),
    .mult_distance              (    mult_distance   ) 
    );

endmodule
