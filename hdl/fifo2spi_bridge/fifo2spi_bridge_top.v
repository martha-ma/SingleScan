/*=============================================================================
# FileName    :	fifo2spi_bridge_top.v
# Author      :	author
# Email       :	email@email.com
# Description :	从一个FIFO接收数据，SPI转发出去，并将SPI接收到的数据转发出去
                往FIFO写入读指令后，接下来的一个字节代表读取数据的长度
# Version     :	1.0
# LastChange  :	2018-07-10 16:56:48
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module fifo2spi_bridge_top
(
    input   wire                clk,
    input   wire                rst,
    /*port*/

    input   wire                nios_cs ,   //

    input   wire                spiwr_fifo_out_valid , 
    input   wire [31:00]        spiwr_fifo_out_data , 
    output  wire                spiwr_fifo_out_ready , 

    input                       spird_fifo_in_ready,
    output  reg                 spird_fifo_in_valid,
    output  reg  [07:0]         spird_fifo_in_data,

    output  wire                sclk,
    output  wire                scs,
    output  wire                mosi,
    input   wire                miso
);


reg     [11:00]             read_len;
reg     [11:00]             len_cnt;


localparam              IDLE        = 0;
localparam              START       = 1;
localparam              ADDR_H      = 2;    // 转发高地址
localparam              ADDR_L      = 3;    // 转发低地址
localparam              CONTROL     = 4;    // 控制命令，根据bit[2]决定是读还是写
localparam              WRITE       = 5;
localparam              READ_LEN    = 6;    // 获得读取长度参数
localparam              READ_BYTE   = 7;
localparam              READ_CNT    = 8;
localparam              READ_JUDGE  = 9;    // 判断读数据个数是否达到
localparam              OVER        = 10;
(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[START]: cs_STRING = "START";
        cs[ADDR_H]: cs_STRING = "ADDR_H";
        cs[ADDR_L]: cs_STRING = "ADDR_L";
        cs[CONTROL]: cs_STRING = "CONTROL";
        cs[WRITE]: cs_STRING = "WRITE";
        cs[READ_LEN]: cs_STRING = "READ_LEN";
        cs[READ_BYTE]: cs_STRING = "READ_BYTE";
        cs[READ_CNT]: cs_STRING = "READ_CNT";
        cs[READ_JUDGE]: cs_STRING = "READ_JUDGE";
        cs[OVER]: cs_STRING = "OVER";
        default: cs_STRING = "XXXX";
    endcase
end
// synthesis translate_on

always @(posedge clk)
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
            if(~nios_cs)
                ns[START] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[START]:
        begin
            if(spiwr_fifo_out_valid)
                ns[ADDR_H] = 1'b1;
            else
                ns[START] = 1'b1;
        end
        cs[ADDR_H]:
        begin
            if(spiwr_fifo_out_valid)
                ns[ADDR_L] = 1'b1;
            else
                ns[ADDR_H] = 1'b1;
        end
        cs[ADDR_L]:
        begin
            if(spiwr_fifo_out_valid)
                ns[CONTROL] = 1'b1;
            else
                ns[ADDR_L] = 1'b1;
        end
        cs[CONTROL]:
        begin
            if(spiwr_fifo_out_data[2] == 1'b1)
                ns[WRITE] = 1'b1;
            else
                ns[READ_LEN] = 1'b1;
        end
        cs[WRITE]:
        begin
            if(nios_cs)
                ns[IDLE] = 1'b1;
            else
                ns[WRITE] = 1'b1;
        end
        cs[READ_LEN]:
        begin
            if(spiwr_fifo_out_valid)
                ns[READ_BYTE] = 1'b1;
            else
                ns[READ_LEN] = 1'b1;
        end
        cs[READ_BYTE]:
        begin
            if(state_cnt == 140)
                ns[READ_CNT] = 1'b1;
            else
                ns[READ_BYTE] = 1'b1;
        end
        cs[READ_CNT]:
        begin
            ns[READ_JUDGE] = 1'b1;
        end
        cs[READ_JUDGE]:
        begin
            if(spird_fifo_in_ready)
            begin
                if(len_cnt == read_len)
                    ns[OVER] = 1'b1;
                else
                    ns[READ_BYTE] = 1'b1;
            end
            else
                ns[READ_JUDGE] = 1'b1;
        end
        cs[OVER]:
        begin
            if(nios_cs)
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
        len_cnt <= 0;
    else if(cs[IDLE])
        len_cnt <= 0;
    else if(cs[READ_CNT])
        len_cnt <= len_cnt + 1'b1;
end

always @ (posedge clk or negedge rst)
begin
    if(~rst)
        read_len <= 0;
    else if(cs[IDLE])
        read_len <= 0;
    else if(cs[READ_LEN] & spiwr_fifo_out_valid)
        read_len <= spiwr_fifo_out_data;
end

wire                s_axi_tready;   // 可以作为空闲标志用
reg                 s_axi_tvalid;
reg  [07:00]        s_axi_tdata;

assign                  spiwr_fifo_out_ready = 1;
always @ (posedge clk)
begin
    if(~rst)
    begin
        s_axi_tvalid <= 0;
        s_axi_tdata <= 0;
    end
    else if(cs[READ_LEN])
    begin
        s_axi_tvalid <= 0;
        s_axi_tdata <= 0;
    end
    else if(cs[READ_BYTE])
        if(state_cnt == 4)
        begin
            s_axi_tvalid <= 1;
            s_axi_tdata <= 8'h00;
        end
        else
            s_axi_tvalid <= 0;
    else
    begin
        s_axi_tvalid <= spiwr_fifo_out_valid;
        s_axi_tdata <= spiwr_fifo_out_data[07:00];
    end

end


wire                m_axi_tvalid;
wire [07:00]        m_axi_tdata;
always @ (posedge clk or negedge rst)
begin
    if(~rst)
        spird_fifo_in_valid <= 0;
    else if(m_axi_tvalid & (cs[READ_BYTE] | cs[READ_CNT] | cs[READ_JUDGE]))
        spird_fifo_in_valid <= 1;
    else
        spird_fifo_in_valid <= 0;
end

always @ (posedge clk)
begin
    spird_fifo_in_data <= m_axi_tdata;
end

spi_master_core #
(
    .DATA_W          (  8               ),
    .SYS_FREQ        (  100_000_000     ),
    .SPI_FREQ        (  10_000_000      )
)
spi_master_coreEx01
(
    .clk             (  clk                 ),
    .rst             (  rst                 ),
    .enable          (  ~nios_cs            ),
    .config_reg      (  8'h00          ),
    .s_axi_tready    (  s_axi_tready        ),
    .s_axi_tvalid    (  s_axi_tvalid        ),
    .s_axi_tdata     (  s_axi_tdata         ),
    .m_axi_tready    (  spird_fifo_in_ready ),
    .m_axi_tvalid    (  m_axi_tvalid        ),
    .m_axi_tdata     (  m_axi_tdata         ),
    .sclk            (  sclk                ),
    .scs             (  scs                 ),
    .mosi            (  mosi                ),
    .miso            (  miso                )
);
endmodule
