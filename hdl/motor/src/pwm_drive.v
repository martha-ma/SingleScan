/*=============================================================================
# FileName    :	pwm_drive.v
# Author      :	author
# Email       :	email@email.com
# Description :	
# Version     :	1.0
# LastChange  :	2018-10-08 15:20:59
# ChangeLog   :	
=============================================================================*/
`timescale  1 ns/1 ps

module pwm_drive
(
    input   wire                clk,
    input   wire                rst_n,
    /*port*/
    input   wire                enable,

    input   wire [15:00]        high_cnt,   // 高电平计数器
    input   wire [15:00]        low_cnt,    // 

    output  wire                pwm
);

reg     [15:00]             high_cnt_r0;
reg     [15:00]             low_cnt_r0;
always @ (posedge clk)
begin
    high_cnt_r0 <= high_cnt;
    low_cnt_r0 <= low_cnt;
end

localparam              IDLE    = 0;
localparam              HIGH    = 1;
localparam              LOW     = 2;
(* KEEP = "TRUE" *)reg     [LOW:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[HIGH]: cs_STRING = "HIGH";
        cs[LOW]: cs_STRING = "LOW";
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
            if(enable)
                ns[HIGH] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[HIGH]:
        begin
            if(state_cnt == high_cnt_r0-1)
                ns[LOW] = 1'b1;
            else
                ns[HIGH] = 1'b1;
        end
        cs[LOW]:
        begin
            if(state_cnt == low_cnt_r0-1)
            begin
                if(enable)
                    ns[HIGH] = 1'b1;
                else
                    ns[IDLE] = 1'b1;
            end
            else
                ns[LOW] = 1'b1;
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

assign                  pwm = (enable & cs[HIGH]) ? 1 : 0;
endmodule
