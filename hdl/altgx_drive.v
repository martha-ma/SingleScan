//`timescale  1 ns/1 ps

module altgx_drive
(
    input   wire                clk,
    input   wire                rst_n,
    input   wire [0:0]          rx_datain,
    output  wire [0:0]          tx_dataout,

    output  wire                rx_clkout,
    output  wire                tx_clkout,
    output  wire [15:00]        rx_dataout

    /*port*/
);

wire    [15:00]             tx_datain;
wire                        gxb_powerdown;
wire                        tx_digitalreset;
wire                        rx_analogreset;
wire                        rx_digitalreset;
wire                        pll_locked;

gx_rst_ctrl gx_rst_ctrlEx01
(
    .clk                    (    clk                ),
    .rst_n                  (    rst_n              ),
    .pll_locked             (    pll_locked         ),
    .gxb_powerdown          (    gxb_powerdown      ),
    .tx_digitalreset        (    tx_digitalreset    ),
    .rx_analogreset         (    rx_analogreset     ),
    .rx_digitalreset        (    rx_digitalreset    )
);


// 仿真电机时，关闭pll功能，提升仿真速度
`ifdef ALTGX_SIM
altgx_sim altgx_simEx01
(
    .clk                    (    clk                ),
    .rst                    (    rst_n              ),
    .rx_datain              (    rx_datain          ),
    .rx_dataout             (    rx_dataout         ),
    .rx_clkout              (    rx_clkout          ),
    .tx_datain              (    tx_datain          ),
    .tx_dataout             (    tx_dataout         ),
    .tx_clkout              (    tx_clkout          ),
    .pll_locked             (    pll_locked         )
);
`else
ALTGX   ALTGXEx01(
        .cal_blk_clk        (    clk                ),

        .gxb_powerdown      (    gxb_powerdown      ),
        .pll_areset         (    gxb_powerdown      ),
        .pll_inclk          (    clk                ),

        .rx_analogreset     (    rx_analogreset     ),
        .rx_datain          (    rx_datain          ),
        .rx_digitalreset    (    rx_digitalreset    ),
        .rx_locktodata      (    1'b0               ),
        .rx_locktorefclk    (    1'b1               ),
        .tx_datain          (    tx_datain          ),
        .tx_digitalreset    (    tx_digitalreset    ),
        .pll_locked         (    pll_locked         ),

        .rx_clkout          (    rx_clkout          ),
        .rx_dataout         (    rx_dataout         ),
        .rx_freqlocked      (    rx_freqlocked      ),
        .tx_clkout          (    tx_clkout          ),
        .tx_dataout         (    tx_dataout         )
);
`endif

endmodule
