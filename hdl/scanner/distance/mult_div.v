/*=============================================================================
# FileName    : mult_div.v
# Author      : author
# Email       : email@email.com
# Description :
        1. 距离单位：mm
        2. 脉冲宽度：time_pluse/2 = t(ns)
        3. 将接收到的0-5个回波，按顺序输出。间隔大约20个时钟周期。
		4. 有几个回波输出几个回波。
# Version     : 1.0
# LastChange  : 2018-10-11 17:53:18
# ChangeLog   :
=============================================================================*/

module mult_div(
	input wire              clk,
	input wire              rst,
	input wire [39:0]       mult_pluse,
	input wire [79:0]       mult_distance,
	input wire              valid_m,
	output reg              valid,
	output reg [11:0]       time_pluse,
	output reg [17:0]       distance
);



	reg        [79:0]       mult_distance_m;
	reg        [39:0]       mult_pluse_m;
	reg        [7:0]        pluse;
	reg        [15:0]       distance_reg;
	reg        [7:0]        mult_delay;
	reg                     valid_1;
	reg                     valid_int;
    reg        [1:0]        valid_r;
    wire                    valid_rise;
	wire                    valid_fall;



assign      valid_rise=valid_r[1:0]==2'b01;
assign      valid_fall=valid_r[1:0]==2'b10;

always@(posedge clk or negedge rst)                             
begin
    if (!rst)
    begin
        valid_r<=2'b00;
    end
    else
        valid_r<={valid_r[0],valid_int};
end

always@(posedge clk or negedge rst)
begin
	if(!rst)
		valid_int<=1'b0;
	else 
		valid_int<=valid_m;
end




always@(posedge clk or negedge rst)
begin
	if(!rst)
		mult_delay<=8'd0;
	else if(valid_rise)
		mult_delay<=8'd0;
	else 
		mult_delay<=mult_delay+1'b1;
end


always@(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		mult_pluse_m<=40'd0;
		mult_distance_m<=80'd0;
	end
	else if(valid_int)
	begin
		mult_pluse_m<=mult_pluse;
		mult_distance_m<=mult_distance;
	end
	else if((mult_delay==8'd18)||(mult_delay==8'd38)||(mult_delay==8'd58)||(mult_delay==8'd78))
	begin
		mult_pluse_m<=mult_pluse_m<<8;
		mult_distance_m<=mult_distance_m<<16;
	end
	
end


 
always@(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		distance_reg<=16'd0;
		pluse<=8'd0;
	end
	else
	begin
		distance_reg<=mult_distance_m[79:64];
		pluse<=mult_pluse_m[39:32];
	end
end


always@(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		time_pluse<=12'd0;
		distance<=18'd0;
		valid_1<=1'b0;
	end
	else if((mult_delay==8'd80)&&(distance_reg==16'd0))
	begin
		time_pluse<=12'd0;
		distance<=16'hffff;
		valid_1<=1'b1;
	end		
	else if(distance_reg>0)
	begin
		if((valid_fall)||(mult_delay==8'd20)||(mult_delay==8'd40)||(mult_delay==8'd60)||(mult_delay==8'd80))
		begin
			distance<={2'd0,distance_reg};
			time_pluse<={4'd0,pluse};
			valid_1<=1'b1;
		end
		else
		valid_1<=1'b0;
	end
	else
	valid_1<=1'b0;
end

always@(posedge clk or negedge rst)
begin
	if(!rst)
		valid<=1'b0;
	else
		valid<=valid_1;
end
endmodule
	
	
	