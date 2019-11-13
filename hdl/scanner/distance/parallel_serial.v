module parallel_serial(                                                         //并行数据转为串行数据输出
    input  wire                                     clk,
    input  wire                                     rst,
    input  wire                 [399:0]             parallel_data,
    input  wire                                     tola_en,
    output reg                  [9:0]               single_cnt,
   
    output reg                                      data_en,
    output reg                                      single_en,
    output reg                                      serial_data
);      

    reg                         [399:0]             mid_data;
    reg                         [8:0]               cnt;
    reg                         [2:0]               state;
    


always@(posedge clk or negedge rst)
begin
    if(!rst)
    begin
        mid_data<=400'd0;
        state<=3'd0;
        cnt<=9'd0;
        data_en<=1'b0;
        
    end
    else
    begin
        case(state)
            3'd0:
                begin
                    cnt<=9'd0;
                    
                    if(tola_en)
                    begin
//                      mid_data<=parallel_data;
                        state<=state+1'b1;
                        
                    end
                    else
                        state<=3'd0;
                end
            3'd1:
                begin 
                    mid_data<=parallel_data;
                    state<=state+1'b1;
                end     
            3'd2:
                begin
                    if(cnt <400)
                    begin
                        cnt<=cnt+1'b1;
                        mid_data <= mid_data >> 1;
                        serial_data <= mid_data[0];
                        data_en <= 1'b1;
                        state<=3'd2;
                    end
                    else
                    begin
                        serial_data<=1'b0;
                        data_en<=1'b0;
                        state<=3'd0;
                        cnt<=9'd0;
                        
                    end             
                end
            default: ;
        endcase
    end
end
always@(posedge clk or negedge rst)            //当没有信号时的状态
begin
	if(!rst)
		single_cnt<=10'd0;
	else
	begin
		if(tola_en)
			single_cnt<=10'd0;
		else if(single_cnt < 10'd480)
			single_cnt<=single_cnt+1'b1;
		else if(single_cnt >= 10'd480)
			single_cnt<=10'd481;
	end
end

endmodule
