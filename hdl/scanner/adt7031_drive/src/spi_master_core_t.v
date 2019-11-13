/*=============================================================================
# FileName    :   spi_master_core.v
# Author      :   author
# Email       :   email@email.com
# Description :   在spi写数据的同时，会从miso读取数据，读取数据的有效性由其他模块(drive)决定
                操作flash时，当前是读还是写，由drive发送的数据决定
                借用axi-stream协议的交互方式，具体使用时, m_axi_tready可以一直为1, m_axi_tvalid只保持一个周期高电平
# Version     :   1.0
# LastChange  : 2018-07-02 15:46:53
# ChangeLog   :   
=============================================================================*/

module spi_master_core_t #
(
    parameter                   DATA_W = 16,
    parameter                   SYS_FREQ = 125_000_000,
    parameter                   SPI_FREQ = 1_000_000
)
(
    input   wire                clk,
    input   wire                rst,

    input   wire                enable,      // enable = 1, 发送数据，如果是数据帧，发送期间，enable保持为1
    /*
     * bit[2] : lsbfe;  1, MSB first; 0, LSB first
     *
     * bit[7]   bit[6]   bit[5]   bit[4]   bit[3]   bit[2]   bit[1]   bit[0]
                                                    lsbfe    cpol     cpha
     */
    input   wire [07:00]        config_reg,

    /*
     * drive写到从机的数据 接口
     */
    output  wire                s_axi_tready,   // 可以作为空闲标志用
    input   wire                s_axi_tvalid,
    input   wire [DATA_W-1:00]  s_axi_tdata,

    /*
     * 需要响应给spi_master 读的数据 
     */
    input   wire                m_axi_tready,
    output  wire                m_axi_tvalid,
    output  reg  [DATA_W-1:00]  m_axi_tdata,

    output  reg                 sclk,
    output  wire                scs,
    output  reg                 mosi,
    input   wire                miso
);

localparam              FREQ_CNT = ((1_000_000_000/SPI_FREQ)/(1_000_000_000/SYS_FREQ));
initial
begin
    $display("freq_cnt is %d", FREQ_CNT);
end

reg     [07:00]             bit_cnt;
reg     [15:00]             clk_cnt;

reg     [1:0]               sclk_r;
wire                        sclk_rise;
wire                        sclk_fall;

assign          sclk_rise = sclk_r[1:0] == 2'b01;
assign          sclk_fall = sclk_r[1:0] == 2'b10;
always @ (posedge clk or negedge rst)
begin
    if(~rst)
        sclk_r    <= 2'b00;
    else
        sclk_r    <= {sclk_r[0], sclk};
end

