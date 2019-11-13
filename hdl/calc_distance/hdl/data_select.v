/*=============================================================================
# FileName    :	data_select.v
# Author      :	author
# Email       :	email@email.com
# Description :	一圈会有1081个数据，这里接受一个偏移量设置，然后输出811个数据作为一圈数据
# Version     :	1.0
# LastChange  :	2018-12-25 14:55:51
# ChangeLog   :	
=============================================================================*/
`timescale  1 ns/1 ps

module data_select
(
    input   wire                clk,
    input   wire                rst_n,

    input   wire                zero_flag,
    input   wire [15:00]        angle_offset,  // unit: 0.333°的个数值
    input        [07:00]        min_display_distance,
    input   wire                data_in_valid,
    input   wire [15:00]        data_in,

    output  wire                cycle_enable,
    output  wire                data_out_valid,
    output  reg  [15:00]        data_out
);

reg     [15:00]             angle_offset_lock;
reg     [15:00]             offset_cnt;

localparam              IDLE    = 0;
localparam              SKIP    = 1;
localparam              ENABLE  = 2;
localparam              OVER    = 3;
(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[SKIP]: cs_STRING = "SKIP";
        cs[ENABLE]: cs_STRING = "ENABLE";
        cs[OVER]: cs_STRING = "OVER";
        default: cs_STRING = "XXXX";
    endcase
end
// synthesis translate_on

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
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
            if(zero_flag)
                ns[SKIP] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[SKIP]:
        begin
            if(offset_cnt == angle_offset_lock - 1)
                ns[ENABLE] = 1'b1;
            else
                ns[SKIP] = 1'b1;
        end
        cs[ENABLE]:
        begin
            if(offset_cnt >= angle_offset_lock + 811 -1)
                ns[IDLE] = 1'b1;
            else
                ns[ENABLE] = 1'b1;
        end
        default:
            ns[IDLE] = 1'b1;
    endcase
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        state_cnt <= 0;
    else if (cs != ns)
        state_cnt <= 0;
    else
        state_cnt <= state_cnt + 1'b1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        offset_cnt <= 0;
    else if(zero_flag)
        offset_cnt <= 0;
    else if(data_in_valid)
        offset_cnt <= offset_cnt + 1'b1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        angle_offset_lock <= 0;
    else if(cs[IDLE])
        angle_offset_lock <= angle_offset;
end


assign                  cycle_enable = cs[ENABLE];
assign                  data_out_valid = cs[ENABLE] & data_in_valid;
//assign                  data_out = cs[ENABLE] ? data_in : 0;
always @ (*)
begin
    if(cs[ENABLE])
    begin
        if(data_in < min_display_distance)
            data_out = 16'hFFFF;
        else
            data_out = data_in;
    end
    else
        data_out = 0;
end
endmodule
