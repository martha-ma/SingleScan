module tem_adjust(
	input wire              clk,
	input wire              rst,
	input wire              ad_en,
	input wire    [15:0]    ad_distance, 
	input wire    [11:0]    time_pluse_a, 
	input wire    [7:0]     POINT_TEM,
	input wire    [7:0]     CORRECT_TEM_1,
	input wire    [7:0]     CORRECT_TEM_2,
	input wire    [15:0]    tem_per,
	output reg    [11:0]    time_pluse_t,
	output reg              temp_en, 
	output reg    [17:0]    tem_distance
	);
	
	
	reg                     temp_en_1;
	wire          [17:0]    tem_distance_1;
	wire          [17:0]    tem_distance_2;
	reg           [7:0]     tem_change;

always@(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		tem_change<=8'd0;
	end
	else
	begin
		if(tem_per[13])
			tem_change<=tem_per[6:0]+POINT_TEM;
		else
		begin
			if(tem_per<POINT_TEM)
				tem_change<=POINT_TEM-tem_per[7:0];
			else
				tem_change<=tem_per[7:0]-POINT_TEM;
		end
			
	end
end

always@(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		tem_distance<=15'd0;
	end
	else
	begin
		if((tem_per[13])||(tem_per<POINT_TEM))
			tem_distance<=ad_distance+(tem_distance_2>>2);
		else
			tem_distance<=ad_distance-(tem_distance_1>>2);
	end
	
end


always@(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		temp_en_1<=1'b0;
		time_pluse_t<=12'd0;
	end
	else
	begin
		if(ad_en)
		begin
			temp_en_1<=1'b1;
			time_pluse_t<=time_pluse_a;
		end
		else
			temp_en_1<=1'b0;
	end
end
always@(posedge clk or negedge rst)
begin
	if(!rst)
	begin
		temp_en<=1'b0;
	end
	else
	begin
		if(temp_en_1)
			temp_en<=1'b1;
		else
			temp_en<=1'b0;
	end
end

mul_p n1(
    .clock          ( clk                    ),
    .dataa          ( {2'd0,tem_change}      ),		//	温度矫正系数4
    .datab          ( CORRECT_TEM_1          ),
    .result         ( tem_distance_1         )
	);
mul_p n2(
    .clock          ( clk                    ),
    .dataa          ( {2'd0,tem_change}      ),		//	温度矫正系数4
    .datab          ( CORRECT_TEM_2          ),
    .result         ( tem_distance_2         )
	);	
	
endmodule
