`timescale  1 ns/1 ps

module degree_info
(
    input                       clk,

    input        [31:00]        cycle_cnt,
    output       [07:00]        degree_para
);

wire    [31:00]             denom = ((360*1000)<<1) + (360*1000);

mod_degree mod_degreeEx01
(
    .clock       (  clk             ),
    .denom       (  denom           ),
    .numer       (  cycle_cnt<<3    ),
    .quotient    (  degree_para     ),
    .remain      (                  )
);

endmodule
