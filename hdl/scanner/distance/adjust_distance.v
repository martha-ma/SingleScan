/*=============================================================================
# FileName    :	adjust_distance.v
# Author      :	author
# Email       :	email@email.com
# Description :	1.小于阈值1：距离=当前距离-k2*(阈值2-阈值1)-k1*(阈值1-x);
2.阈值1<x<阈值2：距离=当前距离-k2*(阈值2-x);
3.x>阈值2:距离=当前距离-k3*(x-阈值2)
# Version     :	1.0
# LastChange  :	2018-11-02 14:00:44
# ChangeLog   :	x扩大10倍，K缩小10倍
=============================================================================*/
module adjust_distance(                     	        //对不同反射率的目标进行距离标校
    input  wire    		        clk,
    input  wire                 rst,
    input  wire     [11:0]      time_pluse,
    input  wire                 time_en,
    input  wire     [17:0]      mid_distance,
    input  wire     [7:0]       CORRECT_CNT_N,//大于拐点2小于拐点3
    input  wire     [7:0]       CORRECT_CNT_B,  //大于拐点1小于拐点2          //不同反射率目标距离矫正系数
    input  wire     [7:0]       CORRECT_CNT_M,//小于拐点1
    input  wire     [7:0]       CORRECT_CNT_4,//大于拐点3小于拐点4
    input  wire     [7:0]       CORRECT_CNT_5,//大于拐点 4

    input  wire     [9:0]       POINT_CNT1,
    input  wire     [9:0]       POINT_CNT2,
    input  wire     [9:0]       POINT_CNT3,
    input  wire     [9:0]       POINT_CNT4,
    output reg                  ad_en,

    output reg      [11:0]      time_pluse_a,
    output reg      [15:0]      ad_distance 

);

reg             [9:0]      time_1; //  p<= POINT_CNT1
reg             [9:0]      time_21;//POINT_CNT2-POINT_CNT1
reg             [9:0]      time_2; //POINT_CNT1< p <= POINT_CNT2
reg             [9:0]      time_3; //POINT_CNT2< p <= POINT_CNT3
reg             [9:0]      time_32;//POINT_CNT3-POINT_CNT2
reg             [9:0]      time_4; //p > POINT_CNT3
reg             [9:0]      time_43;
reg             [9:0]      time_5;

reg             [2:0]      state;
wire            [17:0]     ad_distance_3;   //大于阈值2
wire            [17:0]     ad_distance_2/*synthesis keep*/;
wire            [17:0]     ad_distance_1;   //<阈值1
wire            [17:0]     ad_distance_4;   //小于阈值1的固定偏差
wire            [17:0]     ad_distance_21;
wire            [17:0]     ad_distance_32;
wire            [17:0]     ad_distance_43;
wire            [17:0]     ad_distance_5;

reg             [17:0]     ad_distance_m;
reg             [17:0]     ad_distance_m2;
reg             [17:0]     ad_distance_m3;
reg             [17:0]     ad_distance_m4;

reg             [11:0]     time_pluse_1;
reg             [11:0]     time_pluse_2;
reg             [11:0]     time_pluse_3;
wire            [11:0]     time_pluse_com/* synthesis keep */;

assign time_pluse_com = time_pluse<<2;

