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
 * @brief 保存系统运行时的状态参数
 * 
 */
typedef struct _sys_para
{
    //update_pos_flag = 1时, 让FPGA上传距离数据
    bool         update_pos_flag;  //  update_pos_flag=1, 需要上传位置数据
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
    unsigned int placeholer1;  // 灰尘报警占位
    unsigned int first_noise_filter;

    unsigned char nios_ver[4];
    unsigned char fpga_ver[4];

    unsigned int temp_volt_cof1;
    unsigned int temp_volt_cof2;
    unsigned int temp_volt_inflection;

    unsigned int temp_distance_cof1;
    unsigned int temp_distance_cof2;
    int          temp_distance_inflection;
    // 零位距离值
    unsigned int zero_value;
    // 系统温度值
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

    unsigned int pc_command_value;  // 接受到上位机的命令个数
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

// 270度测量范围内上传的数据点
#define TARGET_NUMBER 811
#define ZENITH_NUMBER 103

void IINCHIP_CSoff();

void IINCHIP_CSon();

void delay_ms(unsigned int d);  //延时函数(ms)
void delay_us(unsigned int d);

void tim561_run(void);

void test(void);
#endif /* BSP_H_ */
