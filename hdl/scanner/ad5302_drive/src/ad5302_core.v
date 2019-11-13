/*=============================================================================
# FileName    :	ad5302_core.v
# Author      :	author
# Email       :	email@email.com
# Description :	
# Version     :	1.0
# LastChange  :	2018-10-22 13:23:58
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module ad5302_core
(
    input   wire                clk,
    input   wire                rst_n,

    output  wire                s_axis_tready,   // 可以作为空闲标志用
    input   wire                s_axis_tvalid,
    input   wire [15:00]        s_axis_tdata,

    /*port*/
    output  wire                ldac_n,
    output  wire                sync_n,
    output  wire                sclk,
    output  wire                dout
);
spi_master_core #
(
    .DATA_W          (  16              ),
    .SYS_FREQ        (  125_000_000     ),
    .SPI_FREQ        (  1_000_000       )
)
spi_master_coreEx01
(
    .clk             (  clk                 ),
    .rst             (  rst_n               ),
    .enable          (  1'b1                ),
    .config_reg      (  {5'b00000, 3'b100}  ),
    .s_axi_tready    (  s_axis_tready       ),
    .s_axi_tvalid    (  s_axis_tvalid       ),
    .s_axi_tdata     (  s_axis_tdata        ),
    .m_axi_tready    (                      ),
    .m_axi_tvalid    (                      ),
    .m_axi_tdata     (                      ),
    .sclk            (  sclk                ),
    .scs             (  sync_n              ),
    .mosi            (  dout                ),
    .miso            (                      )
);

assign                  ldac_n = 0;
endmodule