always@(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        ad_distance<=16'd0;
		ad_distance_m<=18'd0;
		ad_distance_m2<=18'd0;
		ad_distance_m3<=18'd0;
        state<=3'd0;
        ad_en<=1'b0;

        time_1<=10'd0;
        time_2<=10'd0;
        time_3<=10'd0;
        time_4<=10'd0;
        time_21<=10'd0;
        time_32<=10'd0;
        time_43<=10'd0;
        time_5<=10'd0;

        time_pluse_a<=12'd0;
        time_pluse_1<=12'd0;
        time_pluse_2<=12'd0;
        time_pluse_3<=12'd0;

    end
    else
    begin
        case(state)
            3'd0:
                begin
                    ad_en<=1'b0;
                    if(time_en)
                    begin
                        state<=state+1'b1;
                        time_pluse_1<=time_pluse_com;
                    end
                    else
                        state<=3'd0;
                end
            3'd1:
                begin
                    time_21<=POINT_CNT2-POINT_CNT1;
                    time_32<=POINT_CNT3-POINT_CNT2;
                    time_43<=POINT_CNT4-POINT_CNT3;
                    time_pluse_2<=time_pluse_1;
                    if(time_pluse_1<=POINT_CNT1)
                    begin
                        time_1<=POINT_CNT1-time_pluse_1;
                        state<=3'd2;
                    end
                    else if((POINT_CNT1<time_pluse_1)&&(time_pluse_1<=POINT_CNT2))
                    begin
                        time_2<=time_pluse_1-POINT_CNT1;
                        state<=3'd2;
                    end
                    else if((POINT_CNT2<time_pluse_1)&&(time_pluse_1<=POINT_CNT3))
                    begin
                        time_3<=time_pluse_1-POINT_CNT2;
                        state<=3'd2;
                    end
                    else if((POINT_CNT3<time_pluse_1)&&(time_pluse_1<=POINT_CNT4))
                    begin
                        time_4<=time_pluse_1-POINT_CNT3;
                        state<=3'd2;
                    end
                    else if(POINT_CNT4<time_pluse_1)
                    begin
                        time_5<=time_pluse_1-POINT_CNT4;
                        state<=3'd2;
                    end
                end
            3'd2:
                state<=3'd3;
				3'd3:
					begin
						ad_distance_m=ad_distance_21[17:4]+ad_distance_3[17:4];
						ad_distance_m2=ad_distance_21[17:4]+ad_distance_32[17:4];
						ad_distance_m3=ad_distance_5[17:4]+ad_distance_43[17:4];
						state<=3'd4;
					end
            3'd4:
                begin             
                    time_pluse_3<=time_pluse_2;
                    if(time_pluse_2<=POINT_CNT1)
                    begin
                        ad_distance<=mid_distance+ad_distance_1[17:4];
                        state<=3'd5;
                    end
                    else if((POINT_CNT1<time_pluse_2)&&(time_pluse_2<=POINT_CNT2))
                    begin
                        ad_distance<=mid_distance-ad_distance_2[17:4];
                        state<=3'd5;
                    end
                    else if((POINT_CNT2<time_pluse_2)&&(time_pluse_2<=POINT_CNT3))
                    begin
                        ad_distance<=mid_distance-ad_distance_m;                 //ad_distance_3[15:3]-ad_distance_21[15:3];
                        state<=3'd5;
                    end
                    else if((POINT_CNT3<time_pluse_2)&&(time_pluse_2<=POINT_CNT4))
                    begin
                        ad_distance<=mid_distance-(ad_distance_4[17:4]+ad_distance_m2);             //(ad_distance_21[15:3]+ad_distance_32[15:3]);
                        state<=3'd5;
                    end
                    else if(POINT_CNT4<time_pluse_2)
                    begin
                        ad_distance<=mid_distance-(ad_distance_m2+ad_distance_m3);             //((ad_distance_5[15:3]+ad_distance_21[15:3])+(ad_distance_32[15:3]+ad_distance_43[15:3]));
                        state<=3'd5;
                    end

                end
				
            3'd5:
                begin
                    ad_en<=1'b1;
                    time_pluse_a<={2'b0,time_pluse_3[11:2]};
                    state<=3'd0;
                    time_pluse_1<=12'd0;
                    time_pluse_2<=12'd0;
                    time_pluse_3<=12'd0;
						  
					ad_distance_m<=18'd0;
					ad_distance_m2<=18'd0;
					ad_distance_m3<=18'd0;

                end
            default:;
        endcase
    end
end


mul_p n1(
    .clock          ( clk               ),
    .dataa          ( time_2            ),		//	POINT_CNT1< p <= POINT_CNT2		
    .datab          ( CORRECT_CNT_B     ),
    .result         ( ad_distance_2     )
);

mul_p n2(
    .clock          (  clk              ),
    .dataa          (  time_32          ),		// POINT_CNT3-POINT_CNT2
    .datab          (  CORRECT_CNT_N    ),
    .result         (  ad_distance_32   )
);
mul_p n3(
    .clock          ( clk               ),
    .dataa          ( time_21           ),		//	POINT_CNT2-POINT_CNT1  
    .datab          ( CORRECT_CNT_B     ),
    .result         ( ad_distance_21     )
); 

mul_p n4(
    .clock          ( clk               ),
    .dataa          ( time_1            ),		//	 p<= POINT_CNT1  
    .datab          ( CORRECT_CNT_M     ),
    .result         ( ad_distance_1     )
);
mul_p n5(
    .clock          ( clk               ),
    .dataa          ( time_3            ),		//	 POINT_CNT2< p <= POINT_CNT3
    .datab          ( CORRECT_CNT_N     ),
    .result         ( ad_distance_3     )
);	
mul_p n6(
    .clock          ( clk               ),
    .dataa          ( time_4            ),		//	 p > POINT_CNT3
    .datab          ( CORRECT_CNT_4     ),
    .result         ( ad_distance_4     )
);
mul_p n7(
    .clock          ( clk               ),
    .dataa          ( time_5            ),		//	 p > POINT_CNT3
    .datab          ( CORRECT_CNT_5     ),
    .result         ( ad_distance_5     )
);
mul_p n8(
    .clock          ( clk               ),
    .dataa          ( time_43           ),		//	 p > POINT_CNT3
    .datab          ( CORRECT_CNT_4     ),
    .result         ( ad_distance_43    )
);	
endmodule

