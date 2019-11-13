/*=============================================================================
# FileName    : ad5328_drive.v
# Author      : author
# Email       : email@email.com
# Description :
                APD serial num   dac channal
                PMT serial num   dac channal
# Version     : 1.0
# LastChange  : 2016-11-11 16:07:02
# ChangeLog   :
=============================================================================*/

`timescale  1 ns/1 ps

module ad5328_drive
(
    input   wire                clk,
    input   wire                rst_n,

    input   wire                dac_set,
    input   wire [15:0]         dac_value,

    input   wire                ready,
    output  reg                 wr_req,
    output  reg  [15:0]         wr_data
);

localparam              DATA_BIT = 1'b0;
localparam              CRTL_BIT = 1'b1;
localparam              CHANNAL_A = 3'b000;
localparam              CHANNAL_B = 3'b001;     // pmt_hv1
localparam              CHANNAL_C = 3'b010;     // pmt_hv2
localparam              CHANNAL_D = 3'b011;     // pmt_hv3
localparam              CHANNAL_E = 3'b100;
localparam              CHANNAL_F = 3'b101;
localparam              CHANNAL_G = 3'b110;
localparam              CHANNAL_H = 3'b111;

localparam              IDLE            = 0;
localparam              CONFIG_GAIN     = 1;
localparam              CONFIG_LDAC     = 2;
localparam              WAIT            = 3;
localparam              SET             = 4;
localparam              OVER            = 5;
reg     [OVER:0]        cs = 'd1, ns = 'd1;
reg     [15:0]          state_cnt;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[CONFIG_GAIN]: cs_STRING = "CONFIG_GAIN";
        cs[CONFIG_LDAC]: cs_STRING = "CONFIG_LDAC";
        cs[WAIT]: cs_STRING = "WAIT";
        cs[SET]: cs_STRING = "SET";
        cs[OVER]: cs_STRING = "OVER";
        default: cs_STRING = "XXXX";
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
            if(ready)
                ns[CONFIG_LDAC] = 1'b1;
            else
                ns[IDLE] = 1'b1;
//            ns[WAIT] = 1'b1;
        end
        cs[CONFIG_LDAC]:
        begin
            if(ready & state_cnt >= 800)
                ns[CONFIG_GAIN] = 1'b1;
            else
                ns[CONFIG_LDAC] = 1'b1;
        end
        cs[CONFIG_GAIN]:
        begin
            if(ready & state_cnt >= 800)
                ns[WAIT] = 1'b1;
            else
                ns[CONFIG_GAIN] = 1'b1;
        end
        cs[WAIT]:
        begin
            if(ready & dac_set)
                ns[SET] = 1'b1;
            else
                ns[WAIT] = 1'b1;
        end
        cs[SET]:
        begin
            if(ready & state_cnt >= 800)
                ns[WAIT] = 1'b1;
            else
                ns[SET] = 1'b1;
        end
        cs[OVER]:
        begin
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
        wr_req <= 0;
        wr_data <= 0;
    end
    else
    begin
        case (1'b1)
            ns[IDLE]:
            begin
                wr_req <= 0;
                wr_data <= 0;
            end
            ns[CONFIG_GAIN]:
            begin
                if(state_cnt == 2)
                begin
                    wr_req <= 1;
                    wr_data <= {1'b0,3'd0,10'd550,2'd0};//20 460:-10
                end
                else
                begin
                    wr_req <= 0;
                    wr_data <= 0;
                end
            end
            ns[CONFIG_LDAC]:
            begin
                if(state_cnt == 2)
                begin
                    wr_req <= 1;
                    wr_data <= {1'b1,3'd0,10'd60,2'd0};
                end
                else
                begin
                    wr_req <= 0;
                    wr_data <= 0;
                end
            end
            ns[SET]:
            begin
                if(state_cnt == 2)
                begin
                    wr_req <= 1;
                    wr_data <= dac_value;
                end
                else
                begin
                    wr_req <= 0;
                    wr_data <= 0;
                end
            end
            default:
            begin
                wr_req <= 0;
                wr_data <= 0;
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
endmodule

