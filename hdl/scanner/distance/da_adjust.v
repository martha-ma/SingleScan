module da_adjust(
	input wire              clk,
	input wire              rst,
	input wire  [15:0]      dac_value,
	input wire              temp_en,
	input wire  [17:0]      ad_distance,
	input wire  [9:0]       dac_max,
	input wire  [9:0]       dac_min,
	output reg              da_en,
	output reg  [17:0]      da_distance
);

//localparam                       LOW_DA = 310;
//localparam                       k_DA = 2;
wire [9:0]     dac_real;
wire [9:0]     dac_change/* synthesis keep */;
wire [15:0]    after_distance/* synthesis keep */;
wire [9:0]     dac_base/* synthesis keep */;
wire [15:0]    k_DA/* synthesis keep */;

assign dac_base=dac_max-dac_min;


assign dac_real=dac_value[11:4];
assign dac_change=dac_real-dac_min;

always@(posedge clk or negedge rst)
begin
	if(!rst)
		da_distance<=18'd0;
	else if(temp_en)
		da_distance<=ad_distance-(after_distance>>5);
end
always@(posedge clk or negedge rst)
begin
	if(!rst)
		da_en<=1'b0;
	else if(temp_en)
		da_en<=1'b1;
	else
		da_en<=1'b0;
end

div_16 n1(
	.clock			(	clk				    ),
	.denom			(	{6'd0,dac_base}		),
	.numer			(	16'd2400			),
	.quotient		(	k_DA	            ),
	.remain			(                       )
	);

mul_p n4(
    .clock          (   clk                 ),
    .dataa          (   dac_change          ),		//	 p<= POINT_CNT1  
    .datab          (   k_DA[7:0]           ),
    .result         (   after_distance      )
);
endmodule
