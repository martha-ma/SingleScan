/*=============================================================================
# FileName    :	filter_signal.v
# Author      :	author
# Email       :	email@email.com
# Description :	[过滤掉输入信号上的毛刺（电机运动造成）] 是由于OSC信号不稳定造成
                此模块的使用反而会造成信号的错误，所以简单的对异步信号进行同步
                2018.11.21 偶尔还会出现信号异常跳变，准备状态改变后两次确认过滤掉这个跳变
# Version     :	1.0
# LastChange  :	2018-10-25 10:27:47
# ChangeLog   :	
=============================================================================*/
module filter_signal
(
    input   wire                clk,
    input   wire                rst_n,
    input   wire                data_in,
    output  reg                 data_out
);

reg                         data_in_r0;
reg                         data_in_r1;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        data_in_r0 <= 0;
        data_in_r1 <= 0;
    end
    else
    begin
        data_in_r0 <= data_in;
        data_in_r1 <= data_in_r0;
    end
end

reg     [07:00]             time_cnt;
wire                        time_flag;
assign                  time_flag = &time_cnt;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        time_cnt <= 0;
    else
        time_cnt <= time_cnt + 1'b1;
end

localparam              IDLE            = 0;
localparam              LOW2HIGH        = 1;
localparam              LOW2HIGH_ACK0   = 2;
localparam              LOW2HIGH_ACK1   = 3;
localparam              LOW2HIGH_ACK2   = 4;
localparam              HIGH            = 5;
localparam              HIGH2LOW        = 6;
localparam              HIGH2LOW_ACK0   = 7;
localparam              HIGH2LOW_ACK1   = 8;
localparam              HIGH2LOW_ACK2   = 9;
localparam              LOW             = 10;
localparam              OVER            = 11;
(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[LOW2HIGH]: cs_STRING = "LOW2HIGH";
        cs[LOW2HIGH_ACK0]: cs_STRING = "LOW2HIGH_ACK0";
        cs[LOW2HIGH_ACK1]: cs_STRING = "LOW2HIGH_ACK1";
        cs[LOW2HIGH_ACK2]: cs_STRING = "LOW2HIGH_ACK2";
        cs[HIGH]: cs_STRING = "HIGH";

        cs[HIGH2LOW]: cs_STRING = "HIGH2LOW";
        cs[HIGH2LOW_ACK0]: cs_STRING = "HIGH2LOW_ACK0";
        cs[HIGH2LOW_ACK1]: cs_STRING = "HIGH2LOW_ACK1";
        cs[HIGH2LOW_ACK2]: cs_STRING = "HIGH2LOW_ACK2";
        cs[LOW]: cs_STRING = "LOW";
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
            if(time_flag)
            begin
                if(data_in_r1)
                    ns[LOW2HIGH] = 1'b1;
                else
                    ns[IDLE] = 1'b1;
            end
            else
                ns[IDLE] = 1'b1;
        end
        cs[LOW2HIGH]:
        begin
            if(time_flag)
            begin
                if(data_in_r1)
                    ns[LOW2HIGH_ACK0] = 1'b1;
                else
                    ns[LOW] = 1'b1;
            end
            else
                ns[LOW2HIGH] = 1'b1;
        end
        cs[LOW2HIGH_ACK0]:
        begin
            if(time_flag)
            begin
                if(data_in_r1)
                    ns[LOW2HIGH_ACK1] = 1'b1;
                else
                    ns[IDLE] = 1'b1;
            end
            else
                ns[LOW2HIGH_ACK0] = 1'b1;
        end
        cs[LOW2HIGH_ACK1]:
        begin
            if(time_flag)
            begin
                if(data_in_r1)
                    ns[LOW2HIGH_ACK2] = 1'b1;
                else
                    ns[IDLE] = 1'b1;
            end
            else
                ns[LOW2HIGH_ACK1] = 1'b1;
        end
        cs[LOW2HIGH_ACK2]:
        begin   // 连续3次检测都是高，则认为已经过滤掉信号异变
            if(time_flag)
            begin
                if(data_in_r1)
                    ns[HIGH] = 1'b1;
                else
                    ns[IDLE] = 1'b1;
            end
            else
                ns[LOW2HIGH_ACK2] = 1'b1;
        end
        cs[HIGH]:
        begin  
            if(time_flag)
            begin
                if(data_in_r1)
                    ns[HIGH] = 1'b1;
                else        // 高电平期间信号变低，暂时还认为是高
                    ns[HIGH2LOW] = 1'b1;
            end
            else
                ns[HIGH] = 1'b1;
        end
        cs[HIGH2LOW]:
        begin
            if(time_flag)
            begin
                if(data_in_r1)
                    ns[HIGH] = 1'b1;
                else
                    ns[HIGH2LOW_ACK0] = 1'b1;
            end
            else
                ns[HIGH2LOW] = 1'b1;
        end
        cs[HIGH2LOW_ACK0]:
        begin
            if(time_flag)
            begin
                if(data_in_r1)
                    ns[HIGH] = 1'b1;
                else
                    ns[HIGH2LOW_ACK1] = 1'b1;
            end
            else
                ns[HIGH2LOW_ACK0] = 1'b1;
        end
        cs[HIGH2LOW_ACK1]:
        begin
            if(time_flag)
            begin
                if(data_in_r1)
                    ns[HIGH] = 1'b1;
                else
                    ns[HIGH2LOW_ACK2] = 1'b1;
            end
            else
                ns[HIGH2LOW_ACK1] = 1'b1;
        end
        cs[HIGH2LOW_ACK2]:
        begin
            if(time_flag)
            begin
                if(data_in_r1)
                    ns[HIGH] = 1'b1;
                else
                    ns[LOW] = 1'b1;
            end
            else
                ns[HIGH2LOW_ACK2] = 1'b1;
        end
        cs[LOW]:
        begin
            if(time_flag)
            begin
                if(data_in_r1)
                    ns[LOW2HIGH] = 1'b1;
                else
                    ns[LOW] = 1'b1;
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
        data_out <= 0;
    else if(cs[LOW2HIGH_ACK2] & ns[HIGH])
        data_out <= 1;
    else if(cs[HIGH2LOW_ACK2] & ns[LOW])
        data_out <= 0;
end

endmodule
