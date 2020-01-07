/*=============================================================================
# FileName    :	compare_region.v
# Author      :	author
# Email       :	email@email.com
# Description :	
# Version     :	1.0
# LastChange  :	2019-01-02 14:21:26
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module compare_region
(
    input   wire                clk,
    input   wire                rst_n,

    input   wire [01:00]        hw_type,
    input   wire                upload_en,   // 不使能上传数据时, 如何保存

    input   wire                cycle_enable,
    input   wire                target_valid,
    input   wire [15:00]        target_pos,
    input   wire [15:00]        min_target_size,
    input   wire [09:00]        alarm_output_threshold,

    output  wire                region0_rden,
    output  wire [09:00]        region0_rdaddr,  // 内层
    input   wire [17:00]        region0_rddata,

    output  wire                region1_rden,
    output  wire [09:00]        region1_rdaddr,     // 中间层
    input   wire [17:00]        region1_rddata,

    output  wire                region2_rden,
    output  wire [09:00]        region2_rdaddr,     // 外层
    input   wire [17:00]        region2_rddata,
    
    output  reg  [02:00]        alarm_io
);
//localparam                                  alarm_output_threshold = 20;  
reg     [03:00]             alarm_io_r;
reg     [15:00]             rd_cnt;

reg     [1:0]               cycle_enable_r;
wire                        cycle_enable_rise;
wire                        cycle_enable_fall;


reg     [02:00]             region_flag;
// flag = 1 说明本圈数据不会产生报警信号

reg  [21:0]     sum_r0;
reg  [21:0]     sum_r1;
reg  [21:0]     sum_r2;
reg  [11:0]     sum_0;
reg  [11:0]     sum_1;
reg  [11:0]     sum_2;



reg  [15:0]     target_pos_s0;
reg  [15:0]     target_pos_r0;
wire [15:0]     range_des/* synthesis keep */;
wire [23:0]     range_des_um/* synthesis keep */;

reg  [15:0]     change_r0;
reg             flag_0/* synthesis keep */;
reg             flag_1;
reg             flag_2;
reg             judge_0/* synthesis keep */;
reg             judge_1;
reg             judge_2;

reg  [16:0]     min_target_size_f;
reg  [15:0]     min_target_size_r0;
reg  [15:0]     min_target_size_r1;
wire            min_target_size_flag;
reg  [9:0]      alarm_output_threshold_r0;
reg  [9:0]      alarm_output_threshold_r1;
reg  [9:0]      alarm_output_threshold_com;
wire            alarm_output_threshold_flag;




assign          cycle_enable_rise = cycle_enable_r[1:0] == 2'b01;
assign          cycle_enable_fall = cycle_enable_r[1:0] == 2'b10;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cycle_enable_r    <= 2'b00;
    else
        cycle_enable_r    <= {cycle_enable_r[0], cycle_enable};
end


always @ (posedge clk)
begin
    alarm_output_threshold_r0 <= alarm_output_threshold;
    alarm_output_threshold_r1 <= alarm_output_threshold_r0;
end

assign                  alarm_output_threshold_flag = (alarm_output_threshold_r0 != alarm_output_threshold_r1);
always@(posedge clk)
begin
	if(alarm_output_threshold>500)
	alarm_output_threshold_com<=10'd1;
	else if(alarm_output_threshold_flag) 
	alarm_output_threshold_com<=alarm_output_threshold;
	
end



