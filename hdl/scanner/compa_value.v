/*=============================================================================
# FileName    : compa_value.v
# Author      : author
# Email       : email@email.com
# Description :
        1. 进行光源DA调制控制。
        2. 产生9段循环设置DA值。控制光源比较器输入值。（现为8位DA）
# Version     : 1.0
# LastChange  : 2019-6-21 13:21:18
# ChangeLog   :
=============================================================================*/
module compa_value(
   input  wire                clk,
   input  wire                rst,
   input  wire [89:00]        da_cycle_para,
   output reg  [15:0]         dac_value,
	input  wire [7:00]         CHANGE_TH_2,
	input  wire                laser_enable,
	output wire [9:0]          dac_max,
	output wire [9:0]          dac_min,
   output reg                 dac_set
);

wire                        cycle_set_flag;
reg     [89:00]             da_cycle_para_r0;
reg     [89:00]             da_cycle_para_r1;
wire       						 b_set_flag_fall/* synthesis keep */;                           //查找数据使能上升沿
reg  	  [1:0]               b_set_flag_r;
wire                        b_set_flag/* synthesis keep */;	
reg     [7:0]               da_bvalue1;
reg     [7:0]               da_bvalue2;		  
		  
always @ (posedge clk)
begin
   da_bvalue1 <= CHANGE_TH_2;
   da_bvalue2 <= da_bvalue1;
end


assign     b_set_flag = (da_bvalue1 != da_bvalue2);

assign     b_set_flag_fall=b_set_flag_r[1:0]==2'b01;

always@(posedge clk or negedge rst)
begin
	if(!rst)
		b_set_flag_r<=2'd0;
	else
		b_set_flag_r<={b_set_flag_r[0],b_set_flag};
end
	
always @ (posedge clk)
begin
   da_cycle_para_r0 <= da_cycle_para;
   da_cycle_para_r1 <= da_cycle_para_r0;
end

assign                  cycle_set_flag = (da_cycle_para_r0 != da_cycle_para_r1);

localparam              CYC_CNT=813;//1000;//813;//6us
//reg            [89:0]   dac_reg  ;//248 :800mv 304;980mv 360:1.16v 416:1.34v  472:1.52v   528:1.7v
// Prevents Quartus Prime from removing or optimizing a fanout free register.
// Apply the attribute to the variable declaration for an object that infers
// a register.

(* noprune *)  reg            [89:0]   dac_reg;


//reg            [69:0]   dac_reg;
reg            [31:0]   cnt;
reg            [9:0]    state;
wire                    dac_set_1;
wire                    dac_set_fall;
wire                    dac_set_rise/* synthesis keep */;
reg            [1:0]    dac_set_r;

wire           [9:0]    da_cycle_para9 /* synthesis keep */;
wire           [9:0]    da_cycle_para8 /* synthesis keep */;
wire           [9:0]    da_cycle_para7 /* synthesis keep */;
wire           [9:0]    da_cycle_para6 /* synthesis keep */;
wire           [9:0]    da_cycle_para5 /* synthesis keep */;
wire           [9:0]    da_cycle_para4 /* synthesis keep */;
wire           [9:0]    da_cycle_para3 /* synthesis keep */;
wire           [9:0]    da_cycle_para2 /* synthesis keep */;
wire           [9:0]    da_cycle_para1 /* synthesis keep */;
reg            [15:0]   b_cnt;

assign      dac_set_fall=dac_set_r[1:0]==2'b10;
assign      dac_set_rise=dac_set_r[1:0]==2'b01;

assign      dac_set_1=(cnt==CYC_CNT-1)?1'b1:1'b0;

assign      {da_cycle_para9, da_cycle_para8, da_cycle_para7, da_cycle_para6, da_cycle_para5, da_cycle_para4, da_cycle_para3, da_cycle_para2, da_cycle_para1}=da_cycle_para;


assign      dac_max=da_cycle_para5;
assign      dac_min=da_cycle_para9;



always@(posedge clk or negedge rst)                             
begin
   if (!rst)
   begin
      dac_set_r<=2'b00;
   end
   else
      dac_set_r<={dac_set_r[0],dac_set_1};
end
always@(posedge clk or negedge rst)
begin
   if(!rst)
      cnt<=16'd0;
   else if(cnt==CYC_CNT-1)
      cnt<=16'd0;
   else
      cnt<=cnt+1'b1;
end 
always@(posedge clk or negedge rst)
begin
	if(!rst)
		b_cnt<=16'd0;
	else if(b_cnt>=16'd1000)
	   b_cnt<=16'd1001;
	else 
		b_cnt<=b_cnt+1'b1;
end

always@(posedge clk or negedge rst)
begin
   if(!rst)
//   dac_reg<= {10'd23,10'd46,10'd69,10'd93,10'd81,10'd58,10'd35};//300--1.2
//	dac_reg<= {10'd31,10'd42,10'd54,10'd65,10'd77,10'd71,10'd60,10'd48,10'd37};//10'd132};400-1v
//	dac_reg<= {10'd116,10'd121,10'd143,10'd164,10'd185,10'd174,10'd153,10'd132,10'd111};//10'd132};1.3-2.4 xiaohuo 
//	dac_reg<= {10'd100,10'd110,10'd120,10'd130,10'd140,10'd135,10'd125,10'd115,10'd105};//10'd132};1.5-2.6 xiaohuo 
	dac_reg<= {10'd123,10'd143,10'd162,10'd181,10'd200,10'd191,10'd172,10'd152,10'd133};//等比例上升
//dac_reg<= {10'd200,10'd191,10'd456,10'd527,10'd589,10'd651,10'd620,10'd558,10'd496};10bits

   else if(cycle_set_flag)
      dac_reg <={da_cycle_para9,da_cycle_para8,da_cycle_para7,da_cycle_para6,da_cycle_para5,da_cycle_para4,da_cycle_para3,da_cycle_para2,da_cycle_para1};
   else if(cnt==CYC_CNT-1)
      dac_reg<={dac_reg[79:0],dac_reg[89:80]};
//	dac_reg<={dac_reg[49:0],dac_reg[59:50]};	
end

always@(posedge clk or negedge rst)
begin
   if(!rst)
      dac_value<={1'b0,3'd0,8'd123,4'd0};
   else
   begin
      if(dac_set_rise && laser_enable)
         dac_value<={1'b0,3'd0,dac_reg[7:0],4'd0};//{1'b1,3'd0,dac_reg[9:0],2'd0}
		else if(dac_set_rise && (~laser_enable))
		   dac_value<=16'd0;
		else if(b_cnt==16'd870)
			dac_value<={1'b1,3'd0,8'd155,4'd0};
		else if(b_set_flag)
			dac_value<={1'b1,3'd0,CHANGE_TH_2,4'd0};
   end   
end


always@(posedge clk or negedge rst)
begin
   if(!rst)
      dac_set<=1'b1;
   else 
   begin
      if(dac_set_fall)
			dac_set<=1'b1;
		else if(b_cnt==16'd871)
			dac_set<=1'b1;
		else if(b_set_flag_fall)
			dac_set<=1'b1;
		else
			dac_set<=1'b0;
	end
end
   
endmodule
