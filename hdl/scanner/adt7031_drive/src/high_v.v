module high_v(
    input wire          clk,
    input wire          rst,
    input wire          m_axis_tvalid,
    input wire [9:0]    INITIAL_COUNT,
    input wire [15:0]   tem_count,
    input wire [7:0]    TEM_K,
    input wire [7:0]    TEM_KH,
    input wire [7:0]    POINT_TEM,
    output reg          set_en,
    output wire[12:0]   tem_count_test,
    output reg [15:0]   da_count
);
//localparam              INITIAL_COUNT = 555;
//reg     [7:0]         INITIAL_TEM;
//localparam     [7:0]    TEM_K = 5;
////
//localparam     [7:0]    TEM_KH = 4;
//localparam     [9:0]    MAX = INITIAL_COUNT+132;//715;         //上限60c
//localparam              POINT_TEM = 30;
//
    wire       [17:0]   da_count_change;
    wire       [17:0]   da_count_change_H;
    wire       [9:0]    MAX;

    reg        [15:0]   tem_count_m;  
    reg        [9:0]    da_count_m/* synthesis keep */;
    reg        [7:0]    tem_change;
    wire                m_axis_tvalid_fall;
    wire                m_axis_tvalid_rise;
    reg        [1:0]    m_axis_tvalid_r;
    reg                 set_en_m;
    reg        [1:0]    set_en_r;
    wire                set_en_fall;
//assign      INITIAL_TEM = POINT_TEM;     
assign      MAX = INITIAL_COUNT+240;                   //715;         //上限60c
assign      m_axis_tvalid_fall=m_axis_tvalid_r[1:0]==2'b10;
assign      m_axis_tvalid_rise=m_axis_tvalid_r[1:0]==2'b01;
assign      tem_count_test=tem_count_m[12:0];
always@(posedge clk or negedge rst)                             
begin
    if (!rst)
        m_axis_tvalid_r<=2'b00;
    else
        m_axis_tvalid_r<={m_axis_tvalid_r[0],m_axis_tvalid};
end

always@(posedge clk or negedge rst)
begin
   if(!rst)
    set_en_m<=1'b0;
    else if(m_axis_tvalid_fall)
    set_en_m<=1'b1;
    else
    set_en_m<=1'b0;
end

assign      set_en_fall=set_en_r[1:0]==2'b10;

always@(posedge clk or negedge rst)                             
begin
    if (!rst)
        set_en_r<=2'b00;
    else
        set_en_r<={set_en_r[0],set_en_m};
end

always@(posedge clk or negedge rst)
begin
   if(!rst)
    tem_count_m<=16'd0;
    else if(m_axis_tvalid_rise)
    tem_count_m<=tem_count;
end

always@(posedge clk or negedge rst)                                 //判断温度差值
begin
    if(!rst)
        tem_change<=8'd0;
    else if(tem_count_m[13])
        tem_change<=tem_count_m[12:0]+POINT_TEM;
    else
    begin
        if(tem_count_m[12:0]>POINT_TEM)
            tem_change<=tem_count_m[12:0]-POINT_TEM;
        else
            tem_change<=POINT_TEM-tem_count_m[12:0];
    end
end
always@(posedge clk or negedge rst)                                 //计算da设置数值
begin
   if(!rst)
        da_count_m<=10'd0;
    else if((tem_count_m[13])||(tem_count_m[12:0]<=POINT_TEM))
        da_count_m<=(INITIAL_COUNT-(da_count_change[11:0]>>3));
    else
        da_count_m<=(INITIAL_COUNT+(da_count_change_H[11:0]>>3));
end
always@(posedge clk or negedge rst)                                //当计算数值大于最高值时，就保持设置的最高值
begin
    if(!rst)
    da_count<=16'd0;
    else
    begin
        if(da_count_m < MAX )
        da_count<={1'b0,3'd0,da_count_m,2'd0};
        else
        da_count<={1'b0,3'd0,MAX,2'd0};
    end
end
always@(posedge clk or negedge rst)                                //设置da数值使能
begin
    if(!rst)
    set_en<=1'b0;
    else if(set_en_fall)
    set_en<=1'b1;
    else
    set_en<=1'b0;
end

mul_p n1(
    .clock          ( clk               ),
    .dataa          ( {2'd0,tem_change} ),      //k*(t-t0)  
    .datab          ( TEM_K             ),
    .result         ( da_count_change   )
    );
mul_p n2(
    .clock          ( clk               ),
    .dataa          ( {2'd0,tem_change} ),      //k*(t-t0)  
    .datab          ( TEM_KH            ),
    .result         ( da_count_change_H )
    );


endmodule

