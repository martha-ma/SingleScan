module cal_tem(
    input wire           clk,
    input wire           rst,
    input wire [15:0]    m_axis_tdata,
    input wire           m_axis_tvalid,
    output reg           tem_count_en,
    output reg [15:0]    tem_count
    
    );
    reg        [7:0]     tem_count_m/* synthesis keep */;
// reg                    tem_count_en;
    wire       [12:0]    m_axis_tdata_m/* synthesis keep */;
    reg        [1:0]     tem_count_en_r;
    wire                 tem_count_en_fall/* synthesis keep */;

assign        tem_count_en_fall=tem_count_en_r[1:0]==2'b10;
always@(posedge clk or negedge rst)                                      
begin
    if (!rst)
        tem_count_en_r<=2'b00;
    else
        tem_count_en_r<={tem_count_en_r[0],m_axis_tvalid};
end
//assign    m_axis_tdata_m=m_axis_tdata[12:0];
always@(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        tem_count_m<=8'd0;
    end
    else
    begin
        if(m_axis_tdata[13])
            tem_count_m <= (8192-m_axis_tdata[12:0])>>5;
        else
            tem_count_m <= m_axis_tdata[12:0] >> 5;
    end
end
always@(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        tem_count<=16'd0;
        tem_count_en<=1'b0;
    end
    else
    begin
        if(tem_count_en_fall)
        begin
            tem_count<={2'd0,m_axis_tdata[13],5'd0,tem_count_m};
            tem_count_en<=1'b1;
        end
        else
            tem_count_en<=1'b0;
    end
end    
endmodule
