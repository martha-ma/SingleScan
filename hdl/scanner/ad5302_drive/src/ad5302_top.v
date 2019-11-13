/*=============================================================================
# FileName    :	ad5302_top.v
# Author      :	author
# Email       :	email@email.com
# Description :	dac需要接收外部模块的数据
# Version     :	1.0
# LastChange  :	2018-10-22 13:20:17
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module ad5302_top
(
    input   wire                clk,
    input   wire                rst_n,
    
    output  wire                s_axis_tready,
    input   wire                s_axis_tvalid,
    input   wire [08:00]        s_axis_tdata,   // bit8 0， dac A；bit8 1 DAC B

    output  wire                ad5302_sync_n,
    output  wire                ad5302_sclk,
    output  wire                ad5302_dout
);


wire    [15:00]             dac_data;
assign                  dac_data = {s_axis_tdata[8], 3'b000, s_axis_tdata[07:00], 4'b000};

ad5302_core ad5302_coreEx01
(
    .clk             (  clk                 ),
    .rst_n           (  rst_n               ),
    .s_axis_tready   (  s_axis_tready       ),
    .s_axis_tvalid   (  s_axis_tvalid       ),
    .s_axis_tdata    (  dac_data            ),
    .ldac_n          (  ldac_n              ),
    .sync_n          (  sync_n              ),
    .sclk            (  sclk                ),
    .dout            (  dout                )
);

endmodule
