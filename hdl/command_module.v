
module command_module
(

    input   wire                clk,
    input   wire                clk_125m,
    input   wire                rst_n,
    input   wire                protocol_fifo_out_valid ,
    input   wire [31:00]        protocol_fifo_out_data ,
    output  reg                 protocol_fifo_out_ready ,

    input   wire                valid_region_finish,
    input   wire                region0_rden,
    input   wire [09:00]        region0_rdaddr,
    output  wire [17:00]        region0_rddata,

    input   wire                region1_rden,
    input   wire [09:00]        region1_rdaddr,
    output  wire [17:00]        region1_rddata,

    input   wire                region2_rden,
    input   wire [09:00]        region2_rdaddr,
    output  wire [17:00]        region2_rddata,

    output  reg  [239:00]       laser_presdo,
    output  wire [61:00]        system_para,
    output  wire [89:00]        da_cycle_para,
    output  wire [215:00]       distance_para
);

reg     [15:00]             recv_command;

reg     [15:00]             zero_distance_revise;
reg     [15:00]             zero_angle_revise;
reg     [07:00]             gray_distance_revise1;  // 20
reg     [07:00]             gray_distance_revise2;  // 35
reg     [07:00]             gray_distance_revise3;  // 35
reg     [07:00]             gray_distance_revise4;  // 35
reg     [07:00]             gray_distance_revise5;  // 35
reg     [07:00]             laser_pulse_width;      // 4
reg     [07:00]             laser_recv_delay;      // 4
reg     [07:00]             noise_diff_setting1;     // 200
reg     [07:00]             noise_diff_setting2;     // 200
reg     [09:00]             gray_inflection1;        // 14
reg     [09:00]             gray_inflection2;        // 14
reg     [09:00]             gray_inflection3;        // 14
reg     [09:00]             gray_inflection4;        // 14
reg     [15:00]             apd_volt_setting;       // 0, 设置高压通道; 1, 设置比较器通道
reg     [07:00]             dust_alarm_threshold;
reg     [07:00]             temp_volt_cof1;
reg     [07:00]             temp_volt_cof2;
reg     [07:00]             temp_volt_inflection;

reg     [07:00]             temp_distance_cof1;
reg     [07:00]             temp_distance_cof2;
reg     [07:00]             temp_distance_inflection;
reg     [07:00]             valid_num_threshold;

reg     [07:00]             min_display_distance;
reg     [07:00]             first_noise_filter;

reg     [31:00]             laser_freq;
reg     [07:00]             motor_speed;

reg     [09:00]             da_cycle_para1, da_cycle_para2, da_cycle_para3, da_cycle_para4, da_cycle_para5, da_cycle_para6, da_cycle_para7, da_cycle_para8, da_cycle_para9; 

reg     [01:00]             hw_type;
reg                         laser_enable;
reg                         upload_en;
reg                         motor_enable;
reg                         dac_set_flag;

// 根据协议从上而下依次排列, 207
assign                  distance_para = {
                                    valid_num_threshold,
                                    laser_recv_delay,   // 8bit
                                    zero_distance_revise,   // 16bit
                                    gray_distance_revise1,  // 8bit
                                    gray_distance_revise2,  // 8bit
                                    gray_distance_revise3,  // 8bit
                                    gray_distance_revise4,  // 8bit
                                    gray_distance_revise5,  // 8bit
                                    gray_inflection1,       // 8bit
                                    gray_inflection2,       // 8bit
                                    gray_inflection3,       // 8bit
                                    gray_inflection4,       // 8bit
                                    noise_diff_setting1,    // 8bit
                                    noise_diff_setting2,    // 8bit
                                    apd_volt_setting,       // 16bit
                                    temp_volt_cof1,         // 8bit
                                    temp_volt_cof2,         // 8bit
                                    temp_volt_inflection,   // 8bit
                                    
                                    temp_distance_cof1,     // 8bit
                                    temp_distance_cof2,     // 8bit
                                    temp_distance_inflection,   // 8bit

                                    min_display_distance,     // 8bit   self use
                                    first_noise_filter,      // 8bit
                                    dust_alarm_threshold      // 8bit   小马使用
                            };

// 60bit
assign                  system_para = {
                                    // data[255:192] ，用于保存32bit参数
                                    laser_freq,     // 32bit
                                    motor_speed,    // 16bit
                                    zero_angle_revise,  // 16bit

                                    hw_type,
                                    laser_enable,   // 1bit
                                    upload_en,      // 1bit
                                    motor_enable,   // 1bit
                                    dac_set_flag   // 1bit
                            };