localparam              IDLE    = 0;
localparam              CHECK   = 1;
localparam              SEND    = 2;
localparam              OVER    = 3;
(* KEEP = "TRUE" *)reg     [SEND:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt;

reg    [1:0]            send_state_r;
wire                    send_state_rise;
wire                    send_state_fall;

assign          send_state_rise = send_state_r[1:0] == 2'b01;
assign          send_state_fall = send_state_r[1:0] == 2'b10;
always @ (posedge clk or negedge rst)
begin
    if(~rst)
        send_state_r    <= 2'b00;
    else
        send_state_r    <= {send_state_r[0], cs[SEND]};
end

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[CHECK]: cs_STRING = "CHECK";
        cs[SEND]: cs_STRING = "SEND";
        default: cs_STRING = "XXXX";
    endcase
end
// synthesis translate_on

always @ (posedge clk or negedge rst)
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
            if(enable)
                ns[CHECK] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[CHECK]:
        begin
            if(~enable)
                ns[IDLE] = 1'b1;
            else
            begin
                if(s_axi_tready & s_axi_tvalid)
                    ns[SEND] = 1'b1;
                else
                    ns[CHECK] = 1'b1;
            end
        end
        cs[SEND]:
        begin
            if(bit_cnt == DATA_W)
                ns[CHECK] = 1'b1;
            else
                ns[SEND] = 1'b1;
        end
        default:
            ns[IDLE] = 1'b1;
    endcase
end

always @ (posedge clk or negedge rst)
begin
    if(~rst)
        state_cnt <= 0;
    else if (cs != ns)
        state_cnt <= 0;
    else
        state_cnt <= state_cnt + 1'b1;
end

always @ (posedge clk or negedge rst)
begin
    if(~rst)
        clk_cnt <= 0;
    else if(cs[SEND])
    begin
        if(clk_cnt == FREQ_CNT-1)
            clk_cnt <= 0;
        else
            clk_cnt <= clk_cnt + 1'b1;
    end
end

always @ (posedge clk or negedge rst)
begin
    if(~rst)
        bit_cnt <= 0;
    else if(cs[SEND])
    begin
        if(clk_cnt == FREQ_CNT -1)
            bit_cnt <= bit_cnt + 1'b1;
    end
    else
        bit_cnt <= 0;
end

assign                  s_axi_tready = ~cs[SEND];
assign                  scs = ~(cs[CHECK] | cs[SEND]);
always @ (posedge clk or negedge rst)
begin
    if(~rst)
        sclk <= 0;
    else
    begin
        case (config_reg[1:0])
            // cpol cpha
            2'b00:
            begin
                if(cs[SEND])
                begin
                    if(clk_cnt <= FREQ_CNT/2 -1)
                        sclk <= 0;
                    else
                        sclk <= 1;
                end
                else
                    sclk <= 0;
            end
            2'b01:
            begin
                if(ns[SEND])
                begin
                    if(clk_cnt <= FREQ_CNT/2 -1)
                        sclk <= 1;
                    else
                        sclk <= 0;
                end
                else
                    sclk <= 0;
            end
            2'b10:
            begin
                if(cs[SEND])
                begin
                    if(clk_cnt <= FREQ_CNT/2 -1)
                        sclk <= 1;
                    else
                        sclk <= 0;
                end
                else
                    sclk <= 1;
            end
            2'b11:
            begin
                if(ns[SEND])
                begin
                    if(clk_cnt <= FREQ_CNT/2 -1)
                        sclk <= 0;
                    else
                        sclk <= 1;
                end
                else
                    sclk <= 1;
            end
            default:
            begin
            end
        endcase
    end
end

reg     [DATA_W-1:00]             data_r;
always @ (posedge clk or negedge rst)
begin
    if(~rst)
    begin
        mosi <= 0;
        data_r <= 0;
    end
    else if(s_axi_tready & s_axi_tvalid)
        data_r <= s_axi_tdata;
    else if(cs[SEND])
    begin
        case (config_reg[1:0])
            2'b00:
            begin
                if(send_state_rise | sclk_fall)
                begin
                    data_r <= (data_r << 1);
                    mosi <= data_r[DATA_W-1];
                end
            end
            2'b10:
            begin
                if(send_state_rise | sclk_rise)
                begin
                    data_r <= (data_r << 1);
                    mosi <= data_r[DATA_W-1];
                end
            end
            2'b01:
            begin
                if(sclk_rise)
                begin
                    data_r <= (data_r << 1);
                    mosi <= data_r[DATA_W-1];
                end
            end
            2'b11:
            begin
                if(send_state_rise | sclk_fall)
                begin
                    data_r <= (data_r << 1);
                    mosi <= data_r[DATA_W-1];
                end
            end
            default:;
        endcase
    end
end



always @ (posedge clk or negedge rst)
begin
    if(~rst)
        m_axi_tdata <= 0;
    else if(cs[SEND])
    begin
        if(clk_cnt == FREQ_CNT/2)
            m_axi_tdata[DATA_W-1:0] <= {m_axi_tdata[DATA_W-2:0], miso};             // 最先进来的数据在最高位
    end
end
assign                  m_axi_tvalid = cs[SEND] & ns[CHECK];

endmodule
