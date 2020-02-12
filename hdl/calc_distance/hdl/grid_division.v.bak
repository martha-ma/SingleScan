/*=============================================================================
# FileName    :	grid_division.v
# Author      :	author
# Email       :	email@email.com
# Description :	负责将数据按照写入到400mm的栅格中
# Version     :	1.0
# LastChange  :	2019-06-14 14:17:05
# ChangeLog   :	
=============================================================================*/
`timescale  1 ns/1 ps

module grid_division
(
    input                       clk,
    input                       rst_n,

    input                       send_en,
    input                       valid_in,
    input        [15:00]        distance_in,
    input        [07:00]        gray_in,

    input                       zero_flag, 
    input        [07:00]        step_cnt,
    input                       wheel_fall, 
    input        [07:00]        degree_para,   // 0.333°需要采集多少次数据

    output  reg                 tannis_change,
    output  reg                 tannis1_left_wren,
    output  reg                 tannis1_left_rden,
    output      [07:00]         tannis1_left_addr,
    output  reg [47:00]         tannis1_left_wrdata,  // 高8bit表示个数，低24bit表示距离
    input       [47:00]         tannis1_left_rddata,

    output  reg                 tannis2_left_wren,
    output  reg                 tannis2_left_rden,
    output      [07:00]         tannis2_left_addr,
    output  reg [47:00]         tannis2_left_wrdata,
    input       [47:00]         tannis2_left_rddata
);

localparam              MAX_VALUE_ADDR  = 80;
localparam              PHY_ZERO_CNT    = 34;
localparam              END_STEP_CNT    = 43 ; // 最后一个8度数据不写入，后续不好处理
localparam              DEGREE08_NUM    = 24;
localparam              DEGREE16_NUM    = 48;

reg     [07:00]             send_en_cnt;
wire    [08:00]             grid_addr /* synthesis keep */;      // 当前距离数据需要写入到ram那个地址中
reg     [15:00]             grid_gray /* synthesis keep */;
reg     [07:00]             grid_idx /* synthesis keep */;       // 当前栅格内已经写入了几个
reg     [23:00]             grid_value /* synthesis keep */;     // 当前栅格内已经写入的数据和

reg     [07:00]             grid_degree33_cnt;   // 电机单个齿轮内 (8°/16°) 0.333° 计数值
//reg     [15:00]             degree_para_cnt;    // send_en_cnt

mod10 mod10Ex01
(
    .clock       (  clk                     ),
    .denom       (  400                     ),
    .numer       (  {8'd0, distance_in}     ),
    .quotient    (  grid_addr               ),
    .remain      (                          )
);

reg     [31:00]             valid_in_r0;
wire                        div_over = valid_in_r0[11];
always @(posedge clk)
begin
    valid_in_r0[31:00] <= {valid_in_r0[30:00],  valid_in};             // 最先进来的数据在最高位
end

localparam              IDLE            = 0;
localparam              WAIT_DATA       = 1;
localparam              WAIT_GRID       = 2;    // 等待除法器计算出结果
localparam              READ            = 3;    // 从RAM中读取之前的数据, 需要对数据进行处理
localparam              WRITE           = 4;    // 将计算好的数据写回RAM
localparam              DEGREE33_JUDGE  = 5;    // 判断是否计算到 degree_para 次数
localparam              WHELL_JUDGE     = 6;
localparam              WAIT_MOTOR      = 7;    // 如果电机速度变慢，8° 内计算了24个点后还会多余几个点的数据, 等待 8° 结束信号
localparam              OVER            = 8;
(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt, state_cnt_n;

// synthesis translate_off
reg [127:0] cs_STRING;
reg [127:0] TANNIS_CHANGE;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[WAIT_DATA]: cs_STRING = "WAIT_DATA";
        cs[WAIT_GRID]: cs_STRING = "WAIT_GRID";
        cs[READ]: cs_STRING = "READ";
        cs[WRITE]: cs_STRING = "WRITE";
        cs[DEGREE33_JUDGE]: cs_STRING = "DEGREE33_JUDGE";
        cs[WAIT_MOTOR]: cs_STRING = "WAIT_MOTOR";
        cs[OVER]: cs_STRING = "OVER";
        default: cs_STRING = "XXXX";
    endcase

    case(tannis_change)
        1'b0 : TANNIS_CHANGE = "WRITE1_READ2";
        1'b1 : TANNIS_CHANGE = "WRITE2_READ1";
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
* 2. 上流模块输入信号后，计算数据应该划分在那个栅格
* 3. 等待除法器计算结果
* 4. 先从RAM里读取当前数据区间已经写入了几个数字
* 5. 保存更新过后的数字
* 6. 判断已经计算了多少个0.333°，提前结束计算
*/ 
always @(*)
begin
    ns = 'd0;
    case(1'b1)
        cs[IDLE]:
        begin
            if(zero_flag)
                ns[WAIT_DATA] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[WAIT_DATA]:
        begin
            if(valid_in)  // 如果有数据进来，计算数据在那个栅格需要时间
                ns[WAIT_GRID] = 1'b1;
            else
                ns[WAIT_DATA] = 1'b1;
        end
        cs[WAIT_GRID]:
        begin
            if(div_over)
                ns[READ] = 1'b1;
            else
                ns[WAIT_GRID] = 1'b1;
        end
        cs[READ]:
        begin
            if(state_cnt == 3)
                ns[WRITE] = 1'b1;
            else
                ns[READ] = 1'b1;
        end
        cs[WRITE]:
        begin
            ns[DEGREE33_JUDGE] = 1'b1;
        end
        //cs[DEGREE33_JUDGE]:
        //begin
        //    if(wheel_fall)              // 这么短的时间内，恰巧 wheel_fall = 1, 几乎不可能
        //        ns[WAIT_DATA] = 1'b1;
        //    if(grid_degree33_cnt == degree_para)
        //        ns[WHELL_JUDGE] = 1'b1;
        //    else
        //        ns[WAIT_DATA] = 1'b1;
        //end
        cs[DEGREE33_JUDGE]:
        begin
            if(step_cnt >= END_STEP_CNT)   // 最后角度数据不计算
                ns[IDLE] = 1'b1;
            else if(step_cnt == PHY_ZERO_CNT)
            begin
                if(wheel_fall)
                    ns[WAIT_DATA] = 1'b1;
                else if(grid_degree33_cnt >= DEGREE16_NUM)
                    ns[WAIT_MOTOR] = 1'b1;
                else
                    ns[WAIT_DATA] = 1'b1;
            end
            else
            begin
                if(wheel_fall)
                    ns[WAIT_DATA] = 1'b1;
                else if(grid_degree33_cnt >= DEGREE08_NUM)
                    ns[WAIT_MOTOR] = 1'b1;
                else
                    ns[WAIT_DATA] = 1'b1;
            end
        end
        cs[WAIT_MOTOR]:
        begin
            if(wheel_fall)
                ns[WAIT_DATA] = 1'b1;
            else
                ns[WAIT_MOTOR] = 1'b1;
        end
        cs[OVER]:
        begin
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

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        send_en_cnt <= 0;
    else if(zero_flag)
        send_en_cnt <= 0;
    else if(wheel_fall)
        send_en_cnt <= 0;
    else if(send_en_cnt == degree_para) 
        send_en_cnt <= 0;
    else if(cs[WAIT_MOTOR] | cs[IDLE])
        send_en_cnt <= 0;
    else// if((~cs[WAIT_MOTOR]) | (~cs[IDLE]) )
    begin
        if(send_en)
            send_en_cnt <= send_en_cnt + 1'b1;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        grid_degree33_cnt <= 0;
    else if(wheel_fall)
        grid_degree33_cnt <= 0;
    else if(cs[WAIT_MOTOR] | cs[IDLE])
        grid_degree33_cnt <= 0;
    else if(send_en_cnt == degree_para)
        grid_degree33_cnt <= grid_degree33_cnt + 1'b1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis_change <= 0;
    //else if(grid_degree33_cnt[0])
        //tannis_change <= 1;
    //else
        //tannis_change <= 0;
    else if(cs[IDLE])
        tannis_change <= 0;
    else if (send_en_cnt == degree_para)
        tannis_change <= ~tannis_change;
    else if(wheel_fall)
    begin
        if(send_en_cnt == 0)
            tannis_change <= tannis_change;
        else
            tannis_change <= ~tannis_change;
        //if(cs[WAIT_MOTOR])
            //tannis_change <= tannis_change;
        //else if(grid_degree33_cnt == 24)
            //tannis_change <= tannis_change;
        //else
            //tannis_change <= ~tannis_change;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        grid_idx <= 0;
    else
    begin
        if(tannis_change)   // tannis_change = 1时，操作tannis2
        begin
            if(cs[READ] && (state_cnt == 3))
                grid_idx <= tannis2_left_rddata[31:24] + 1;
        end
        else        // tannis_change = 0时，操作tannis1
        begin
            if(cs[READ] && (state_cnt == 3))
                grid_idx <= tannis1_left_rddata[31:24] + 1;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        grid_gray <= 0;
    else
    begin
        if(tannis_change)   // tannis_change = 1时，操作tannis2
        begin
            if(cs[READ] && (state_cnt == 3))
                grid_gray <= tannis2_left_rddata[47:32] + gray_in;
        end
        else        // tannis_change = 0时，操作tannis1
        begin
            if(cs[READ] && (state_cnt == 3))
                grid_gray <= tannis1_left_rddata[47:32] + gray_in;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(~rst_n)
        grid_value <= 0;
    else
    begin
        if(tannis_change)
        begin
            if(cs[READ] && (state_cnt == 3))
                grid_value <= tannis2_left_rddata[23:00]+distance_in;
        end
        else
        begin
            if(cs[READ] && (state_cnt == 3))
                grid_value <= tannis1_left_rddata[23:00]+distance_in;
        end
    end
end

/*
* tannis_change = 0时，操作tannis1
* tannis_change = 1时，操作tannis2
*/
assign                  tannis1_left_addr = (distance_in == 16'hffff) ? MAX_VALUE_ADDR : grid_addr;
//always @ (posedge clk or negedge rst_n)
//begin
    //if(~rst_n)
        //tannis1_left_addr <= 0;
    //else if(distance_in == 16'hffff)
        //tannis1_left_addr <= MAX_VALUE_ADDR;
    //else
    //begin
        //if(div_over)
            //tannis1_left_addr <= grid_addr;
    //end
//end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis1_left_rden <= 0;
    else
        tannis1_left_rden <= ~tannis_change & div_over & (~cs[WAIT_MOTOR]);
end
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis1_left_wren <= 0;
    else
        tannis1_left_wren <= ~tannis_change & cs[WRITE];
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis1_left_wrdata <= 0;
    else if(~tannis_change & cs[WRITE])
        tannis1_left_wrdata <= {grid_gray, grid_idx, grid_value};
end

assign                  tannis2_left_addr = (distance_in == 16'hffff) ? MAX_VALUE_ADDR : grid_addr;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis2_left_rden <= 0;
    else
        tannis2_left_rden <= tannis_change & div_over & (~cs[WAIT_MOTOR]);
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis2_left_wren <= 0;
    else
        tannis2_left_wren <= tannis_change & cs[WRITE];
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        tannis2_left_wrdata <= 0;
    else if(tannis_change & cs[WRITE])
        tannis2_left_wrdata <= {grid_gray, grid_idx, grid_value};
end

endmodule