assign                  da_cycle_para = {da_cycle_para9, da_cycle_para8, da_cycle_para7, da_cycle_para6, da_cycle_para5, da_cycle_para4, da_cycle_para3, da_cycle_para2, da_cycle_para1};

localparam              HEAD_CODE = 16'h1234 ;
localparam              ENABLE    = 32'h11111111;
localparam              DISABLE   = 32'h22222222;

localparam              M_SET_HW_TYPE             = 16'h4006;

localparam              M_UPLOAD_EN               = 16'hb000;

localparam              M_LASER_ENABLE            = 16'ha100;
localparam              M_LASER_FREQ              = 16'ha101;
localparam              M_LASER_PULSE_WIDTH       = 16'ha102;
localparam              M_LASER_RECV_DELAY        = 16'ha103;
localparam              M_LASER_PSEUDO            = 16'ha104;


localparam              M_MOTOR_ENABLE            = 16'ha200;
localparam              M_MOTOR_SPEED             = 16'ha201;

localparam              M_ZERO_DISTANCE_REVISE    = 16'ha301;
localparam              M_ZERO_ANGLE_REVISE       = 16'ha302;

localparam              M_GRAY_DISTANCE_REVISE1   = 16'ha401;
localparam              M_GRAY_DISTANCE_REVISE2   = 16'ha402;
localparam              M_GRAY_DISTANCE_REVISE3   = 16'ha403;
localparam              M_GRAY_DISTANCE_REVISE4   = 16'ha404;
localparam              M_GRAY_DISTANCE_REVISE5   = 16'ha405;

localparam              M_NOISE_DIFF_SETTING1     = 16'ha501;
localparam              M_NOISE_DIFF_SETTING2     = 16'ha502;

localparam              M_GRAY_INFLECTION1        = 16'ha601;
localparam              M_GRAY_INFLECTION2        = 16'ha602;
localparam              M_GRAY_INFLECTION3        = 16'ha603;
localparam              M_GRAY_INFLECTION4        = 16'ha604;

localparam              M_SIGNAL_THRESHOLD        = 16'ha701;
localparam              M_APD_VOLT_SETTING        = 16'ha702;
localparam              M_TEMP_VOLT_COF1          = 16'ha703;
localparam              M_TEMP_VOLT_COF2          = 16'ha704;
localparam              M_TEMP_VOLT_INFLECTION    = 16'ha705;

localparam              M_TEMP_DISTANCE_COF1      = 16'ha706;
localparam              M_TEMP_DISTANCE_COF2      = 16'ha707;
localparam              M_TEMP_DISTANCE_INFLECTION= 16'ha708;
localparam              M_VALID_NUM_THRESHOLD     = 16'ha709;

localparam              M_MIN_DISPLAY_DISTANCE    = 16'haa01;
localparam              M_DUST_ALARM              = 16'haa02;
localparam              M_FIRST_NOISE_FILTER      = 16'haa03;

localparam              M_DUST_ALARM_THRESHOLD    = 16'hab00;

localparam              M_DA_CYCLE_SETTING1       = 16'hac01;
localparam              M_DA_CYCLE_SETTING2       = 16'hac02;
localparam              M_DA_CYCLE_SETTING3       = 16'hac03;
localparam              M_DA_CYCLE_SETTING4       = 16'hac04;
localparam              M_DA_CYCLE_SETTING5       = 16'hac05;
localparam              M_DA_CYCLE_SETTING6       = 16'hac06;
localparam              M_DA_CYCLE_SETTING7       = 16'hac07;
localparam              M_DA_CYCLE_SETTING8       = 16'hac08;
localparam              M_DA_CYCLE_SETTING9       = 16'hac09;

localparam              M_WR_REGION0              = 16'hb100;
localparam              M_WR_REGION1              = 16'hb101;
localparam              M_WR_REGION2              = 16'hb102;

localparam              M_REQ_FPGA_STATUS         = 16'hc000;


reg     [15:00]             data_len_reg;
reg     [15:00]             recv_cnt;
localparam              IDLE            = 0;
localparam              HEAD_COMMAND    = 1;
localparam              DATA_LEN        = 2;
localparam              DATA            = 3;
localparam              CHECKSUM        = 4;
localparam              OVER            = 5;

(* KEEP = "TRUE" *)reg     [OVER:00]       cs = 'd1, ns = 'd1;
reg     [15:00]         state_cnt;

