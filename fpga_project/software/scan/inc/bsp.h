/*
 * bsp.h
 *
 *  Created on: 2018-3-27
 *      Author: wj
 */

#ifndef BSP_H_
#define BSP_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "alt_types.h"
#include "system.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"

#include "scan_config.h"
#include "queue.h"
#include "types.h"

#include "w5500.h"
#include "fpga2nios_protocol.h"
#include "nios2fpga_protocol.h"
#include "socket.h"
#include "device.h"

//#define SIM_DATA_TEST
extern uint8 buffer[];
/**
 * @brief 淇濆瓨绯荤粺杩愯鏃剁殑鐘舵�佸弬鏁�
 * 
 */
typedef struct _sys_para
{
    //update_pos_flag = 1鏃�, 璁〧PGA涓婁紶璺濈鏁版嵁
    bool         update_pos_flag;  //  update_pos_flag=1, 闇�瑕佷笂浼犱綅缃暟鎹�
    unsigned int laser_enable;
    unsigned int laser_freq;
    unsigned int laser_recv_delay;
    unsigned int motor_enable;
    unsigned int motor_expect_speed;
    unsigned int zero_distance_revise;
    unsigned int zero_angle_revise;
    unsigned int gray_distance_revise1;
    unsigned int gray_distance_revise2;
    unsigned int gray_distance_revise3;
    unsigned int laser_pulse_width;
    unsigned int signal_thresold;
    unsigned int noise_diff_setting1;
    unsigned int noise_diff_setting2;
    unsigned int apd_vol_base;
    unsigned int gray_inflection1;
    unsigned int gray_inflection2;
    unsigned int min_display_distance;
    unsigned int placeholer1;  // 鐏板皹鎶ヨ鍗犱綅
    unsigned int first_noise_filter;

    unsigned char nios_ver[4];
    unsigned char fpga_ver[4];

    unsigned int temp_volt_cof1;
    unsigned int temp_volt_cof2;
    unsigned int temp_volt_inflection;

    unsigned int temp_distance_cof1;
    unsigned int temp_distance_cof2;
    int          temp_distance_inflection;
    // 闆朵綅璺濈鍊�
    unsigned int zero_value;
    // 绯荤粺娓╁害鍊�
    unsigned int sys_temp;
    unsigned int max_pwm_duty;
    unsigned int min_pwm_duty;
    unsigned int motor_real_speed;
    unsigned int dust_alarm_threshold;

    unsigned int da_cycle_para1;
    unsigned int da_cycle_para2;
    unsigned int da_cycle_para3;
    unsigned int da_cycle_para4;
    unsigned int da_cycle_para5;
    unsigned int da_cycle_para6;
    unsigned int da_cycle_para7;
    unsigned int da_cycle_para8;
    unsigned int da_cycle_para9;

    unsigned int board_type;
    unsigned int zero_pulse_width;

    unsigned char dev_type[20];
    unsigned char dev_pn[20];
    unsigned char dev_sn[16];
    unsigned char laser_presdo[30];
    unsigned char xxx1;
    unsigned char xxx2;
    unsigned int  valid_num_threshold;
    unsigned int  gray_inflection3;
    unsigned int  gray_inflection4;
    unsigned int  gray_distance_revise4;
    unsigned int  gray_distance_revise5;
    unsigned int  dust_threshold;
    unsigned int  min_target_size;
    unsigned int  alarm_output_threshold;

    unsigned int pc_command_value;  // 鎺ュ彈鍒颁笂浣嶆満鐨勫懡浠や釜鏁�
} Sys_Para;

typedef struct _sys_status
{
    unsigned int reset_nios;
} Sys_Status;

extern Sys_Para      SysPara;
extern Sys_Status    SysStatus;
extern unsigned char isTcpEstablished;
extern unsigned char isPowerUp;

#define USE_SOPAS 1

#define ANGLE_RESOLUTION 0.333 * 3600
#define START_ANGLE 45 * 3600
#define VALID_ANGLE_RANGE 0.0165 * 3600
#define TARGET_THRESHOLD 100

// 270搴︽祴閲忚寖鍥村唴涓婁紶鐨勬暟鎹偣
#define TARGET_NUMBER 811
#define ZENITH_NUMBER 103

void IINCHIP_CSoff();

void IINCHIP_CSon();

void delay_ms(unsigned int d);  //寤舵椂鍑芥暟(ms)
void delay_us(unsigned int d);

void tim561_run(void);

void test(void);
#endif /* BSP_H_ */
