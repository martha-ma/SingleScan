/*=============================================================================
# FileName    :	move_average.v
# Author      :	author
# Email       :	email@email.com
# Description :	数据位宽可通过参数设置，但滑动次数暂不可设
# Version     :	1.0
# LastChange  :	2018-12-20 16:07:43
# ChangeLog   :	
=============================================================================*/

module move_average #
(
    parameter               WIDTH = 8,
    parameter               AVE_N = 16
)
(
    input   wire                clk,
    input   wire                rst_n,

    input   wire                enable,
    input   wire                data_in_valid,
    input   wire [WIDTH-1:00]   data_in,

    output  reg                 data_out_valid,
    output  reg  [WIDTH-1:00]   data_out
);

/* 
 * 2^x = bit_depth, return x+1
 */
function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
  endfunction // clogb2

localparam              P_WIDTH = WIDTH*AVE_N;
reg     [P_WIDTH-1:00]      parallel_data;  // 数据先移位成并行数据

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        parallel_data <= 0;
    else if(data_in_valid)
        parallel_data[P_WIDTH-1:0] <= {parallel_data[P_WIDTH-WIDTH-1:0], data_in};             // 最先进来的数据在最高位
end

reg     [P_WIDTH-1:00]      sum_result;
always @(*)
begin

sum_result = 
        //( (parallel_data[WIDTH*6'd01-1:WIDTH*6'd00] + 
        //parallel_data[WIDTH*6'd02-1:WIDTH*6'd01]) +

        //(parallel_data[WIDTH*6'd03-1:WIDTH*6'd02] + 
        //parallel_data[WIDTH*6'd04-1:WIDTH*6'd03]) ) + 

        //( (parallel_data[WIDTH*6'd05-1:WIDTH*6'd04] + 
        //parallel_data[WIDTH*6'd06-1:WIDTH*6'd05]) + 

        //(parallel_data[WIDTH*6'd07-1:WIDTH*6'd06] + 
        //parallel_data[WIDTH*6'd08-1:WIDTH*6'd07]) ); 

        ( (parallel_data[WIDTH*6'd01-1:WIDTH*6'd00] + 
        parallel_data[WIDTH*6'd02-1:WIDTH*6'd01]) +

        (parallel_data[WIDTH*6'd03-1:WIDTH*6'd02] + 
        parallel_data[WIDTH*6'd04-1:WIDTH*6'd03]) ) ;


    // ( ( ( (parallel_data[WIDTH*6'd01-1:WIDTH*6'd00] + 
    //         parallel_data[WIDTH*6'd02-1:WIDTH*6'd01]) +

    //         (parallel_data[WIDTH*6'd03-1:WIDTH*6'd02] + 
    //         parallel_data[WIDTH*6'd04-1:WIDTH*6'd03]) ) + 

    //         ( (parallel_data[WIDTH*6'd05-1:WIDTH*6'd04] + 
    //         parallel_data[WIDTH*6'd06-1:WIDTH*6'd05]) + 

    //         (parallel_data[WIDTH*6'd07-1:WIDTH*6'd06] + 
    //         parallel_data[WIDTH*6'd08-1:WIDTH*6'd07]) ) )+ 

    //         ( ( (parallel_data[WIDTH*6'd09-1:WIDTH*6'd08] + 
    //         parallel_data[WIDTH*6'd10-1:WIDTH*6'd09]) + 

    //         (parallel_data[WIDTH*6'd11-1:WIDTH*6'd10] + 
    //         parallel_data[WIDTH*6'd12-1:WIDTH*6'd11]) ) + 

    //         ( (parallel_data[WIDTH*6'd13-1:WIDTH*6'd12] + 
    //         parallel_data[WIDTH*6'd14-1:WIDTH*6'd13]) + 

    //         (parallel_data[WIDTH*6'd15-1:WIDTH*6'd14] + 
    //         parallel_data[WIDTH*6'd16-1:WIDTH*6'd15]) ) ) ) ;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_out <= 0;
    else if(enable)
    begin
        if(data_in_valid)
            data_out <= sum_result[WIDTH + clogb2(AVE_N)-1:clogb2(AVE_N)];
    end
    else
        data_out <= 0;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_out_valid <= 0;
    else 
        data_out_valid <= data_in_valid;
end
endmodule

