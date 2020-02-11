`timescale  1 ns/1 ps

module grid_statistical
(
    input                       clk,
    input                       rst_n,

    input        [07:00]        valid_num_threshold,
    input                       zero_flag,
    input                       wheel_fall,
    input        [07:00]        step_cnt,
    input                       tannis_change,
    output  reg                 tannis1_right_wren,
    output       [47:00]        tannis1_right_wrdata,
    output  reg  [07:00]        tannis1_right_addr,
    output  reg                 tannis1_right_rden,
    input        [47:00]        tannis1_right_rddata,

    output  reg                 tannis2_right_wren,
    output       [47:00]        tannis2_right_wrdata,
    output  reg  [07:00]        tannis2_right_addr,
    output  reg                 tannis2_right_rden,
    input        [47:00]        tannis2_right_rddata,
    input        [07:00]        CORRECT_PULSE_WIDTH,
    output  reg                 target_valid,
    output  reg  [15:00]        target_gray,
    output  reg  [15:00]        target_pos
);

localparam              MAX_VALUE_ADDR  = 80;

reg    [1:0]            tannis_change_r;
wire                    tannis_change_rise;
wire                    tannis_change_fall;

assign          tannis_change_rise = tannis_change_r[1:0] == 2'b01;
assign          tannis_change_fall = tannis_change_r[1:0] == 2'b10;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis_change_r    <= 2'b00;
    else
        tannis_change_r    <= {tannis_change_r[0], tannis_change};
end

reg     [07:00]             cur_range_point_number;         // 所有gird内数据点个数最多的
reg     [07:00]             max_range_point_pos;            // 最多数据点所在grid的位置

reg     [47:00]             before_info;
reg     [47:00]             middle_info;
reg     [47:00]             after_info;

/*
* distance_data[47:32]: 此grid内gray总和
* distance_data[31:24]: 此grid内有几个数据
* distance_data[23:00]: 此grid内距离值总和
*/
wire    [47:00]             distance_data = tannis_change ? tannis1_right_rddata : tannis2_right_rddata;


localparam              IDLE        = 0;
localparam              START1      = 1;
localparam              START2      = 2;
localparam              COUNT       = 3;   // 从RAM里读取数据并统计
localparam              WAIT        = 4;
localparam              RE_READ     = 5;    // 根据统计信息，从新读取相关数据
localparam              RESULT      = 6;
localparam              CLEAR       = 7;    // 计算完成，清空 RAM
localparam              RESET       = 8;    // 计算完成，清空 RAM
localparam              OVER        = 9;
(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt, state_cnt_n;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[START1]: cs_STRING = "START1";
        cs[START2]: cs_STRING = "START2";
        cs[COUNT]: cs_STRING = "COUNT";
        cs[WAIT]: cs_STRING = "WAIT";
        cs[RE_READ]: cs_STRING = "RE_READ";
        cs[RESULT]: cs_STRING = "RESULT";
        cs[CLEAR]: cs_STRING = "CLEAR";
        cs[RESET]: cs_STRING = "RESET";
        cs[OVER]: cs_STRING = "OVER";
        default: cs_STRING = "XXXX";
    endcase

end
// synthesis translate_on

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        cs <= 'd1;
    else
        cs <= ns;
end

/*
* 1. 等待zero_flag启动状态机
* 2. 等待 tannis_change, 开始从 RAM 里读取统计数据
* 3. 边读边找出区间存入数据个数最多的那个
* 4. WAIT 好像没啥用处
* 5. 根据找出的最大值，重新去 RAM 里读取相邻的数据
* 6. 根据算法规则，计算出平均距离
* 7. 将 RAM 数据清零
*/
always @(*)
begin
    ns = 'd0;
    case(1'b1)
        cs[IDLE]:
        begin
            if(zero_flag)
                ns[START1] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[START1]:
        begin
            if(tannis_change_rise | tannis_change_fall)
                ns[COUNT] = 1'b1;
            else
                ns[START1] = 1'b1;
        end
        cs[COUNT]:
        begin
            if(state_cnt == MAX_VALUE_ADDR+2)         // 预留处理数据的空间
                ns[WAIT] = 1'b1;
            else
                ns[COUNT] = 1'b1;
        end
        cs[WAIT]:
        begin
            if(state_cnt == 2)
                ns[RE_READ] = 1'b1;
            else
                ns[WAIT] = 1'b1;
        end
        cs[RE_READ]:
        begin
            if(state_cnt == 2)
                ns[RESULT] = 1'b1;
            else
                ns[RE_READ] = 1'b1;
        end
        cs[RESULT]:
        begin
            if(state_cnt == 2)
                ns[CLEAR] = 1'b1;
            else
                ns[RESULT] = 1'b1;
        end
        cs[CLEAR]:
        begin
            if(state_cnt == MAX_VALUE_ADDR+4)
                ns[RESET] = 1'b1;
            else
                ns[CLEAR] = 1'b1;
        end
        cs[RESET]:
        begin
            ns[START1] = 1'b1;
        end
        cs[OVER]:
        begin
            ns[OVER] = 1'b1;
        end
        default:
            ns[IDLE] = 1'b1;
    endcase
end


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        state_cnt <= 0;
    else
        state_cnt <= state_cnt_n;
end

always @ (*)
begin
    if(~rst_n)
        state_cnt_n <= 0;
    else if (cs != ns)
        state_cnt_n <= 0;
    else
        state_cnt_n <= state_cnt + 1'b1;
end

reg                         ram_data_valid_r0;      // cs[COUNT]延后2个时钟
reg                         ram_data_valid_r1;
reg                         ram_data_valid_r2;
reg     [07:00]             ram_data_cnt;

always @ (posedge clk)
begin
    ram_data_valid_r0 <= cs[COUNT] | cs[RE_READ];
    ram_data_valid_r1 <= ram_data_valid_r0;
    ram_data_valid_r2 <= ram_data_valid_r1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        ram_data_cnt <= 0;
    else if(ram_data_valid_r2)
        ram_data_cnt <= ram_data_cnt + 1'b1;
    else
        ram_data_cnt <= 0;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis1_right_wren <= 0;
    else
    begin
        if(tannis_change)
            tannis1_right_wren <= cs[CLEAR];
        else
            tannis1_right_wren <= 0;
    end
end

assign                  tannis1_right_wrdata = 0;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis1_right_rden <= 0;
    else
    begin
        if(tannis_change)
            tannis1_right_rden <= (cs[COUNT] | cs[RE_READ] | cs[RESET]);
        else
            tannis1_right_rden <= 0;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis1_right_addr <= 0;
    else
    begin
        if(tannis_change)
        begin
            if(cs[COUNT])
                tannis1_right_addr <= state_cnt;
            else if(cs[RE_READ])
                tannis1_right_addr <= max_range_point_pos - 1 + state_cnt;
            else if(cs[CLEAR])
                tannis1_right_addr <= state_cnt;
            else if(cs[RESET])
                tannis1_right_addr <= 0;
        end
        else 
            tannis1_right_addr <= 0;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis2_right_wren <= 0;
    else
    begin
        if(~tannis_change)
            tannis2_right_wren <= cs[CLEAR];
        else
            tannis2_right_wren <= 0;
    end
end

assign                  tannis2_right_wrdata = 0;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis2_right_rden <= 0;
    else
    begin
        if(~tannis_change)
            tannis2_right_rden <= (cs[COUNT] | cs[RE_READ] | cs[RESET]);
        else
            tannis2_right_rden <= 0;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis2_right_addr <= 0;
    else
    begin
        if(~tannis_change)
        begin
            if(cs[COUNT])
                tannis2_right_addr <= state_cnt;
            else if(cs[RE_READ])
                tannis2_right_addr <= max_range_point_pos - 1 + state_cnt;
            else if(cs[CLEAR])
                tannis2_right_addr <= state_cnt;
            else if(cs[RESET])
                tannis2_right_addr <= 0;
        end
        else 
            tannis2_right_addr <= 0;
    end
end


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        cur_range_point_number <= 0;
        max_range_point_pos <= 0;
    end
    else if(cs[CLEAR] & (state_cnt == 20))
    begin
        max_range_point_pos <= 0;
        cur_range_point_number <= 0;
    end
    else if(ram_data_valid_r1)
    begin
        // 遍历所有gird，找出拥有最多数据点个数的grid
        if(distance_data[31:24] > cur_range_point_number)
        begin
            // 在统计最后一个区间数据个数时，如果前面已经有数据个数大
            // 于10的单个区间, 使用这个数据来计算距离
            if( (tannis1_right_addr == MAX_VALUE_ADDR+2) || (tannis2_right_addr == MAX_VALUE_ADDR+2) )   // 得到数据的适合，addr已经变成了65
            begin
                if(cur_range_point_number < valid_num_threshold)
                begin
                    cur_range_point_number <= distance_data[31:24];
                    max_range_point_pos <= ram_data_cnt;
                end
            end
            else
            begin
                cur_range_point_number <= distance_data[31:24];
                max_range_point_pos <= ram_data_cnt;
            end
        end
    end
end


/*
* 以上完成0.33°内所有数据的统计，找出那个0.5m区间内拥有最多的测距数据点位置
* max_range_point_pos+2
*/

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        before_info <= 0;
        middle_info <= 0;
        after_info <= 0;
    end
    else if(cs[START1])
    begin
        before_info <= 0;
        middle_info <= 0;
        after_info <= 0;
    end
    else if(cs[RESULT])
    begin
        if(state_cnt == 0)
            before_info <= distance_data;
        else if(state_cnt == 1)
            middle_info <= distance_data;
        else if(state_cnt == 2)
            after_info <= distance_data;
    end
end

reg     [08:00]             denom;
reg     [23:00]             pos_numer;
reg     [15:00]             gray_numer;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        denom <= 0;
        pos_numer <= 0;
        gray_numer <= 0;
    end
    //else if(cs[RESULT] & ns[CLEAR])
    else if(cs[CLEAR] && (state_cnt == 2) )
    begin
        if( (max_range_point_pos != 00) && (cur_range_point_number >= 20) )
        begin
            // 相邻两个区间数据都不符合要求
            if( ((middle_info[31:24] >> 4) >= before_info[31:24]) && ((middle_info[31:24]>>4) >= after_info[31:24]) )
            begin
                pos_numer <= middle_info[23:00];
                denom <= middle_info[31:24];
				gray_numer <= middle_info[47:32];
            end

            // 前面区间数据符合要求, 后面区间数据不符合要求
            else if( ((middle_info[31:24]>>4) < before_info[31:24]) && ((middle_info[31:24]>>4) >= after_info[31:24]) )
            begin
                pos_numer <= middle_info[23:00] + before_info[23:00];
                denom <= middle_info[31:24] + before_info[31:24];
				gray_numer <= middle_info[47:32]+ before_info[47:32];
            end

            // 后面区间数据符合要求, 前面区间数据不符合要求
            else if( ((middle_info[31:24]>>4) >= before_info[31:24]) && ((middle_info[31:24]>>4) < after_info[31:24]) )
            begin
                pos_numer <= middle_info[23:00] + after_info[23:00];
                denom <= middle_info[31:24] + after_info[31:24];
				gray_numer <= middle_info[47:32]+ after_info[47:32];
            end

            // 前后两个区间都符合要求，选择最接近中间值的那个
            else if( ((middle_info[31:24]>>4) < before_info[31:24]) && ((middle_info[31:24]>>4) < after_info[31:24]) )
            begin
                if(before_info[31:24] > after_info[31:24])
                begin
                    pos_numer <= middle_info[23:00] + before_info[23:00];
                    denom <= middle_info[31:24] + before_info[31:24];
					gray_numer <= middle_info[47:32]+ before_info[47:32];
                end
                else
                begin
                    pos_numer <= middle_info[23:00] + after_info[23:00];
                    denom <= middle_info[31:24] + after_info[31:24];
					gray_numer <= middle_info[47:32]+ after_info[47:32];
                end
            end
        end
    end
end

wire    [15:00]             target_pos_r0/* synthesis keep */;
wire    [15:00]             target_gray_r0/* synthesis keep */;
wire    [15:00]             target_gray_r1;
reg                         target_valid_r0;
reg                         target_valid_r1;
reg                         target_valid_r2;
mod10 mod10Ex01
(
    .clock       (    clk              ),
    .denom       (    denom            ),
    .numer       (    pos_numer        ),
    .quotient    (    target_pos_r0    ),
    .remain      (                     )
);

mod10 mod10Ex02
(
    .clock       (    clk              ),
    .denom       (    denom            ),
    .numer       (    gray_numer*10    ),
    .quotient    (    target_gray_r0   ),
    .remain      (                     )
);

mod10 mod10Ex03
(
    .clock       (    clk              ),
    .denom       (    denom            ),
    .numer       (    gray_numer       ),
    .quotient    (    target_gray_r1   ),
    .remain      (                     )
);
reg     [15:00]             expect_number;
reg     [07:00]             diff_number;
reg                         diff_flag;
reg                         wheel_fall_r0;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        expect_number <= 0;
    else if(zero_flag)
        expect_number <= 0;
    else if(wheel_fall)
    begin
        if(step_cnt == 34)
            expect_number <= expect_number + 48;
        else
            expect_number <= expect_number + 24;
    end

end


reg     [15:00]             real_num;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        real_num <= 0;
    else if(zero_flag)
        real_num <= 0;
    else if(target_valid)
        real_num <= real_num + 1'b1;
end


//assign                  target_valid = (cs[CLEAR] & (state_cnt == 10) );
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
    begin
        diff_number <= 0;
        diff_flag <= 0;
        target_valid <= 0;
        wheel_fall_r0 <= 0;
    end
    else
    begin
        //wheel_fall_r0 <= wheel_fall;
        //if(wheel_fall_r0)
        //begin
            //if(real_num < expect_number)
            //begin
                //diff_number <= expect_number - real_num;
                //diff_flag <= 1;
            //end
        //end

        //if(diff_flag)
        //begin
            //if(diff_number > 1)
            //begin
                //target_valid <= 1;
                //diff_number <= diff_number - 1;
            //end
            //else if(diff_number == 1)
            //begin
                //target_valid <= 1;
                //diff_flag <= 0;
            //end
            //else
                //diff_flag <= 0;
        //end
        //else
        begin
            target_valid_r0 <= (cs[CLEAR] & (state_cnt == 12) );
            target_valid_r1 <= target_valid_r0;
            target_valid_r2 <= target_valid_r1;
            target_valid <= target_valid_r2;
        end
    end
end
always @ (posedge clk)
begin
    if((target_gray_r0>=(CORRECT_PULSE_WIDTH - 3))&&(target_gray_r0 < (CORRECT_PULSE_WIDTH + 3)))
    begin
        target_pos <= target_pos_r0+12;
        target_gray <= target_gray_r1;
    end
    else
    begin
        target_pos <= target_pos_r0;
        target_gray <= target_gray_r1;
	end
end
//always @ (posedge clk)
//begin
//    target_pos <= target_pos_r0;
//    target_gray <= target_gray_r0;
//end

endmodule
