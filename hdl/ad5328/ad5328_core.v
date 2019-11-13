/*=============================================================================
# FileName    :	ad5328_core.v
# Author      :	author
# Email       :	email@email.com
# Description : Vout = (Vref * value) / (2**12)
# Version     :	1.0
# LastChange  :	2016-10-27 08:29:44
# ChangeLog   :
=============================================================================*/

`timescale 1 ns/1 ps

module ad5328_core
(
    input   wire                clk,
    input   wire                rst_n,

    input   wire                wr_req,
    input   wire [15:0]         wr_data,
    output  reg                 ready,

    output  reg                 ldac_n,
    output  reg                 sync_n,
    output  reg                 sclk,
    output  reg                 dout
);
localparam              DIV_CNT = 20;

localparam              IDLE    = 0;
localparam              START   = 1;
localparam              WRITE   = 2;
localparam              LDAC_N  = 3;
localparam              OVER    = 4;
reg     [OVER:0]        cs = 'd1, ns = 'd1;
reg     [15:0]          state_cnt;

reg     [7:0]           div_cnt;
reg     [7:0]           bit_cnt;
reg                     wr_req_lock;
reg     [15:0]          wr_data_lock;


always @ (posedge clk)
begin
    if(~rst_n)
    begin
        wr_req_lock <= 0;
        wr_data_lock <= 0;
    end
    else if(wr_req)
    begin
        wr_req_lock <= 1'b1;
        wr_data_lock <= wr_data;
    end
    else if(cs[WRITE])
        wr_req_lock <= 1'b0;
end
// synthesis translate_off
reg [63:0] CS_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]    : CS_STRING = "IDLE";
        cs[START]    : CS_STRING = "START";
        cs[WRITE]    : CS_STRING = "WRITE";
        cs[LDAC_N]    : CS_STRING = "LDAC_N";
        cs[OVER]    : CS_STRING = "OVER";
        default     : CS_STRING = "XXXX";
    endcase
end
// synthesis translate_on


always @(posedge clk)
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
            if(wr_req_lock)
                ns[START] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[START]:
        begin
            if(state_cnt == 1)
                ns[WRITE] = 1'b1;
            else
                ns[START] = 1'b1;
        end
        cs[WRITE]:
        begin
            if(bit_cnt == 16)
                ns[LDAC_N] = 1'b1;
            else
                ns[WRITE] = 1'b1;
        end
        cs[LDAC_N]:
        begin
            if(state_cnt == 20)
                ns[OVER] = 1;
            else
                ns[LDAC_N] = 1;
        end
        cs[OVER]:
        begin
            if(state_cnt == 10)
                ns[IDLE] = 1'b1;
            else
                ns[OVER] = 1'b1;
        end
        default:
            ns[IDLE] = 1'b1;
    endcase
end


always @ (posedge clk)
begin
    if(~rst_n)
    begin
        ready <= 0;
        sclk <= 1;
        sync_n <= 1;
        ldac_n <= 0;
        dout <= 0;
    end
    else
    begin
        case (1'b1)
            ns[IDLE]:
            begin
                ready <= 1;
                sclk <= 1;
                sync_n <= 1;
                //ldac_n <= 1;
                dout <= 0;
            end
            ns[START]:
            begin
                ready <= 0;
                sync_n <= 0;
            end
            ns[WRITE]:
            begin
                ready <= 0;
                sclk <= (div_cnt < DIV_CNT/2-1) ? 1 : 0;
                dout <= wr_data_lock[15-bit_cnt];
            end
            ns[LDAC_N]:
            begin
                sclk <= 1;
                //ldac_n <= (state_cnt >= 5) && (state_cnt <= 10) ? 0 : 1;
            end
            ns[OVER]:
            begin
                ready <= 1;
                sclk <= 1;
                sync_n <= 1;
                //ldac_n <= 1;
                dout <= 0;
            end
            default:
            begin
                ready <= 0;
                sclk <= 1;
                sync_n <= 1;
                //ldac_n <= 1;
                dout <= 0;
            end
        endcase
    end
end

always @ (posedge clk)
begin
    if(~rst_n)
        state_cnt <= 0;
    else if (cs != ns)
        state_cnt <= 0;
    else
        state_cnt <= state_cnt + 1'b1;
end

always @ (posedge clk)
begin
    if(~rst_n)
    begin
        div_cnt <= 0;
    end
    else if(cs[WRITE])
    begin
        if(div_cnt >= DIV_CNT-1)
        begin
            div_cnt <= 0;
            bit_cnt <= bit_cnt + 1'b1;
        end
        else
            div_cnt <= div_cnt + 1'b1;
    end
    else
    begin
        div_cnt <= 0;
        bit_cnt <= 0;
    end
end

endmodule
