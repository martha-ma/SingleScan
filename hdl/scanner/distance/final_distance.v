/*=============================================================================
# FileName    : final_diatance.v
# Author      : author
# Email       : email@email.com
# Description :
        1. 单一周期进行出具处理至少需要3.4us时间，为保证1us实时出测量结果，进行四次pingpong操作。
# Version     : 1.0
# LastChange  : 2019-6-21 13:21:18
# ChangeLog   :
=============================================================================*/
module final_diatance(                                                          //最终距离输出
    input  wire                                     clk,
    input  wire                                     rst,
    input  wire                                     tola_en,                //移位寄存器存满400个点后的使能信号
    input  wire     [399:0]                         total_data,
    input  wire     [7:0]                           NOISE_CNT,              //噪声信号宽度
    input  wire     [7:0]                           CORRECT_CNT_N,          //不同反射率目标距离矫正系数
    input  wire     [7:0]                           CORRECT_CNT_B,
    input  wire     [7:0]                           CORRECT_CNT_M,
    input  wire     [7:0]                           CORRECT_CNT_5,
    input  wire     [7:0]                           CORRECT_CNT_4,
    input  wire     [9:0]                           POINT_CNT1,
    input  wire     [9:0]                           POINT_CNT2,
    input  wire     [9:0]                           POINT_CNT3,
    input  wire     [9:0]                           POINT_CNT4,
    input  wire     [15:0]                          ABSOLUTE_CNT,
    input  wire     [7:0]                           POINT_TEM,        
    input  wire     [7:0]                           CORRECT_TEM_1,
    input  wire     [7:0]                           CORRECT_TEM_2,
    input  wire     [7:0]                           CHANGE_TH_1,
    input  wire     [7:0]                           CHANGE_TH_2,	 
    input  wire                                     set_en,           
    input  wire     [15:0]                          tem_count,        
    input  wire     [15:0]                          dac_value,
    input  wire     [9:0]                           dac_max,
    input  wire     [9:0]                           dac_min,
	 
    output wire                                     valid,               //有最大距离值时标志信号
    output wire     [11:0]                          time_pluse,             //输出脉冲宽度
    output wire     [17:0]                          distance

    );
//      reg             [17:0]                          distance;
        //分别给4个模块的回波值
//        reg             [399:0]                         total_data_1;
//        reg             [399:0]                         total_data_2;
//        reg             [399:0]                         total_data_3;
//        reg             [399:0]                         total_data_4;

        reg             [1:0]                           sel;                    //400个点输入选择依据
        reg             [1:0]                           state;                  //距离读取选择依据
        reg             [39:0]                          mult_pluse;
        reg             [79:0]                          mult_distance;

        //四个模块的输出距离值(保留三回波)
        wire            [39:0]                          mult_pluse_1;
        wire            [39:0]                          mult_pluse_2;
        wire            [39:0]                          mult_pluse_3;
        wire            [39:0]                          mult_pluse_4;
        wire            [79:0]                          mult_distance_1;
        wire            [79:0]                          mult_distance_2;
        wire            [79:0]                          mult_distance_3;
        wire            [79:0]                          mult_distance_4;



        //四个模块的距离输出的使能信号
        wire                                            valid_1/*synthesis keep*/;
        wire                                            valid_2/*synthesis keep*/;
        wire                                            valid_3/*synthesis keep*/;
        wire                                            valid_4/*synthesis keep*/;



        reg                                             tola_en_1,tola_en_2;
        reg                                             tola_en_3,tola_en_4;//输入数据开始处理信号
        

        wire                                            valid_m;

		  
