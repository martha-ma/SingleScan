/*=============================================================================
# FileName    :	cycle_ctrl.v
# Author      :	author
# Email       :	email@email.com
# Description :	产生重频信号
# Version     :	1.0
# LastChange  :	2018-06-01 14:54:40
# ChangeLog   :	
=============================================================================*/
//`timescale  1 ns/1 ps

module cycle_ctrl #
(
    parameter               SYS_FREQ = 125_000_000,
    parameter               OUT_FREQ = 1000_000//50hz////1mhz
)
(
    input   wire                clk,
    input   wire                rst_n,
    input   wire                laser_enable,
    input        [239:00]       laser_presdo,
    output                      change_flag,
    output  wire                send_en
);


reg     [239:00]             offset;

wire                         set_laser_presdo;
reg     [31:00]             laser_presdo_r0;
reg     [31:00]             laser_presdo_r1;

always @ (posedge clk)
begin
    laser_presdo_r0 <= laser_presdo[31];
    laser_presdo_r1 <= laser_presdo_r0;
end
assign                  set_laser_presdo = (laser_presdo_r1 != laser_presdo_r0);

localparam              BASIC_NUM = 120;  // 设计要求：984ns(123) + 8ns*N， N = [0,4]

localparam              IDLE    = 0;
localparam              BASIC   = 1;
localparam              OFFSET  = 2;
localparam              OVER    = 3;
(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt, state_cnt_n;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[BASIC]: cs_STRING = "BASIC";
        cs[OFFSET]: cs_STRING = "OFFSET";
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
            if(laser_enable)
                ns[BASIC] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[BASIC]:
        begin
            if(state_cnt == BASIC_NUM)
                ns[OFFSET] = 1'b1;
            else
                ns[BASIC] = 1'b1;
        end
        cs[OFFSET]:
        begin
            if(state_cnt == offset[2:0])
                ns[IDLE] = 1'b1;
            else
                ns[OFFSET] = 1'b1;
        end
        default:
            ns[IDLE] = 1'b1;
    endcase
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        state_cnt <= 0;
    else
        state_cnt <= state_cnt_n;
end

always @ (*)
begin
    if(~rst_n)
        state_cnt_n <= 0;
    else if (cs != ns)
        state_cnt_n <= 0;
    else
        state_cnt_n <= state_cnt + 1'b1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        offset <= 240'h000000000000111111111111222222222222333333333333444444444444;
    else if(set_laser_presdo)
        offset <= laser_presdo;
    else if(cs[IDLE] & ns[BASIC])
        offset <= {offset[235:00], offset[239:236]};
end

assign                  send_en = cs[OFFSET] & ns[IDLE];
assign                  change_flag = cs[BASIC] && (state_cnt == 60);
endmodule