// synthesis translate_off
reg [127:0] cs_STRING;
always @(*)
begin
    case(1'b1)
        cs[IDLE]: cs_STRING = "IDLE";
        cs[HEAD_COMMAND]: cs_STRING = "HEAD_COMMAND";
        cs[DATA_LEN]: cs_STRING = "DATA_LEN";
        cs[DATA]: cs_STRING = "DATA";
        cs[CHECKSUM]: cs_STRING = "CHECKSUM";
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

always @(*)
begin
    ns = 'd0;
    case(1'b1)
        cs[IDLE]:
        begin
            if(protocol_fifo_out_valid & protocol_fifo_out_data[31:16] == HEAD_CODE)
                ns[HEAD_COMMAND] = 1'b1;
            else
                ns[IDLE] = 1'b1;
        end
        cs[HEAD_COMMAND]:
        begin
            if(protocol_fifo_out_valid)
                ns[DATA_LEN] = 1'b1;
            else
                ns[HEAD_COMMAND] = 1'b1;
        end
        cs[DATA_LEN]:
        begin
            if(protocol_fifo_out_valid)
                ns[DATA] = 1'b1;
            else
                ns[DATA_LEN] = 1'b1;
        end
        cs[DATA]:
        begin
            if(recv_cnt == data_len_reg+1)
                ns[CHECKSUM] = 1'b1;
            else
                ns[DATA] = 1'b1;
        end
        cs[CHECKSUM]:
        begin
            if(protocol_fifo_out_valid)
                ns[OVER] = 1'b1;
            else
                ns[CHECKSUM] = 1'b1;
        end
        cs[OVER]:
        begin
            ns[IDLE] = 1'b1;
        end
        default:
            ns[IDLE] = 1'b1;
    endcase
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        recv_command <= 0;
    else if(cs[IDLE] & ns[HEAD_COMMAND])
        recv_command <= protocol_fifo_out_data[15:00];
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        data_len_reg <= 0;
    else if(cs[HEAD_COMMAND] & ns[DATA_LEN])
        data_len_reg <= protocol_fifo_out_data[15:00];
    else if(cs[IDLE])
        data_len_reg <= 0;
end

// 生成标志, 拉低tready
wire                        region_flag;
assign                  region_flag = (data_len_reg == 811);
reg    [1:0]            region_flag_r;
wire                    region_flag_rise /* synthesis keep */;
wire                    region_flag_fall;

assign          region_flag_rise = region_flag_r[1:0] == 2'b01;
assign          region_flag_fall = region_flag_r[1:0] == 2'b10;
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        region_flag_r    <= 2'b00;
    else
        region_flag_r    <= {region_flag_r[0], region_flag};
end


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        recv_cnt <= 0;
    else if(cs[IDLE])
        recv_cnt <= 0;
    else if(protocol_fifo_out_ready & protocol_fifo_out_valid)
        recv_cnt <= recv_cnt + 1'b1;
end

/*
* 必须等到一圈比较完成之后,才能将NIOS发送的区域数据加载到RAM里
*/
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        protocol_fifo_out_ready <= 0;
    else
        protocol_fifo_out_ready <= 1;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        motor_enable <= 1;
    else if(ns[DATA] & (recv_command == M_MOTOR_ENABLE))
    begin
        if(protocol_fifo_out_data == ENABLE)
            motor_enable <= 1;
        else
            motor_enable <= 0;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        laser_freq <= 1_000_000;
    else if(ns[DATA] & (recv_command == M_LASER_FREQ))
    begin
        laser_freq <= protocol_fifo_out_data;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        motor_speed <= 15;
    else if(ns[DATA] & (recv_command == M_MOTOR_SPEED))
    begin
        if( (protocol_fifo_out_data >= 8) && (protocol_fifo_out_data <= 15) )
            motor_speed <= protocol_fifo_out_data;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        laser_enable <= 1;
    else if(ns[DATA] & (recv_command == M_LASER_ENABLE))
    begin
        if(protocol_fifo_out_data == ENABLE)
            laser_enable <= 1;
        else
            laser_enable <= 0;
    end
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        upload_en <= 0;
    else if(ns[DATA] & (recv_command == M_UPLOAD_EN))
    begin
        if(protocol_fifo_out_data == ENABLE)
            upload_en <= 1;
        else
            upload_en <= 0;
    end
end
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        state_cnt <= 0;
    else if (cs != ns)
        state_cnt <= 0;
    else
        state_cnt <= state_cnt + 1'b1;
end


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        zero_distance_revise <= 0;
    else if(ns[DATA] & (recv_command == M_ZERO_DISTANCE_REVISE))
        zero_distance_revise <= protocol_fifo_out_data;
end

/*
 * 零位之后的45°不要数据，所有从135(*0.333）个偏移量开始取数据
 */
always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        zero_angle_revise <= 135;
    else if(ns[DATA] & (recv_command == M_ZERO_ANGLE_REVISE))
        zero_angle_revise <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        gray_distance_revise1 <= 144;
    else if(ns[DATA] & (recv_command == M_GRAY_DISTANCE_REVISE1))
        gray_distance_revise1 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        gray_distance_revise2 <= 40;
    else if(ns[DATA] & (recv_command == M_GRAY_DISTANCE_REVISE2))
        gray_distance_revise2 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        gray_distance_revise3 <= 140;
    else if(ns[DATA] & (recv_command == M_GRAY_DISTANCE_REVISE3))
        gray_distance_revise3 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        gray_distance_revise4 <= 140;
    else if(ns[DATA] & (recv_command == M_GRAY_DISTANCE_REVISE4))
        gray_distance_revise4 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        gray_distance_revise5 <= 140;
    else if(ns[DATA] & (recv_command == M_GRAY_DISTANCE_REVISE5))
        gray_distance_revise5 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        laser_pulse_width <= 7;
    else if(ns[DATA] & (recv_command == M_LASER_PULSE_WIDTH))
        laser_pulse_width <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        laser_recv_delay <= 0;
    else if(ns[DATA] & (recv_command == M_LASER_RECV_DELAY))
        laser_recv_delay <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        noise_diff_setting1 <= 180;
    else if(ns[DATA] & (recv_command == M_NOISE_DIFF_SETTING1))
        noise_diff_setting1 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        noise_diff_setting2 <= 180;
    else if(ns[DATA] & (recv_command == M_NOISE_DIFF_SETTING2))
        noise_diff_setting2 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        apd_volt_setting <= 16'd548;
    else if(ns[DATA] & (recv_command == M_APD_VOLT_SETTING))
        apd_volt_setting <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        dac_set_flag <= 0;
    else if(ns[DATA] & (recv_command == M_APD_VOLT_SETTING) )
        dac_set_flag <= 1;
    else
        dac_set_flag <= 0;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        temp_volt_cof1 <= 38;
    else if(ns[DATA] & (recv_command == M_TEMP_VOLT_COF1))
        temp_volt_cof1 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        temp_volt_cof2 <= 38;
    else if(ns[DATA] & (recv_command == M_TEMP_VOLT_COF2))
        temp_volt_cof2 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        temp_volt_inflection <= 25;
    else if(ns[DATA] & (recv_command == M_TEMP_VOLT_INFLECTION))
        temp_volt_inflection <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        temp_distance_cof1 <= 4;
    else if(ns[DATA] & (recv_command == M_TEMP_DISTANCE_COF1))
        temp_distance_cof1 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        temp_distance_cof2 <= 4;
    else if(ns[DATA] & (recv_command == M_TEMP_DISTANCE_COF2))
        temp_distance_cof2 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        temp_distance_inflection <= 25;
    else if(ns[DATA] & (recv_command == M_TEMP_DISTANCE_INFLECTION))
        temp_distance_inflection <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        valid_num_threshold <= 8;
    else if(ns[DATA] & (recv_command == M_VALID_NUM_THRESHOLD))
        valid_num_threshold <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        gray_inflection1 <= 30;
    else if(ns[DATA] & (recv_command == M_GRAY_INFLECTION1))
        gray_inflection1 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        gray_inflection2 <= 30;
    else if(ns[DATA] & (recv_command == M_GRAY_INFLECTION2))
        gray_inflection2 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        gray_inflection3 <= 120;
    else if(ns[DATA] & (recv_command == M_GRAY_INFLECTION3))
        gray_inflection3 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        gray_inflection4 <= 220;
    else if(ns[DATA] & (recv_command == M_GRAY_INFLECTION4))
        gray_inflection4 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        min_display_distance <= 50;
    else if(ns[DATA] & (recv_command == M_MIN_DISPLAY_DISTANCE))
        min_display_distance <= protocol_fifo_out_data;
end


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        first_noise_filter <= 3;
    else if(ns[DATA] & (recv_command == M_FIRST_NOISE_FILTER))
        first_noise_filter <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        dust_alarm_threshold <= 35;
    else if(ns[DATA] & (recv_command == M_DUST_ALARM_THRESHOLD))
        dust_alarm_threshold <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        da_cycle_para1 <= 133;
    else if(ns[DATA] & (recv_command == M_DA_CYCLE_SETTING1))
        da_cycle_para1 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        da_cycle_para2 <= 152;
    else if(ns[DATA] & (recv_command == M_DA_CYCLE_SETTING2))
        da_cycle_para2 <= protocol_fifo_out_data;
end


always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        da_cycle_para3 <= 172;
    else if(ns[DATA] & (recv_command == M_DA_CYCLE_SETTING3))
        da_cycle_para3 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        da_cycle_para4 <= 191;
    else if(ns[DATA] & (recv_command == M_DA_CYCLE_SETTING4))
        da_cycle_para4 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        da_cycle_para5 <= 200;
    else if(ns[DATA] & (recv_command == M_DA_CYCLE_SETTING5))
        da_cycle_para5 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        da_cycle_para6 <= 181;
    else if(ns[DATA] & (recv_command == M_DA_CYCLE_SETTING6))
        da_cycle_para6 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        da_cycle_para7 <= 162;
    else if(ns[DATA] & (recv_command == M_DA_CYCLE_SETTING7))
        da_cycle_para7 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        da_cycle_para8 <= 143;
    else if(ns[DATA] & (recv_command == M_DA_CYCLE_SETTING8))
        da_cycle_para8 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        da_cycle_para9 <= 123;
    else if(ns[DATA] & (recv_command == M_DA_CYCLE_SETTING9))
        da_cycle_para9 <= protocol_fifo_out_data;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        hw_type <= 1;
    else if(ns[DATA] & (recv_command == M_SET_HW_TYPE))
        hw_type <= protocol_fifo_out_data[1:0];
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        laser_presdo <= 0;
    else if(ns[DATA] & (recv_command == M_LASER_PSEUDO))
    begin
        if(protocol_fifo_out_valid)
            laser_presdo[239:000] <= {laser_presdo[207:000], protocol_fifo_out_data};             // 最先进来的数据在最高位
    end
end

reg                         region0_wren;
reg     [17:00]             region0_wrdata;
wire    [09:00]             region0_wraddr;

reg                         region1_wren;
reg     [17:00]             region1_wrdata;
wire    [09:00]             region1_wraddr;

reg                         region2_wren;
reg     [17:00]             region2_wrdata;
wire    [09:00]             region2_wraddr;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        region0_wren <= 0;
    else if(ns[DATA] & (recv_command == M_WR_REGION0))
        region0_wren <= protocol_fifo_out_ready & protocol_fifo_out_valid;
    else
        region0_wren <= 0;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        region0_wrdata <= 0;
    else if(ns[DATA] & (recv_command == M_WR_REGION0))
        region0_wrdata <= protocol_fifo_out_data;
    else
        region0_wrdata <= 0;
end
assign                  region0_wraddr = recv_cnt - 2;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        region1_wren <= 0;
    else if(ns[DATA] & (recv_command == M_WR_REGION1))
        region1_wren <= protocol_fifo_out_ready & protocol_fifo_out_valid;
    else
        region1_wren <= 0;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        region1_wrdata <= 0;
    else if(ns[DATA] & (recv_command == M_WR_REGION1))
        region1_wrdata <= protocol_fifo_out_data;
    else
        region1_wrdata <= 0;
end
assign                  region1_wraddr = recv_cnt - 2;

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        region2_wren <= 0;
    else if(ns[DATA] & (recv_command == M_WR_REGION2))
        region2_wren <= protocol_fifo_out_ready & protocol_fifo_out_valid;
    else
        region2_wren <= 0;
end

always @ (posedge clk or negedge rst_n)
begin
    if(~rst_n)
        region2_wrdata <= 0;
    else if(ns[DATA] & (recv_command == M_WR_REGION2))
        region2_wrdata <= protocol_fifo_out_data;
    else
        region2_wrdata <= 0;
end
assign                  region2_wraddr = recv_cnt - 2;

ram_1024x18bit region_Ex01
(
    .wrclock      (    clk               ),
    .wren         (    region0_wren      ),
    .wraddress    (    region0_wraddr    ),
    .data         (    region0_wrdata    ),

    .rdclock      (    clk_125m          ),
    .rden         (    region0_rden      ),
    .rdaddress    (    region0_rdaddr    ),
    .q            (    region0_rddata    )
);

ram_1024x18bit region_Ex02
(
    .wrclock      (    clk               ),
    .wren         (    region1_wren      ),
    .wraddress    (    region1_wraddr    ),
    .data         (    region1_wrdata    ),

    .rdclock      (    clk_125m          ),
    .rden         (    region1_rden      ),
    .rdaddress    (    region1_rdaddr    ),
    .q            (    region1_rddata    )
);

ram_1024x18bit region_Ex03
(
    .wrclock      (    clk               ),
    .wren         (    region2_wren      ),
    .wraddress    (    region2_wraddr    ),
    .data         (    region2_wrdata    ),

    .rdclock      (    clk_125m          ),
    .rden         (    region2_rden      ),
    .rdaddress    (    region2_rdaddr    ),
    .q            (    region2_rddata    )
);
endmodule
