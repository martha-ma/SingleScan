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
    input   wire [07:00]        min_target_size,

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

reg     [03:00]             alarm_io_r;
reg     [15:00]             rd_cnt;

reg     [1:0]               cycle_enable_r;
wire                        cycle_enable_rise;
wire                        cycle_enable_fall;

assign          cycle_enable_rise = cycle_enable_r[1:0] == 2'b01;
assign          cycle_enable_fall = cycle_enable_r[1:0] == 2'b10;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cycle_enable_r    <= 2'b00;
    else
        cycle_enable_r    <= {cycle_enable_r[0], cycle_enable};
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

reg     [02:00]             region_flag;
// flag = 1 说明本圈数据不会产生报警信号

reg  [16:0]     sum_r0;
reg  [16:0]     sum_r1;
reg  [16:0]     sum_r2;
reg  [7:0]     sum_0;
reg  [7:0]     sum_1;
reg  [7:0]     sum_2;



reg  [15:0]     target_pos_s0;
reg  [15:0]     target_pos_r0;
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

reg [4:0] cnt;

always@(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cnt<=5'd0;
    else if(target_valid)
        cnt<=5'd0;
    else if(cnt>5'd20)
        cnt<=5'd21;
    else
        cnt<=cnt+1'b1;
end

wire [15:0]  range_des/* synthesis keep */;
wire [31:0]  range_des_um/* synthesis keep */;

reg [15:0]  change_r0;
reg [15:0]  change_r1;
reg [15:0]  change_r2;
wire        flag_0;
wire        flag_1;
wire        flag_2;

assign flag_0=((region0_rddata[15:00] != 16'hFFFF) & (target_pos <= region0_rddata))?1'b1:0;
assign flag_1=((region1_rddata[15:00] != 16'hFFFF) & (target_pos <= region1_rddata))?1'b1:0;
assign flag_2=((region2_rddata[15:00] != 16'hFFFF) & (target_pos <= region2_rddata))?1'b1:0;

always@(posedge clk)
begin
	if(flag_0)
	begin
		if(target_pos>target_pos_s0)
		change_r0<=target_pos-target_pos_s0;
		else
		change_r0<=target_pos_s0-target_pos;
	end
	if(flag_1)
	begin
		if(target_pos>target_pos_s0)
		change_r1<=target_pos-target_pos_s0;
		else
		change_r1<=target_pos_s0-target_pos;
	end
	if(flag_2)
	begin
		if(target_pos>target_pos_s0)
		change_r2<=target_pos-target_pos_s0;
		else
		change_r2<=target_pos_s0-target_pos;
	end
end




//assign sum_0=((sum_r0>0)&(region0_rddata[15:00] != 16'hFFFF) & (target_pos <= region0_rddata))?range_des:0;  //(range_des<<1)多加一点
//assign sum_1=((sum_r1>0)&(region1_rddata[15:00] != 16'hFFFF) & (target_pos <= region1_rddata))?range_des:0;  //(range_des<<1)
//assign sum_2=((sum_r2>0)&(region2_rddata[15:00] != 16'hFFFF) & (target_pos <= region2_rddata))?range_des:0;  //(range_des<<1)

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        sum_r0<=17'd0;
    else if(cycle_enable_fall)
		sum_r0<=17'd0;
	else if((change_r0>50)&&((sum_r0+sum_0)<min_target_size))
	    sum_r0<=17'd0;
	else if(flag_0)//((region0_rddata[15:00] != 16'hFFFF) & (target_pos <= region0_rddata))
	begin
	    if((cnt==5'd18)&&(min_target_size<=180)&&(min_target_size>0))
	        sum_r0<=sum_r0+range_des_um[25:10];
		else if((cnt==5'd18)&&(min_target_size>180))
		     sum_r0<=sum_r0+range_des[15:0];
	end
end
//
//
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
		sum_r1<=17'd0;
	else if(cycle_enable_fall)
		sum_r1<=17'd0;
	else if((change_r1>50)&&((sum_r1+sum_1)<min_target_size))
	    sum_r1<=17'd0;
	else if(flag_1)//((region1_rddata[15:00] != 16'hFFFF) & (target_pos <= region1_rddata))
	begin
	    if((cnt==5'd18)&&(min_target_size<=180)&&(min_target_size>0))
	        sum_r1<=sum_r1+range_des_um[25:10];
		else if((cnt==5'd18)&&(min_target_size>180))
		     sum_r1<=sum_r1+range_des[15:0];
	end
end
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
		sum_r2<=17'd0;
	else if(cycle_enable_fall)
		sum_r2<=17'd0;
	else if((change_r2>50)&&((sum_r2+sum_2)<min_target_size))
	    sum_r2<=17'd0;
	else if(flag_2)//((region2_rddata[15:00] != 16'hFFFF) & (target_pos <= region2_rddata))
	begin
	    if((cnt==5'd18)&&(min_target_size<=180)&&(min_target_size>0))
	        sum_r2<=sum_r2+range_des_um[25:10];
		 else if((cnt==5'd18)&&(min_target_size>180))
		     sum_r2<=sum_r2+range_des[15:0];
	 end
end
//
//assign sum_0=0;//((sum_r0>0)&(region0_rddata[15:00] != 16'hFFFF) & (target_pos <= region0_rddata))?range_des:0;  //(range_des<<1)多加一点
//assign sum_1=0;//((sum_r1>0)&(region1_rddata[15:00] != 16'hFFFF) & (target_pos <= region1_rddata))?range_des:0;  //(range_des<<1)
//assign sum_2=0;//((sum_r2>0)&(region2_rddata[15:00] != 16'hFFFF) & (target_pos <= region2_rddata))?range_des:0;  //(range_des<<1)
//
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
		sum_0<=8'd0;
	else if((sum_r0>0)&&(flag_0))//(region0_rddata[15:00] != 16'hFFFF) &&(target_pos <= region0_rddata))
		sum_0<=range_des;
	else 
	    sum_0<=8'd0;
end
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
		sum_1<=8'd0;
	else if((sum_r0>0)&&(flag_1))//(region0_rddata[15:00] != 16'hFFFF) &&(target_pos <= region0_rddata))
		sum_1<=range_des;
	else 
	    sum_1<=8'd0;
end
always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
		sum_2<=8'd0;
	else if((sum_r0>0)&&(flag_2))//(region0_rddata[15:00] != 16'hFFFF) &&(target_pos <= region0_rddata))
		sum_2<=range_des;
	else 
	    sum_2<=8'd0;
end


always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        region_flag <= 3'b111;
    else if(cycle_enable)
    begin
        if(cs[READ] & (rd_cnt == 0))   // 检测开始的时候重置
            region_flag <= 3'b111;
        else if((cnt==5'd19)&&(min_target_size>180))
        begin
            // 只要当前测量数据小于区域边界. 
            // 边界区域出现ff的点不做判断
            // 物体距离       检测区域
            if ((sum_r0+sum_0) > min_target_size)
                region_flag[0] <= 0;

            if((sum_r1+sum_1) > min_target_size)
                region_flag[1] <= 0;

            if((sum_r2+sum_2)> min_target_size)
                region_flag[2] <= 0;
        end
		else if((cnt==5'd19)&&(min_target_size<=180)&&(min_target_size>0))
        begin
            // 只要当前测量数据小于区域边界. 
            // 边界区域出现ff的点不做判断
            // 物体距离       检测区域
            if ((sum_r0+sum_0) > (min_target_size << 3))
                region_flag[0] <= 0;

            if((sum_r1+sum_1) > (min_target_size <<3))
                region_flag[1] <= 0;

            if((sum_r2+sum_2)> (min_target_size <<3))
                region_flag[2] <= 0;
        end
		else if((cnt==5'd19)&&(min_target_size==0))
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




always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        alarm_io_r <= 0;
    else if(target_valid && (min_target_size > 0))
    begin
        // 边界数据是ff的时候,不能判断
        if((sum_r0+sum_0) > min_target_size)
            alarm_io_r[0] <= 1;

        if((sum_r1+sum_1) > min_target_size)
            alarm_io_r[1] <= 1;

        if((sum_r2+sum_2) > min_target_size)
            alarm_io_r[2] <= 1;
    end
	else if(target_valid && (min_target_size<=180)&&(min_target_size>0))
    begin
        // 边界数据是ff的时候,不能判断
        if((sum_r0+sum_0) > (min_target_size<<3))
            alarm_io_r[0] <= 1;

        if((sum_r1+sum_1) > (min_target_size<<3))
            alarm_io_r[1] <= 1;

        if((sum_r2+sum_2) > (min_target_size<<3))
            alarm_io_r[2] <= 1;
    end
	else if(target_valid && (min_target_size==0))
		begin
		    if (flag_0 )
                alarm_io_r[0] <= 1;

            if(flag_1)
                alarm_io_r[1] <= 1;

            if(flag_2)
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

mul_z mul_zEx01(                                                        //测量距离
    .clock                  (   clk                     ),
    .dataa                  (   12'd58                  ),       //2*pi*r*0.333/360=0.0058                       
    .datab                  (   {4'd0,target_pos}       ),
    .result                 (   range_des_um            )
);

div_31bits n1(
	.clock			        (   clk				        ),
	.denom			        (	10000			        ),
	.numer			        (	range_des_um	        ),
	.quotient		        (  	range_des	            ),
	.remain			        ()
	);

endmodule
