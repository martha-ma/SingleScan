`timescale  1 ns/1 ps

module calc_distance_toptb ();
reg                     clk = 0;
always
    #(1s/125_000_000/2) clk = ~clk;

reg                     rst_n = 1;
initial
begin
    #1us; rst_n = 0;
    #1us; rst_n = 1;
end

logic                       send_en = 0;
logic                       valid_in = 0;
logic   [15:00]             distance_in = 0;
logic   [15:00]             gray_in = 0;


task generate_send();
    while(1)
    begin
        #1us;
        @(posedge clk);
        send_en = 1;
        @(posedge clk);
        send_en = 0;
    end
endtask

integer distance_num;
integer space;

logic   [15:00]             send_cnt = 0;
task write_data();
    while(1)
    begin
        wait (send_en);
        send_cnt = send_cnt + 1;
        distance_num = $urandom_range(1, 1);
        
        for(int i = 0; i < distance_num; i = i + 1 )
        begin
            space = 20;
            for(int i = 0; i < space; i = i + 1 )
            begin
                @(posedge clk);
            end

            @(posedge clk);
            valid_in = 1;
            //if( (send_cnt >= 15) && (send_cnt <= 105) )
                //distance_in = 16'hffff;
            //else
            distance_in = $urandom_range(1700, 2100);
            gray_in = $urandom_range(10, 100);
            @(posedge clk);
            valid_in = 0;
        end
    end
endtask

logic                       zero_flag = 0;
logic                       wheel_fall = 0;
logic   [07:00]             step_cnt = 0;

// 1*100000000/15.36/(360*3)/100=60.281635802469135803
logic        [07:00]        degree_para = 60;   // 0.333°需要采集多少次数据
task motor_signal();
    while(1)
    begin
        @(posedge clk);
        zero_flag = 1;
        wheel_fall = 1;
        @(posedge clk);
        zero_flag = 0;
        wheel_fall = 0;
        for(int i = 0; i < 44; i = i + 1 )
        begin
            step_cnt = i;
            if(i == 34)
            begin
                #2962us
                @(posedge clk);
                wheel_fall = 1;
                @(posedge clk);
                wheel_fall = 0;
            end
            else if( (i == 1) || (i==3) )
            begin
                #1381us
                //#1450us
                @(posedge clk);
                wheel_fall = 1;
                @(posedge clk);
                wheel_fall = 0;
            end
            else if( (i == 2) || (i == 4) )
            begin
                #1451.058us
                //#1450us
                @(posedge clk);
                wheel_fall = 1;
                @(posedge clk);
                wheel_fall = 0;
            end
            else
            begin
                #1481us
                //#1450us
                @(posedge clk);
                wheel_fall = 1;
                @(posedge clk);
                wheel_fall = 0;
            end
        end
    end
endtask

initial
begin
    #3us;
    generate_send();
end

initial
begin
    write_data();
end

initial
begin
    #2.5us;
    motor_signal();
end

logic                       target_valid;
logic   [15:00]             target_pos;
calc_distance_top calc_distance_topEx01
(
    .clk                    (    clk             ),
    .rst_n                  (    rst_n           ),
    .dust_alarm_threshold   (    7650   ),
    .zero_distance_revise   (    20              ),
    .valid_num_threshold    (    5               ),
    .send_en                (    send_en         ),
    .valid_in               (    valid_in        ),
    .distance_in            (    distance_in     ),
    .zero_flag              (    zero_flag       ),
    .wheel_fall             (    wheel_fall      ),
    .step_cnt               (    step_cnt        ),
    .degree_para            (    degree_para     ),
    .target_valid           (    target_valid    ),
    .target_pos             (    target_pos      ),
    .gray_in                (    gray_in         )
);

data_select data_selectEx01
(
    .clk                    (    clk             ),
    .rst_n                  (    rst_n           ),
    .zero_flag              (    zero_flag       ),
    .angle_offset           (    135             ),
    .data_in_valid          (    target_valid    ),
    .data_in                (    target_pos      ),
    .cycle_enable           (                    ),
    .data_out_valid         (                    ),
    .data_out               (                    )
);
endmodule

