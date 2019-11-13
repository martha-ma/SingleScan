/*=============================================================================
# FileName    :   adt7301_core.v
# Author      :   author
# Email       :   email@email.com
# Description :   
# Version     :   1.0
# LastChange  :   2018-10-23 13:44:53
# ChangeLog   :   
=============================================================================*/

`timescale  1 ns/1 ps

module adt7301_core
(
    input   wire                clk,
    input   wire                rst_n,
   input   wire                data_in,
    input   wire                read_temp_flag,
    input   wire                enable,
    output  wire                m_axis_tvalid,
    input   wire                m_axis_tready,
    output  wire [15:00]        m_axis_tdata,

    /*port*/
    output  wire                cs_n,
    output  wire                sclk,
    output  wire                dout
    
);
    assign                      dout=1'b0;
spi_master_core_t #
(
    .DATA_W          (  16                 ),
    .SYS_FREQ        (  125_000_000        ),
    .SPI_FREQ        (  1000_000          )
)
spi_master_core_tEx01
(
    .clk             (  clk                 ),
    .rst             (  rst_n               ),
    .enable          (  enable              ),
    .config_reg      (  {5'b00000, 3'b100}  ),
    .s_axi_tready    (                      ),
    .s_axi_tvalid    (  read_temp_flag      ),
    .s_axi_tdata     (                      ),
    .m_axi_tready    (  m_axis_tready       ),
    .m_axi_tvalid    (  m_axis_tvalid       ),
    .m_axi_tdata     (  m_axis_tdata        ),
    .sclk            (  sclk                ),
    .scs             (  cs_n                ),
    .mosi            (                      ),
    .miso            (  data_in             )
);
endmodule
