/*=============================================================================
# FileName    :	update2nios.v
# Author      :	author
# Email       :	email@email.com
# Description : FIFO已经有不少于811个数据后，且NIOS可以读数据，才一起讲数据读取出去
# Version     :	1.0
# LastChange  :	2018-05-29 17:15:09
# ChangeLog   :
=============================================================================*/

`timescale  1 ns/1 ps

module update2nios
(
    input   wire                clk,
    input   wire                rst,

    output  reg                 fifo_rdreq,
    input   wire [31:00]        fifo_rddata,
    input   wire [10:00]        fifo_usedw,

    /*
     * 系统状态相关信号
     */

    input   wire [255:00]       fpga_status,

    input                       laser_fifo_in_ready,
    output  reg                 laser_fifo_in_valid,
    output  reg  [31:0]         laser_fifo_in_data
);

reg     [31:00]             timer_cnt;
wire                        timer_flag /* synthesis keep */;

reg     [31:00]             tx_command;
reg     [15:00]             tx_data_len;
reg     [15:00]             tx_data_cnt;

parameter               CYCLE_CNT = 900_000_000/8;
localparam  	        TX_HEAD = 16'h1234;
localparam              CYCLE_DATA_LEN = 811;
localparam              STATUS_DATA_LEN = 5;

localparam              UP_DISTANCE_DATA = 16'ha003;
localparam              UP_FPGA_STATUS = 16'hc100;

localparam              IDLE            = 0;
localparam              HEAD            = 1;
localparam              DATA_LEN        = 2;
localparam              DATA            = 3;
localparam              DLY             = 4;
localparam              CHECKSUM        = 5;
localparam              OVER            = 6;
(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [31:00]         state_cnt, state_cnt_n;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[DLY]: cs_STRING = "DLY";
        cs[HEAD]: cs_STRING = "HEAD";
        cs[DATA_LEN]: cs_STRING = "DATA_LEN";
        cs[DATA]: cs_STRING = "DATA";
        cs[CHECKSUM]: cs_STRING = "CHECKSUM";
        default: cs_STRING = "XXXX";
    endcase
end
// synthesis translate_on

always @ (posedge clk or negedge rst)
begin
    if(~rst)
    begin
        tx_command <= 0;
        tx_data_len <= 0;
    end
    else if(fifo_usedw >= CYCLE_DATA_LEN)
    begin
        tx_command <= UP_DISTANCE_DATA;
        tx_data_len <= CYCLE_DATA_LEN;
    end
    else if(timer_flag)
    begin
        tx_command <= UP_FPGA_STATUS;
        tx_data_len <= STATUS_DATA_LEN;
    end
    else if(cs[CHECKSUM])
    begin
        tx_command <= UP_FPGA_STATUS;
        tx_data_len <= 2;
    end
end

always @(posedge clk or negedge rst)
begin
    if(~rst)
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
            if( ( ( (fifo_usedw == CYCLE_DATA_LEN) || (fifo_usedw == CYCLE_DATA_LEN*2) ) & laser_fifo_in_ready)  | timer_flag)
                ns[HEAD] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[HEAD]:
        begin
            ns[DATA_LEN] = 1'b1;
        end
        cs[DATA_LEN]:
        begin
            ns[DATA] = 1'b1;
        end

        cs[DATA]:
        begin
            if(tx_data_cnt == tx_data_len-1)
                ns[DLY] = 1'b1;
            else
                ns[DATA] = 1'b1;
        end
        cs[DLY]:
        begin
            if(laser_fifo_in_ready)
                ns[CHECKSUM] = 1'b1;
            else
                ns[DLY] = 1'b1;
        end
        cs[CHECKSUM]:
        begin
            if(laser_fifo_in_ready)
                ns[IDLE] = 1'b1;
            else
                ns[OVER] = 1'b1;
        end
        cs[OVER]:
        begin
            if(state_cnt == 10000*800) // 80ms
                ns[IDLE] = 1'b1;
            else
                ns[OVER] = 1'b1;
        end
        default:
            ns[IDLE] = 1'b1;
    endcase
end

always @ (posedge clk or negedge rst)
begin
    if(~rst)
        state_cnt <= 0;
    else
        state_cnt <= state_cnt_n;
end

always @ (*)
begin
    if(~rst)
        state_cnt_n <= 0;
    else if (cs != ns)
        state_cnt_n <= 0;
    else
        state_cnt_n <= state_cnt + 1'b1;
end


always @ (*)
begin
    if(tx_command == UP_DISTANCE_DATA)
    begin
        //if(ns[DATA_LEN] | (ns[DATA] & (state_cnt_n < CYCLE_DATA_LEN-1) ) )
        if(cs[DATA])
            fifo_rdreq = 1;
        else
            fifo_rdreq = 0;
    end
    else
        fifo_rdreq = 0;
end

always @ (*)
begin
    if(cs[HEAD] | cs[DATA_LEN] | cs[DATA] | cs[CHECKSUM])
        laser_fifo_in_valid = 1;
    else
        laser_fifo_in_valid = 0;
end

always @ (*)
begin
    if(tx_command == UP_DISTANCE_DATA)
    begin
        if(cs[HEAD])
            laser_fifo_in_data = {16'h1234, UP_DISTANCE_DATA};
        else if(cs[DATA_LEN])
            laser_fifo_in_data = CYCLE_DATA_LEN;
        else if(cs[DATA])
            laser_fifo_in_data <= fifo_rddata;
            //laser_fifo_in_data = hex2string(fifo_rddata);
        else if(cs[CHECKSUM])
            laser_fifo_in_data = {1'b0, fpga_status[130:128], 28'heeeeeee};
        else
            laser_fifo_in_data = 0;
    end
    else if(tx_command == UP_FPGA_STATUS)
    begin
        if(cs[HEAD])
            laser_fifo_in_data = {16'h1234, UP_FPGA_STATUS};
        else if(cs[DATA_LEN])
            laser_fifo_in_data = STATUS_DATA_LEN;
        else if(cs[DATA])
        begin
            case (tx_data_cnt)
                0:laser_fifo_in_data = fpga_status[031:000];   // 电机速度计数值
                1:laser_fifo_in_data = fpga_status[063:032];    // 零位距离值
                2:laser_fifo_in_data = fpga_status[095:064];    // 灰尘计数值
                3:laser_fifo_in_data = fpga_status[127:096];    // 温度
                //4:laser_fifo_in_data = fpga_status[130:128];
                4:laser_fifo_in_data = fpga_status[142:131];    // 零位脉冲宽度
            default:;
            endcase
        end
        else if(cs[CHECKSUM])
            laser_fifo_in_data = 32'heeeeeeee;
        else
            laser_fifo_in_data <= 0;
    end
end

assign                  timer_flag = (timer_cnt == 100);
always @ (posedge clk or negedge rst)
begin
    if(~rst)
        timer_cnt <= 0;
    else if(cs[IDLE])
    begin
        if(timer_cnt <= CYCLE_CNT)   // 1s 上传1次
            timer_cnt <= timer_cnt + 1'b1;
        else
            timer_cnt <= 0;
    end
end

always @ (posedge clk or negedge rst)
begin
    if(~rst)
        tx_data_cnt <= 0;
    else if(cs[IDLE])
        tx_data_cnt <= 0;
    else if(laser_fifo_in_valid & laser_fifo_in_ready & cs[DATA])
        tx_data_cnt <= tx_data_cnt + 1'b1;
end
endmodule
