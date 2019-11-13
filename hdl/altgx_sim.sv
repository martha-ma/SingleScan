/*=============================================================================
# FileName    :	altgx_sim.sv
# Author      :	author
# Email       :	email@email.com
# Description :	
# Version     :	1.0
# LastChange  :	2018-06-12 18:10:21
# ChangeLog   :	
=============================================================================*/

`timescale  1 ns/1 ps

module altgx_sim
(
    input   wire                clk,
    input   wire                rst,
    /*port*/

    input   logic               rx_datain,
    output  logic   [15:00]     rx_dataout,
    output  logic               rx_clkout = 0,

    output  logic   [15:00]     tx_datain,
    output  logic               tx_dataout,
    output  logic               tx_clkout,

    output  logic               pll_locked
);

reg                     clk_rx = 0;
always
    #(1s/2_000_000_000/2) clk_rx = ~clk_rx;

logic   [15:00]             recv_data;
initial
begin
    recv_data = 0;
    rx_dataout = 0;
    # 1us;
    forever
    begin
        for(int i = 0; i < 16; i = i + 1 )
        begin
            @ (posedge clk_rx);
            recv_data[i] = rx_datain;
            if(i == 15)
                rx_dataout = recv_data;
        end
    end
end

initial
begin
    pll_locked = 0;
    #2us;
    pll_locked = 1;
end

always
    #(1s/125_000_000/2) rx_clkout = ~rx_clkout;
assign                  tx_clkout = rx_clkout;
endmodule
