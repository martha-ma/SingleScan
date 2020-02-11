`timescale  1 ns/1 ps

module laser_send_top
(
    input                       clk,        // 50Mhz
    input                       clk_125m,
    input   wire                rst_n,

    input   wire                laser_enable,
    input        [239:00]       laser_presdo,

    output  wire [0:0]          send_data,
    output  wire                send_en
    /*port*/
);

wire                        change_flag;
wire                        clk_250m_r0;
wire                        clk_250m_r1;
wire                        clk_250m_r2;
wire                        clk_250m_r3;
wire                        clk_250m_r4;

wire                        send_data0;
wire                        send_data1;
wire                        send_data2;
wire                        send_data3;
wire                        send_data4;
pll_250 n1(
    .inclk0          (    clk             ),
    .locked          (    locked          ),
    .c0              (    clk_250m_r0     ),
    .c1              (    clk_250m_r1     ),
    .c2              (    clk_250m_r2     ),
    .c3              (    clk_250m_r3     ),
    .c4              (    clk_250m_r4     )
);


cycle_ctrl #
(
    .SYS_FREQ        (    125_000_000     ),
    .OUT_FREQ        (    1000_000        )
)
cycle_ctrlEx01
(
    .clk             (    clk_125m        ),
    .rst_n           (    rst_n           ),
    .laser_enable    (    laser_enable    ),
    .laser_presdo    (    laser_presdo    ),
    .change_flag     (    change_flag     ),
    .send_en         (    send_en         )
);

send_data       send_dataEx01
(
    .clk             (    clk_250m_r0     ),
    .rst_n           (    rst_n           ),
    .send_en         (    send_en         ),
    .send_data       (    send_data      )
);

//send_data       send_dataEx02
//(
    //.clk             (    clk_250m_r1     ),
    //.rst_n           (    rst_n           ),
    //.send_en         (    send_en         ),
    //.send_data       (    send_data1      )
//);
//send_data       send_dataEx03
//(
    //.clk             (    clk_250m_r2     ),
    //.rst_n           (    rst_n           ),
    //.send_en         (    send_en         ),
    //.send_data       (    send_data2      )
//);
//send_data       send_dataEx04
//(
    //.clk             (    clk_250m_r3     ),
    //.rst_n           (    rst_n           ),
    //.send_en         (    send_en         ),
    //.send_data       (    send_data3      )
//);
//send_data       send_dataEx05
//(
    //.clk             (    clk_250m_r4     ),
    //.rst_n           (    rst_n           ),
    //.send_en         (    send_en         ),
    //.send_data       (    send_data4      )
//);

//change_output change_outputEx01
//(
    //.clk         (  clk_125m        ),
    //.rst_n       (  rst_n           ),
    //.change_flag (  change_flag     ),
    //.data_in0    (  send_data0      ),
    //.data_in1    (  send_data1      ),
    //.data_in2    (  send_data2      ),
    //.data_in3    (  send_data3      ),
    //.data_in4    (  send_data4      ),
    //.data_out    (  send_data       )
//);
endmodule
