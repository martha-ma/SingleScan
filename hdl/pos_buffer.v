/*=============================================================================
# FileName    :	pos_buffer.v
# Author      :	author
# Email       :	email@email.com
# Description :	将距离数据缓存，一起发送到nios
# Version     :	1.0
# LastChange  :	2018-06-12 13:24:07
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module pos_buffer
(
    input   wire                clk,
    input   wire                clk_100m,
    input   wire                rst,

    input   wire                update_enable,
    input   wire                cycle_enable,
    input   wire                target_valid,          // 一个周期，有效期间输出一个角度计算的距离
    input   wire [15:00]        target_pos,      // 距离:mm
    input        [15:00]        target_gray,


    input   wire                fifo_rdreq,
    output  wire [31:00]        fifo_rddata,
    output  wire [10:00]        fifo_usedw
);

reg                         enable_flag;
wire    [10:00]             wrusedw;


reg    [1:0]            cycle_enable_r;
wire                    cycle_enable_rise /* synthesis keep */;
wire                    cycle_enable_fall;

assign          cycle_enable_rise = cycle_enable_r[1:0] == 2'b01;
assign          cycle_enable_fall = cycle_enable_r[1:0] == 2'b10;
always @ (posedge clk or negedge rst)
begin
    if(~rst)
        cycle_enable_r    <= 2'b00;
    else
        cycle_enable_r    <= {cycle_enable_r[0], cycle_enable};
end

/*
 * 使能上传期间，如果cycle_enable信号变高，且FIFO可以存放一次完整的数据帧，则允许向FIFO写入数据。
 * 禁止上传后，如果cycle_enable还是1，则说明本次数据帧没有写完
 */
always @ (posedge clk or negedge rst)
begin
    if(~rst)
        enable_flag <= 0;
    else if(update_enable)
    begin
        if(cycle_enable_rise)
        begin
            // 写完一圈数据后, 剩1237
            // 写完二圈数据后, 剩426
            //if (wrusedw < (2048-811))
            if( (wrusedw == 0) || (wrusedw == 811) )
                enable_flag <= 1;
            else
                enable_flag <= 0;
        end
    end
    else
    begin
        if(~cycle_enable)
            enable_flag <= 0;
    end
end

/*
*  2*66ms内, 如果fifo_usedw 没有变化, 则复位fifo, 清空usedw
*/
localparam              TIME_100MS = 100*1000*100;
reg     [10:00]             fifo_usedw_r0;
reg     [10:00]             fifo_usedw_r1;

always @ (posedge clk)
begin
    fifo_usedw_r0 <= fifo_usedw;
    fifo_usedw_r1 <= fifo_usedw_r0;
end

reg     [31:00]             time_out_cnt;
wire             aclr = (time_out_cnt == TIME_100MS);
always @ (posedge clk or negedge rst)
begin
    if(~rst)
        time_out_cnt <= 0;
    else if(update_enable)
    begin
        if(time_out_cnt == TIME_100MS)    // 100ms
            time_out_cnt <= 0;
        else
        begin
            if(fifo_usedw_r0 != fifo_usedw_r1)
                time_out_cnt <= 0;
            else
                time_out_cnt <= time_out_cnt + 1'b1;
        end
    end
end


/*
 * 将16进制格式的距离数据 转换为 ascii码格式
 */
function [31:00] hex2string;
    input [31:00] hex_data;
begin
    if( (hex_data[15:12] >= 0) && (hex_data[15:12] <= 9) )
        hex2string[31:24] = hex_data[15:12] + 8'h30;
    else
        hex2string[31:24] = hex_data[15:12] + 8'h37;

    if( (hex_data[11:08] >= 0) && (hex_data[11:08] <= 9) )
        hex2string[23:16] = hex_data[11:08] + 8'h30;
    else
        hex2string[23:16] = hex_data[11:08] + 8'h37;

    if( (hex_data[07:04] >= 0) && (hex_data[07:04] <= 9) )
        hex2string[15:08] = hex_data[07:04] + 8'h30;
    else
        hex2string[15:08] = hex_data[07:04] + 8'h37;

    if( (hex_data[03:00] >= 0) && (hex_data[03:00] <= 9) )
        hex2string[07:00] = hex_data[03:00] + 8'h30;
    else
        hex2string[07:00] = hex_data[03:00] + 8'h37;
end
endfunction

pos_fifo pos_fifoEx01
(
    .aclr     (    aclr                          ),
    .wrclk    (    clk                           ),

    .wrreq    (    enable_flag & target_valid    ),
    //.data     (    {14'd0,target_pos}            ),
    .data     (    {target_gray, target_pos}     ),

    .rdclk    (    clk_100m                      ),
    .rdreq    (    fifo_rdreq                    ),
    .q        (    fifo_rddata                   ),

    .wrfull   (                                  ),
    .rdempty  (                                  ),
    .wrusedw  (    wrusedw                       ),
    .rdusedw  (    fifo_usedw                    )
);

endmodule