localparam              IDLE        = 0;
localparam              START1      = 1; //开始ping-pong操作，第一模块分布
localparam              START2      = 2; //第二模块分布
localparam              START3      = 3; //第三模块分布
localparam              START4      = 4; //第四模块分布
localparam              OVER        = 5;
(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt, state_cnt_n;


always @(posedge clk or negedge rst)
begin
    if(~rst)
        cs <= 'd1;
    else
        cs <= ns;
end

/*
* 1. 等待tola_en启动状态机
* 2. 平均分配四模块计算数值，进行4次ping-pong操作
*/
always @(*)
begin
    ns = 'd0;
    case(1'b1)
        cs[IDLE]:
        begin
            if(tola_en)
                ns[START1] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[START1]:            //第一模块
        begin
            if(tola_en)
                ns[START2] = 1'b1;
            else
                ns[START1] = 1'b1;
        end
        cs[START2]:
        begin
            if(tola_en)         // 第二模块
                ns[START3] = 1'b1;
            else
                ns[START2] = 1'b1;
        end
        cs[START3]:             //第三模块
        begin
            if(tola_en)
                ns[START4] = 1'b1;
            else
                ns[START3] = 1'b1;
        end 
        cs[START4]:             //第四模块
        begin
            if(state_cnt == 12)
                ns[OVER] = 1'b1;
            else
                ns[START4] = 1'b1;
        end
        cs[OVER]:
        begin
            ns[OVER] = 1'b1;
        end
        default:
            ns[IDLE] = 1'b1;
    endcase
end


always @ (posedge clk or negedge rst)
begin
    if(~rst)
        state_cnt <= 0;
    else
        state_cnt <= state_cnt_n;
end

always @ (*)
begin
    if(~rst)
        state_cnt_n <= 0;
    else if (cs != ns)
        state_cnt_n <= 0;
    else
        state_cnt_n <= state_cnt + 1'b1;
end		  
		  
		  
always @ (posedge clk or negedge rst) //赋值接收使能信号
begin
    if(~rst)
	 begin
	    tola_en_1<=1'b0;
	    tola_en_2<=1'b0;
       tola_en_3<=1'b0;
	    tola_en_4<=1'b0;
	 end
	 else
	 begin
	    tola_en_1 <= (ns[START1] & cs[START1]);
		 tola_en_2 <= (ns[START2] & cs[START2]);
	    tola_en_3 <= (ns[START3] & cs[START3]);
	    tola_en_4 <= (ns[START4] & cs[START4]);
	 end
end

always @ (posedge clk or negedge rst)
begin
    if(~rst)
	 begin
	     mult_pluse <= 40'd0;
		  mult_distance<=80'd0;
	 end
	 else
	 begin
	    if(cs[START1] && valid_m)
		 begin
		    mult_pluse <= mult_pluse_2;
		    mult_distance <= mult_distance_2;
		 end
		 if(cs[START2])
		 begin
		    mult_pluse <= mult_pluse_3;
		    mult_distance <= mult_distance_3;
		 end
		 if(cs[START3])
		 begin
		    mult_pluse <= mult_pluse_4;
		    mult_distance <= mult_distance_4;
		 end
		 if(cs[START4])
		 begin
		    mult_pluse <= mult_pluse_1;
		    mult_distance <= mult_distance_1;
		 end
	 end
end

		    
		  

//always@(posedge clk or negedge rst)                                     //选择数
//begin
//    if(!rst)
//    begin
//        sel<=2'd0;
//    end
//    else
//    begin
//        if(tola_en)
//        begin
//            sel<=sel+1'b1;
//            if(sel>2'd3)
//            sel<=2'd0;
//        end
//    end
//end
//
//always@(posedge clk)                                                      //接收数据分模块处理
//begin
//    case(sel)
//        2'd0:
//            begin
//                if(tola_en_4)
//                begin
//                    total_data_4 <= total_data;
//                end
//                else if(valid_m)
//                begin
//                    mult_pluse <= mult_pluse_1;
//					mult_distance<=mult_distance_1;
//						  
//                end
//            end
//        2'd1:
//            begin
//                if(tola_en_1)
//                begin
//                    total_data_1 <= total_data;
//                end
//                else if(valid_m)
//                begin
//                    mult_pluse <= mult_pluse_2;
//                    mult_distance <= mult_distance_2;
//                end
//
//            end
//        2'd2:
//            begin
//                if(tola_en_2)
//                begin
//                    total_data_2 <= total_data;
//                end
//                else if(valid_m)
//                begin
//                    mult_pluse <= mult_pluse_3;
//                    mult_distance <= mult_distance_3;
//                end
//
//            end
//        2'd3:
//            begin
//                if(tola_en_3)
//                begin
//                    total_data_3 <= total_data;
//                end
//                else if(valid_m)
//                begin
//                    mult_pluse <= mult_pluse_4;
//                    mult_distance <= mult_distance_4;
//                end
//            end
//        default:;
//    endcase
//end
//always@(posedge clk or negedge rst)
//begin
//    if(!rst)
//    begin
//        tola_en_1<=1'b0;
//        tola_en_2<=1'b0;
//        tola_en_3<=1'b0;
//        tola_en_4<=1'b0;
//        state<=2'd0;
//    end
//    else
//    begin
//    case(state)
//    2'd0:
//        begin
//            if(tola_en)
//            begin
//                tola_en_1<=1'b1;
//                state<=state+1'b1;
//            end
//            else
//            begin
//                tola_en_1<=1'b0;
//                state<=2'd0;
//                tola_en_4<=1'b0;
//            end
//        end
//    2'd1:
//        begin
//            if(tola_en)
//            begin
//                tola_en_2<=1'b1;
//                state<=state+1'b1;
//            end
//            else
//            begin
//                tola_en_2<=1'b0;
//                tola_en_1<=1'b0;
//                state<=2'd1;
//            end
//        end
//    2'd2:
//        begin
//            if(tola_en)
//            begin
//                tola_en_3<=1'b1;
//                state<=state+1'b1;
//            end
//            else
//            begin
//                tola_en_3<=1'b0;
//                tola_en_2<=1'b0;
//                state<=2'd2;
//            end
//        end
//    2'd3:
//        begin
//            if(tola_en)
//            begin
//                tola_en_4<=1'b1;
//                state<=2'd0;
//            end
//            else
//            begin
//                tola_en_4<=1'b0;
//                tola_en_3<=1'b0;
//                state<=2'd3;
//            end
//        end
//    default:;
//    endcase
//    end
//end



assign valid_m=(valid_1 || valid_2 || valid_3 || valid_4);




distance_module distance_moduleEx01(
    .clk             (    clk               ),
    .rst             (    rst               ),
    .tola_en         (    tola_en_1         ),
    .total_data      (    total_data        ),
    .NOISE_CNT       (    NOISE_CNT         ),
    .CORRECT_CNT_B   (    CORRECT_CNT_B     ),
    .CORRECT_CNT_N   (    CORRECT_CNT_N     ),
    .CORRECT_CNT_M   (    CORRECT_CNT_M     ),
    .CORRECT_CNT_5   (    CORRECT_CNT_5     ),
    .CORRECT_CNT_4   (    CORRECT_CNT_4     ),
    .POINT_CNT1      (    POINT_CNT1        ),
    .POINT_CNT2      (    POINT_CNT2        ),
    .POINT_CNT3      (    POINT_CNT3        ),
    .POINT_CNT4      (    POINT_CNT4        ),
    .POINT_TEM       (    POINT_TEM         ),
    .CORRECT_TEM_1   (    CORRECT_TEM_1     ),
    .CORRECT_TEM_2   (    CORRECT_TEM_2     ),
    .CHANGE_TH_1     (    CHANGE_TH_1       ),
    .CHANGE_TH_2     (    CHANGE_TH_2       ),
    .set_en          (    set_en            ),
    .tem_count       (    tem_count         ),
    .dac_value       (    dac_value         ),
    .dac_max         (    dac_max           ),
    .dac_min         (    dac_min           ),
    .target_valid    (    valid_1           ),      //有距离值时标志信号
    .mult_pluse      (    mult_pluse_1      ),
    .mult_distance   (    mult_distance_1   )
    );
distance_module distance_moduleEx02(
    .clk             (    clk               ),
    .rst             (    rst               ),
    .tola_en         (    tola_en_2         ),
    .total_data      (    total_data        ),
    .NOISE_CNT       (    NOISE_CNT         ),
    .CORRECT_CNT_N   (    CORRECT_CNT_N     ),
    .CORRECT_CNT_B   (    CORRECT_CNT_B     ),
    .CORRECT_CNT_M   (    CORRECT_CNT_M     ),
    .CORRECT_CNT_5   (    CORRECT_CNT_5     ),
    .CORRECT_CNT_4   (    CORRECT_CNT_4     ),
    .POINT_CNT1      (    POINT_CNT1        ),
    .POINT_CNT2      (    POINT_CNT2        ),
    .POINT_CNT3      (    POINT_CNT3        ),
    .POINT_CNT4      (    POINT_CNT4        ),
    .POINT_TEM       (    POINT_TEM         ),
    .CORRECT_TEM_1   (    CORRECT_TEM_1     ),
    .CORRECT_TEM_2   (    CORRECT_TEM_2     ),
    .CHANGE_TH_1     (    CHANGE_TH_1       ),
    .CHANGE_TH_2     (    CHANGE_TH_2       ),
    .set_en          (    set_en            ),
    .tem_count       (    tem_count         ),
    .dac_max         (    dac_max           ),
    .dac_min         (    dac_min           ),    
    .dac_value       (    dac_value         ),
    .target_valid    (    valid_2           ),
    .mult_pluse      (    mult_pluse_2      ),
    .mult_distance   (    mult_distance_2   )
    );
distance_module distance_moduleEx03(
    .clk             (    clk               ),
    .rst             (    rst               ),
    .tola_en         (    tola_en_3         ),
    .total_data      (    total_data        ),
    .NOISE_CNT       (    NOISE_CNT         ),
    .CORRECT_CNT_N   (    CORRECT_CNT_N     ),
    .CORRECT_CNT_B   (    CORRECT_CNT_B     ),
    .CORRECT_CNT_M   (    CORRECT_CNT_M     ),
    .CORRECT_CNT_5   (    CORRECT_CNT_5     ),
    .CORRECT_CNT_4   (    CORRECT_CNT_4     ),
    .POINT_CNT1      (    POINT_CNT1        ),
    .POINT_CNT2      (    POINT_CNT2        ),
    .POINT_CNT3      (    POINT_CNT3        ),
    .POINT_CNT4      (    POINT_CNT4        ),
    .POINT_TEM       (    POINT_TEM         ),
    .CORRECT_TEM_1   (    CORRECT_TEM_1     ),
    .CORRECT_TEM_2   (    CORRECT_TEM_2     ),
    .CHANGE_TH_1     (    CHANGE_TH_1       ),
    .CHANGE_TH_2     (    CHANGE_TH_2       ),
    .set_en          (    set_en            ),
    .tem_count       (    tem_count         ),    
    .dac_value       (    dac_value         ),
    .dac_max         (    dac_max           ),
    .dac_min         (    dac_min           ),
    .target_valid    (    valid_3           ),
    .mult_pluse      (    mult_pluse_3      ),
    .mult_distance   (    mult_distance_3   )
    );
distance_module distance_moduleEx04(
    .clk             (    clk               ),
    .rst             (    rst               ),
    .tola_en         (    tola_en_4         ),
    .total_data      (    total_data        ),
    .NOISE_CNT       (    NOISE_CNT         ),
    .CORRECT_CNT_N   (    CORRECT_CNT_N     ),
    .CORRECT_CNT_B   (    CORRECT_CNT_B     ),
    .CORRECT_CNT_M   (    CORRECT_CNT_M     ),
    .CORRECT_CNT_5   (    CORRECT_CNT_5     ),
    .CORRECT_CNT_4   (    CORRECT_CNT_4     ),
    .POINT_CNT1      (    POINT_CNT1        ),
    .POINT_CNT2      (    POINT_CNT2        ),
    .POINT_CNT3      (    POINT_CNT3        ),
    .POINT_CNT4      (    POINT_CNT4        ),
    .POINT_TEM       (    POINT_TEM         ),
    .CORRECT_TEM_1   (    CORRECT_TEM_1     ),
    .CORRECT_TEM_2   (    CORRECT_TEM_2     ),
    .CHANGE_TH_1     (    CHANGE_TH_1       ),
    .CHANGE_TH_2     (    CHANGE_TH_2       ),
    .set_en          (    set_en            ),
    .tem_count       (    tem_count         ),
    .dac_max         (    dac_max           ),
    .dac_min         (    dac_min           ),    
    .dac_value       (    dac_value         ),
    .target_valid    (    valid_4           ),
    .mult_pluse      (    mult_pluse_4      ),
    .mult_distance   (    mult_distance_4   )
    );
	 
mult_div mult_divEx04(
    .clk            (     clk               ),
    .rst            (     rst               ),
    .mult_pluse     (     mult_pluse        ),
    .mult_distance  (     mult_distance     ),
    .valid_m        (     valid_m           ),
    .valid          (     valid             ),
    .time_pluse     (     time_pluse        ),
    .distance       (     distance          ) 
);	 
	 
	 
endmodule
