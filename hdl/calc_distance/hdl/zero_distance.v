/*=============================================================================
# FileName    :	zero_distance.v
# Author      :	author
# Email       :	email@email.com
# Description :	连续取8次零位信号后的2次测距值，滑动平均,
# Version     :	1.0
# LastChange  :	2019-06-20 18:29:43
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module zero_distance
(
    input                       clk,
    input                       rst_n,

    input        [15:00]        zero_distance_revise,
    input                       zero_flag,

    input                       data_in_valid,
    input        [15:00]        data_in,

    output  reg  [15:00]        data_out
    /*port*/
);

localparam              IDLE    = 0;
localparam              WAIT    = 1;
localparam              FIRST   = 2;
localparam              SECOND  = 3;
localparam              OVER    = 4;
(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt, state_cnt_n;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[WAIT]: cs_STRING = "WAIT";
        cs[FIRST]: cs_STRING = "FIRST";
        cs[SECOND]: cs_STRING = "SECOND";
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
                ns[WAIT] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[WAIT]:
        begin
            if(data_in_valid)
                ns[FIRST] = 1'b1;
            else
                ns[WAIT] = 1'b1;
        end
        cs[FIRST]:
        begin
            if(data_in_valid)
                ns[SECOND] = 1'b1;
            else
                ns[FIRST] = 1'b1;
        end
        cs[SECOND]:
        begin
            if(data_in_valid)
                ns[IDLE] = 1'b1;
            else
                ns[SECOND] = 1'b1;
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

reg     [15:00]             data_in_r00;
reg     [15:00]             data_in_r01;
reg     [15:00]             data_in_r02;
reg     [15:00]             data_in_r03;
reg     [15:00]             data_in_r04;
reg     [15:00]             data_in_r05;
reg     [15:00]             data_in_r06;
reg     [15:00]             data_in_r07;
reg     [15:00]             data_in_r08;
reg     [15:00]             data_in_r09;
reg     [15:00]             data_in_r10;
reg     [15:00]             data_in_r11;
reg     [15:00]             data_in_r12;
reg     [15:00]             data_in_r13;
reg     [15:00]             data_in_r14;
reg     [15:00]             data_in_r15;


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        data_in_r00 <= 0;
        data_in_r01 <= 0;
        data_in_r02 <= 0;
        data_in_r03 <= 0;
        data_in_r04 <= 0;
        data_in_r05 <= 0;
        data_in_r06 <= 0;
        data_in_r07 <= 0;
        data_in_r08 <= 0;
        data_in_r09 <= 0;
        data_in_r10 <= 0;
        data_in_r11 <= 0;
        data_in_r12 <= 0;
        data_in_r13 <= 0;
        data_in_r14 <= 0;
        data_in_r15 <= 0;
    end
    else if( (cs[WAIT] & ns[FIRST]) | (cs[FIRST] & ns[SECOND]) )
    begin
        data_in_r00 <= data_in;
        data_in_r01 <= data_in_r00;
        data_in_r02 <= data_in_r01;
        data_in_r03 <= data_in_r02;
        data_in_r04 <= data_in_r03;
        data_in_r05 <= data_in_r04;
        data_in_r06 <= data_in_r05;
        data_in_r07 <= data_in_r06;
        data_in_r08 <= data_in_r07;
        data_in_r09 <= data_in_r08;
        data_in_r10 <= data_in_r09;
        data_in_r11 <= data_in_r10;
        data_in_r12 <= data_in_r11;
        data_in_r13 <= data_in_r12;
        data_in_r14 <= data_in_r13;
        data_in_r15 <= data_in_r14;
    end
end

reg     [19:00]             data_pipe_00;
reg     [19:00]             data_pipe_01;
reg     [19:00]             data_pipe_02;
reg     [19:00]             data_pipe_03;
reg     [19:00]             data_pipe_04;
reg     [19:00]             data_pipe_05;
reg     [19:00]             data_pipe_06;
reg     [19:00]             data_pipe_07;
reg     [19:00]             data_pipe_08;

reg     [19:00]             data_pipe_10;
reg     [19:00]             data_pipe_11;
reg     [19:00]             data_pipe_12;
reg     [19:00]             data_pipe_13;

reg     [19:00]             data_pipe_20;
reg     [19:00]             data_pipe_21;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_out <= 0;
    else
    begin
        data_pipe_00 <= data_in_r00 + data_in_r01;
        data_pipe_01 <= data_in_r02 + data_in_r03;
        data_pipe_02 <= data_in_r04 + data_in_r05;
        data_pipe_03 <= data_in_r06 + data_in_r07;
        data_pipe_04 <= data_in_r08 + data_in_r09;
        data_pipe_05 <= data_in_r10 + data_in_r11;
        data_pipe_06 <= data_in_r12 + data_in_r13;
        data_pipe_07 <= data_in_r14 + data_in_r15;

        data_pipe_10 <= data_pipe_00 + data_pipe_01;
        data_pipe_11 <= data_pipe_02 + data_pipe_03;
        data_pipe_12 <= data_pipe_04 + data_pipe_05;
        data_pipe_13 <= data_pipe_06 + data_pipe_07;

        data_pipe_20 <= data_pipe_10 + data_pipe_11;
        data_pipe_21 <= data_pipe_12 + data_pipe_13;

        data_out <= ((data_pipe_20 + data_pipe_21)>>4) - zero_distance_revise;
        //data_out <= 
        //(( 
            //(data_in_r00 + data_in_r01) + 
            //(data_in_r02 + data_in_r03) + 
            //(data_in_r04 + data_in_r05) + 
            //(data_in_r06 + data_in_r07)
        //) 
            //+ 
        //(
            //(data_in_r08 + data_in_r09) + 
            //(data_in_r10 + data_in_r11) + 
            //(data_in_r12 + data_in_r13) + 
            //(data_in_r14 + data_in_r15)
        //) >> 4)
            //- 
        //zero_distance_revise;
    end 
end
endmodule
