module peak_div(          //根据上升沿下降沿寻找峰值点,以及灰尘报警。测量距离  单位：毫米  使用测距方程(t1*75+t2*75)/2
    input  wire                                     clk,
    input  wire                                     rst,
    input  wire                                     q,
    input  wire                                     data_en,
    input  wire                 [7:0]               NOISE_CNT,                  //噪声信号宽度
    input  wire                 [7:0]               UPP_WITH,
    output reg                                      time_en,
    output wire                                     far_en,                  //超远距离使能
    output reg                  [11:0]              time_pluse,
    output reg                  [11:0]              alarm_time,
    output reg                  [17:0]              mid_distance

);



//localparam                                        NOISE_CNT = 9;              // 过滤噪声的宽度
//localparam                                        DUST_CNT = 15;              //灰尘报警宽度



//reg                           [11:0]              time_pluse;
reg                             [11:0]              time_1;                     //上升沿时间点
reg                             [11:0]              time_2;                     //下降沿时间点
reg                             [11:0]              time_reg_1;  
reg                             [11:0]              time_reg_2;                 //时间中间寄存器

//reg                           [11:0]              alarm_time;                 //判断灰尘遮挡时回波脉冲宽度

reg                             [11:0]              cnt;
reg                                                 time_en_1;
reg                                                 time_en_2;

wire                            [31:0]              tar_dis_1;                  //t1*75
wire                            [31:0]              tar_dis_2;                  //t2*75

reg                                                 amp_reg_mid;                //下降沿使能信号
reg                                                 amp_reg_h;

reg                             [7:0]               state;
reg                                                 far_en_1;
reg                                                 far_en_m;
reg                             [1:0]               time_en_r;
wire                                                time_en_rise;
//reg                           [11:0]              time_pluse_1;

assign      time_en_rise=time_en_r[1:0]==2'b10;
always@(posedge clk or negedge rst)                             
begin
    if (!rst)
    begin
        time_en_r<=2'b00;
    end
    else
        time_en_r<={time_en_r[0],time_en_1};
end

always@(posedge clk or negedge rst)
begin
    if (!rst)
    begin
        cnt<=12'd0;
    end
    else
    begin
        if(data_en)
        begin
            cnt<=cnt+1'b1;
        end
        else
        begin
            cnt<=12'd0;
        end
    end
end


always@(posedge clk or negedge rst)                             //判断上升下降沿
begin
    if (!rst)
    begin   
        time_reg_1<=12'd0;
        time_reg_2 <= 12'd0;
        amp_reg_h<=1'b0;
    end
    else 
    begin
        if (data_en)
        begin
            amp_reg_h<=q;
            if(amp_reg_h<q)                         //上升沿
                time_reg_1 <= cnt;
            else if(amp_reg_h>q)                    //下降沿
                time_reg_2 <= cnt;
        end     
        else
        begin
            amp_reg_h<=1'b0;
            time_reg_1<=1'b0;
            time_reg_2 <= 1'b0;
        end
    end
end
always@(posedge clk or negedge rst)                             //下降沿使能信号
begin
    if (!rst)
        begin
            amp_reg_mid=1'b0;
        end
    else
        begin
            if(amp_reg_h>q)  
                amp_reg_mid<=1'b1;
            else
                amp_reg_mid<=1'b0;
        end
end
always@(posedge clk or negedge rst)                             //读取上升下降沿时间点
begin
    if (!rst)
    begin
        alarm_time<=12'd0;
        time_1<=12'd0;
        time_2<=12'd0;
        time_en_1<=1'b0;
    end
    else
    begin
        if(data_en)
        begin
			  if(amp_reg_mid)
			  begin
					alarm_time<=time_reg_2-time_reg_1;
					time_1<=time_reg_1;
					time_2<=time_reg_2;
					time_en_1<=1'b1;
			  end
			  else
					time_en_1<=1'b0;
        end
        else
        begin
            alarm_time<=12'd0;
            time_1<=12'd0;
            time_2<=12'd0;
        end
    end
end     



//wire [9:0] mult_cnt;
//assign mult_cnt=CHANGE_TH_1+CHANGE_TH_1;

always@(posedge clk or negedge rst)                             //判断噪声
begin
    if (!rst)
    begin
        time_en_2<=1'b0;
        time_pluse<=12'd0;
        far_en_1<=1'b0;
        far_en_m<=1'b0;
    end
    else
    begin 
        if(data_en)
        begin
            far_en_m<=far_en_1;
            if((alarm_time > NOISE_CNT)&&(alarm_time < UPP_WITH))    //150ns之内才参与计算
            begin
                if(time_en_rise)
                begin
                    far_en_1<=1'b1;
                    time_en_2<=1'b1;
//                    time_pluse_1<=alarm_time;
                    time_pluse<=alarm_time;
                end
                else 
                    time_en_2<=1'b0;
            end
            else
            begin
                time_en_2<=1'b0;
            end
        end
        else
        begin
            far_en_1<=1'b0;
//            time_pluse<=12'd0;
        end
    end
end


assign  far_en=((!far_en_m) && (!far_en_1))?1'b1:1'b0;          //无距离使能
always@(posedge clk or negedge rst)
begin
    if (!rst)
        time_en<=1'b0;
    else
    begin
      if(data_en)
      begin
         if(time_en_2)
         time_en<=1'b1;
         else
         time_en<=1'b0;
      end
    end
end


always@(posedge clk or negedge rst)                             //距离
begin
    if (!rst)
    begin
        mid_distance<=18'd0;
    end
    else
    begin
        if(data_en)
        begin
//            if((alarm_time>NOISE_CNT)&&(time_pluse<=time_pluse_1)&&(alarm_time>=time_pluse))  //取最大脉冲宽度
            if((alarm_time > NOISE_CNT)&&(alarm_time < UPP_WITH))
                mid_distance <= (tar_dis_2[18:0]+tar_dis_1[18:0])>>1;
        end
        else
            mid_distance <= 18'd0;
    end
end



   
   

    
    
    
    

mul_z mul_zEx01(  
    .clock                  ( clk                       ),              //测量距离  单位：毫米  使用测距方程(t1*75+t2*75)/2
    .dataa                  ( time_1                    ),                              
    .datab                  ( 20'd75                    ),
    .result                 ( tar_dis_1                 )
);      
mul_z mul_zEx02(                                                        //测量距离
    .clock                  ( clk                       ),
    .dataa                  ( time_2                    ),                              
    .datab                  ( 20'd75                    ),
    .result                 ( tar_dis_2                 )
);

endmodule