localparam              IDLE    = 0;
localparam              READ    = 1;    // 开始去读存放在RAM里的区域数据, 读一个比较一个
localparam              DLY     = 2;
localparam              COMPARE = 3;
localparam              IS_END  = 4;
localparam              OVER    = 5;
(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[READ]: cs_STRING = "READ";
        cs[DLY]: cs_STRING = "DLY";
        cs[COMPARE]: cs_STRING = "COMPARE";
        cs[IS_END]: cs_STRING = "IS_END";
        cs[OVER]: cs_STRING = "OVER";
        default: cs_STRING = "XXXX";
    endcase
end
// synthesis translate_on

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cs <= 'd1;
    else
        cs <= ns;
end

always @(*)
begin
    ns = 'd0;
    case(1'b1)
        cs[IDLE]:
        begin
            if(cycle_enable_rise)
                ns[READ] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[READ]:
        begin
            ns[COMPARE] = 1'b1;
        end
        cs[COMPARE]:
        begin
            if(target_valid)
                ns[IS_END] = 1'b1;
            else
                ns[COMPARE] = 1'b1;
        end
        cs[IS_END]:
        begin
            if(rd_cnt == 811)
                ns[IDLE] = 1'b1;
            else
                ns[READ] = 1'b1;
        end
        default:
            ns[IDLE] = 1'b1;
    endcase
end


always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        state_cnt <= 0;
    else if (cs != ns)
        state_cnt <= 0;
    else
        state_cnt <= state_cnt + 1'b1;
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        rd_cnt <= 0;
    else if(cs[IDLE])
        rd_cnt <= 0;
    else if(target_valid)
        rd_cnt <= rd_cnt + 1'b1;
end


always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        target_pos_s0<=16'd0;
        target_pos_r0<=16'd0;
    end
    else if(cycle_enable)
    begin
        if(target_valid)
        begin
            target_pos_r0<=target_pos;
            target_pos_s0<=target_pos_r0;
				
        end
    end
    else
    begin
	    target_pos_s0<=16'd0;
		target_pos_r0<=16'd0;
    end
end

reg [7:0] cnt;

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cnt<=8'd0;
    else if(target_valid)
        cnt<=8'd0;
    else if(cnt>8'd40)
        cnt<=8'd41;
    else
        cnt<=cnt+1'b1;
end


always @ (posedge clk)
begin
    min_target_size_r0 <= min_target_size;
    min_target_size_r1 <= min_target_size_r0;
end
assign                  min_target_size_flag = (min_target_size_r0 != min_target_size_r1);
always @(posedge clk )
begin
    if(min_target_size_flag)
    min_target_size_f<=min_target_size*10;
end

//assign flag_0=((region0_rddata[15:00] != 16'hFFFF) & (target_pos_r0 <= region0_rddata))?1'b1:0;
//assign flag_1=((region1_rddata[15:00] != 16'hFFFF) & (target_pos_r0 <= region1_rddata))?1'b1:0;
//assign flag_2=((region2_rddata[15:00] != 16'hFFFF) & (target_pos_r0 <= region2_rddata))?1'b1:0;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
	 begin
	 flag_0<=0;
	 flag_1<=0;
	 flag_2<=0;
	 end
	 else
	 begin
	flag_0=((region0_rddata[15:00] != 16'hFFFF) & (target_pos_r0 <= region0_rddata))?1'b1:0;
	flag_1=((region1_rddata[15:00] != 16'hFFFF) & (target_pos_r0 <= region1_rddata))?1'b1:0;
   flag_2=((region2_rddata[15:00] != 16'hFFFF) & (target_pos_r0 <= region2_rddata))?1'b1:0; 
    end
end

always@(posedge clk)
begin
   if(target_pos_s0>target_pos_r0)
	begin
		change_r0<=target_pos_s0-target_pos_r0;
	end
	else 
	begin
		change_r0<=target_pos_r0-target_pos_s0;
	end
	
end


//assign judge_0=((sum_r0+sum_0)<min_target_size_f)?1'b1:1'b0;
//assign judge_1=((sum_r1+sum_1)<min_target_size_f)?1'b1:1'b0;
//assign judge_2=((sum_r2+sum_2)<min_target_size_f)?1'b1:1'b0;

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
	 begin
	 judge_0<=0;
	 judge_1<=0;
	 judge_2<=0;
	 end
	 else
	 begin
	judge_0<=((sum_r0+sum_0)<min_target_size_f)?1'b1:1'b0;
	judge_1<=((sum_r1+sum_1)<min_target_size_f)?1'b1:1'b0;
	judge_2<=((sum_r2+sum_2)<min_target_size_f)?1'b1:1'b0;
	end
end 

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        sum_r0<=22'd0;
    else if((!cycle_enable)||((change_r0>50)&&judge_0))
		sum_r0<=22'd0;

    else if(flag_0)
    begin
	    if(cnt==8'd30)
	        sum_r0<=sum_r0+range_des[15:0];
    end
end
//
//
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
		sum_r1<=22'd0;
    else if((!cycle_enable)||((change_r0>50)&&judge_1))
		sum_r1<=22'd0;

    else if(flag_1)
    begin
	    if(cnt==8'd30)
	        sum_r1<=sum_r1+range_des[15:0];
    end
end
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
		sum_r2<=22'd0;
    else if((!cycle_enable)||((change_r0>50)&&judge_2))
		sum_r2<=22'd0;
    else if(flag_2)
    begin
	    if(cnt==8'd30)
	        sum_r2<=sum_r2+range_des[15:0];
    end
end



always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
		sum_0<=12'd0;
    else if((sum_r0>0)&&(flag_0))
		sum_0<=range_des;
    else 
	    sum_0<=12'd0;
end
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
		sum_1<=12'd0;
    else if((sum_r1>0)&&(flag_1))
		sum_1<=range_des;
    else 
	    sum_1<=12'd0;
end
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
		sum_2<=12'd0;
    else if((sum_r2>0)&&(flag_2))
		sum_2<=range_des;
    else 
	    sum_2<=12'd0;
end





always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        region_flag <= 3'b111;
    else if(cycle_enable)
    begin
        if(cs[READ] & (rd_cnt == 0))   // 检测开始的时候重置
            region_flag <= 3'b111;
        else if((cnt==8'd36)&&(min_target_size>0))
        begin
            // 只要当前测量数据小于区域边界. 
            // 边界区域出现ff的点不做判断
            // 物体距离       检测区域
            if(~judge_0)
                region_flag[0] <= 0;

            if(~judge_1)
                region_flag[1] <= 0;

            if(~judge_2)
                region_flag[2] <= 0;
        end
		  else if((cnt==8'd36)&&(min_target_size==0))
		  begin
		      if (flag_0 )
                region_flag[0] <= 0;

            if(flag_1 )
                region_flag[1] <= 0;

            if(flag_2)
                region_flag[2] <= 0;
		  end
		 
    end
end

reg [9:0] alarm_cnt_r0;
reg [9:0] alarm_cnt_r1;
reg [9:0] alarm_cnt_r2;
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        alarm_cnt_r0<=10'd0;
    end
    else if(cycle_enable_fall)
    begin
        if(region_flag[0]==1)
            alarm_cnt_r0<=10'd0;
        else if(alarm_cnt_r0>10'd500)
            alarm_cnt_r0<=10'd500;
        else 
            alarm_cnt_r0<=alarm_cnt_r0+1'b1;
	 end
end
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        alarm_cnt_r1<=10'd0;
    end
    else if(cycle_enable_fall)
    begin
        if(region_flag[1]==1)
            alarm_cnt_r1<=10'd0;
        else if(alarm_cnt_r1>10'd500)
            alarm_cnt_r1<=10'd500;
        else 
            alarm_cnt_r1<=alarm_cnt_r1+1'b1;
    end
end
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        alarm_cnt_r2<=10'd0;
    end
    else if(cycle_enable_fall)
    begin
        if(region_flag[2]==1)
            alarm_cnt_r2<=10'd0;
        else if(alarm_cnt_r2>10'd500)
            alarm_cnt_r2<=10'd500;
        else 
            alarm_cnt_r2<=alarm_cnt_r2+1'b1;
    end
end
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        alarm_io_r <= 0;
    else if(target_valid &&(min_target_size >0))
    begin
        // 边界数据是ff的时候,不能判断
        if((~judge_0)&&(alarm_cnt_r0>=alarm_output_threshold_com))
            alarm_io_r[0] <= 1;

        if((~judge_1)&&(alarm_cnt_r1>=alarm_output_threshold_com))
            alarm_io_r[1] <= 1;

        if((~judge_2)&&(alarm_cnt_r2>=alarm_output_threshold_com))
            alarm_io_r[2] <= 1;
    end
	
    else if(target_valid && (min_target_size==0))
		  begin
		      if (flag_0 &&(alarm_cnt_r0>=alarm_output_threshold_com))
                alarm_io_r[0] <= 1;

            if(flag_1 && (alarm_cnt_r1>=alarm_output_threshold_com))
                alarm_io_r[1] <= 1;

            if(flag_2 &&(alarm_cnt_r2>=alarm_output_threshold_com))
                alarm_io_r[2] <= 1;
		  end
    else if(cycle_enable_fall)
    begin
        if(region_flag[0])   // 本圈数据正常, 清除之前的异常
            alarm_io_r[0] <= 0;
        if(region_flag[1])
            alarm_io_r[1] <= 0;
        if(region_flag[2])
            alarm_io_r[2] <= 0;
    end
end




/*
* 对于NPN型, 正常时要求外部IO低电平, 报警时高电平
* 结合外部三极管电路(B高电平时, C为低电平), 
*
* 对于PNP型, 正常时要求外部IO高电平, 报警时低电平
*/
always @ (posedge clk)
begin
    if(hw_type == 1)
        alarm_io <= ~alarm_io_r;
    else
        alarm_io <= alarm_io_r;
end


assign                  region0_rden = cs[READ];
assign                  region0_rdaddr = rd_cnt;

assign                  region1_rden = cs[READ];
assign                  region1_rdaddr = rd_cnt;

assign                  region2_rden = cs[READ];
assign                  region2_rdaddr = rd_cnt;


mul_com mul_comEx01(                                                        //测量距离
    .clock                  (   clk                     ),
    .dataa                  (   target_pos_r0           ),       //2*pi*r*0.333/360=0.0058 
    .result                 (   range_des_um            )
);

div_31bits n1(
	.clock			        (   clk				        ),
	.denom			        (	1000			        ),
	.numer			        (	range_des_um	        ),
	.quotient		        (  	range_des	            ),
	.remain			        ()
	);

endmodule
