/*=============================================================================
# FileName    : ad5328_top.v
# Author      : author
# Email       : email@email.com
# Description : 
# Version     : 1.0
# LastChange  : 2016-11-11 16:30:39
# ChangeLog   : 
=============================================================================*/

`timescale  1 ns/1 ps

module ad5328_top
(
    input   wire                clk,
    input   wire                rst_n,

    input   wire                dac_set,
    input   wire [15:0]         dac_value,

    output  wire                ldac_n,
    output  wire                sync_n,
    output  wire                sclk,
    output  wire                dout
);

        wire                    ready;
        wire                    wr_req;
        wire    [15:0]          wr_data;


        reg     [31:00]         cnt;

ad5328_drive    ad5328_driveEx01
(
    .clk          (    clk          ),
    .rst_n        (    rst_n        ),
    .dac_set      (    dac_set      ),
    .dac_value    (    dac_value    ),
    .ready        (    ready        ),
    .wr_req       (    wr_req       ),
    .wr_data      (    wr_data      )
) ;

ad5328_core ad5328_coreEx01
(
    .clk          (    clk          ),
    .rst_n        (    rst_n        ),
    .wr_req       (    wr_req       ),
    .wr_data      (    wr_data      ),
    .ready        (    ready        ),
    .ldac_n       (    ldac_n       ),
    .sync_n       (    sync_n       ),
    .sclk         (    sclk         ),
    .dout         (    dout         )
) ;
endmodule
