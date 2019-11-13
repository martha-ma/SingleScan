module max_distance( 
        input wire                              clk,
        input wire                              rst,
        input wire              [15:0]          ad_distance,                        //不同反射率目标矫正距离
        input wire              [7:0]           time_pluse,
        input wire                              data_en,
        input wire                              far_en,
        input wire                              ad_en,
        input wire              [9:0]           single_cnt,
        output reg                              target_valid,
        output reg              [39:0]          mult_pluse,
        output reg              [79:0]          mult_distance
        );

        
		
		reg                     [15:0]          vaild;	
		wire       								data_en_rise;                           //查找数据使能上升沿
		reg  	                [1:0]           data_en_r;
		
assign     data_en_rise=data_en_r[1:0]==2'b01;

always@(posedge clk or negedge rst)
begin
	if(!rst)
		data_en_r<=2'd0;
	else
		data_en_r<={data_en_r[0],data_en};
end		
		
reg [2:0]	mult_cnt;	
		
always@(posedge clk or negedge rst) 
begin
	if(!rst)
	begin
		mult_distance<=80'd0;
		mult_pluse<=40'd0;
		mult_cnt<=3'd0;
	end
	else if(data_en)
	begin
		if(mult_cnt<3'd5)
		begin	
			if(ad_en)
			begin
				mult_distance <= {mult_distance[63:0],ad_distance};
				mult_pluse <= {mult_pluse[31:0],time_pluse};
				mult_cnt <= mult_cnt+1'b1;
			end
			else if(data_en_rise)
			begin
				mult_distance<=80'd0;
				mult_pluse<=40'd0;
			end
		end
		else
		mult_cnt<=3'd5;
	end
	else
		mult_cnt<=3'd0;		
	
end

always@(posedge clk or negedge rst)                                                  
begin
	if (!rst)
	begin
		vaild <=16'd0;
	end
	else
	begin
		if(data_en)
			vaild <=16'd0;
		else
		begin
		if(vaild<=16'hefff)
			vaild<=vaild+1'b1;
		else
			vaild<=16'hefff;
		end
			
	end
end

	
		
always@(posedge clk or negedge rst)                                                  
begin
	if (!rst)
	begin
		target_valid <= 1'b0;
	end
	else
	begin
		if(vaild==16'd3)
			target_valid <= 1'b1;
		else
			target_valid <= 1'b0;
		
    end
end
	
		
endmodule		
		
		
	

//wire       data_en_rise;                           //查找数据使能上升沿
//reg  [1:0] data_en_r;
//assign     data_en_rise=data_en_r[1:0]==2'b01;
//always@(posedge clk or negedge rst)
//begin
//	if(!rst)
//	data_en_r<=2'd0;
//	else
//	data_en_r<={data_en_r[0],data_en};
//end
//
//
//always@(posedge clk or negedge rst) 
//begin
//	if(!rst)
//		tar_distance<=18'd0;
//	else
//	begin
//		if(data_en)
//		begin
//			if(ad_en)
//				tar_distance<=ad_distance;
//			else if(data_en_rise)
//				tar_distance<=18'd0;
//		end
//		
//	end
//end

//
//assign tar_distance_l0=(tar_distance>0)?(tar_distance-zero_value):18'd0;
//assign distance_m_l0=(distance_q>0)?(distance_q-zero_value):18'd0;
//
//
//always@(posedge clk or negedge rst) 
//begin
//	if(!rst)
//	begin
//		tar_time_pluse<=12'd0;
//		tar_time_pluse_1<=12'd0;
//	end
//	else
//	begin
//		if(data_en)
//		begin 
//			if(ad_en)
//			begin
//				tar_time_pluse<=time_pluse;
//				tar_time_pluse_1<=tar_time_pluse;
//			end
//			else if(data_en_rise)
//			begin
//				tar_time_pluse<=12'd0;
//				tar_time_pluse_1<=12'd0;
//			end
//		end
//	end
//end
//
//
//
//always@(posedge clk or negedge rst)   //保存最强三回波
//begin
//	if(!rst)
//	begin
//		distance_q<=18'd0;
//		distance_2m<=18'd0;
//		distance_3m<=18'd0;
//	end
//	else
//	begin
//		if(data_en_rise)
//		begin
//			distance_q<=18'd0;
//			distance_2m<=18'd0;
//			distance_3m<=18'd0;	
//		end
//		else
//		begin
//			if((com_value_1<=com_value_2)&&(distance_q != tar_distance))
//			begin
//				distance_q<=tar_distance;
//				distance_2m<=distance_q;
//				distance_3m<=distance_2m;
//			end
////			else if ((com_value_1 > com_value_2)&&(distance_q != distance_m))
////			begin
////				distance_q<=distance_m;
////				distance_2<=tar_distance;
////				distance_3<=distance_2;
////			end
//		end
//		
//	end
//end
//
//
//            
//    
//always@(posedge clk or negedge rst)                                                  
//begin
//    if (!rst)
//    begin
//        max_distance <=18'd0;
//		  distance_2<=18'd0;
//		 distance_3<=18'd0;
//		  
//    end
//    else
//    begin
//      if(!data_en)
//      begin
//         if(far_en && (single_cnt<10'd481))
//			begin
//				max_distance<=18'h3_ffff;
//				distance_2<=18'h3_ffff;
//				distance_3<=18'h3_ffff;
//			end
////			
////         else if(single_cnt==10'd481)
////			begin
////				max_distance<=18'd0;
////				distance_2<=18'd0;
////				distance_3<=18'd0;
////				
////			end
//         else
//			begin
////       distance<=tar_distance;
//				max_distance<=distance_q;
//				distance_2<=distance_2m;
//				distance_3<=distance_3m;
//				
//			end
//      end
//    end   
//end
//
//	
//
//always@(posedge clk or negedge rst)                                                  
//begin
//	if (!rst)
//	begin
//		vaild <=16'd0;
//	end
//	else
//	begin
//		if(data_en)
//			vaild <=16'd0;
//		else
//		begin
//		if(vaild<=16'hefff)
//			vaild<=vaild+1'b1;
//		else
//			vaild<=16'hefff;
//		end
//			
//	end
//end
//always@(posedge clk or negedge rst)                                                  
//begin
//	if (!rst)
//	begin
//		target_valid <= 1'b0;
//	end
//	else
//	begin
//		if(vaild==16'd3)
//			target_valid <= 1'b1;
//		else
//			target_valid <= 1'b0;
//		
//    end
//end
//
//
//mul_z mul_zEx01(                                                        //测量距离脉宽乘积 
//    .clock                  ( clk                       ),
//    .dataa                  ( tar_time_pluse            ),                              
//    .datab                  ( {2'd0,tar_distance_l0}    ),
//    .result                 ( com_value_2               )
//);
//mul_z mul_zEx02(                                                        //测量距离脉宽乘积
//    .clock                  ( clk                       ),
//    .dataa                  ( tar_time_pluse_1          ),                              
//    .datab                  ( {2'd0,distance_m_l0}      ),
//    .result                 ( com_value_1               )
//);                        
    

