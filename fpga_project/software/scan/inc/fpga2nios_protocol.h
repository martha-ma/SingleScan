/*
 * fpga2nios_protocol.h
 *
 *  Created on: 2018-3-27
 *      Author: wj
 */
#ifndef FPGA2NIOS_PROTOCOL_H_
#define FPGA2NIOS_PROTOCOL_H_

#include "system.h"
#include "altera_avalon_fifo_util.h"

#include "bsp.h"
#include "pc2dev.h"
typedef struct __fpga_data_packet
{
    unsigned short frame_head;
    unsigned short command;
    unsigned int data_len;
    unsigned int data[20];
    unsigned int checksum;
}Fpga_data_packet;


// 绿灯, 电源灯: 上电, 常亮, 开始测量, 1Hz慢闪
// 红灯, 状态灯: 正常工作红灯不量, 低转速/LD出光 报警, 红灯常亮; 窗口灰尘报警 1Hz; 温度过高报警 5Hz
typedef struct __sys_warn
{
    unsigned int motor_low_speed_alarm;
    unsigned int ld_not_work_alarm;
    unsigned int window_dust_alarm;
    unsigned int temp_out_alarm;

    // 区域报警信息
    unsigned int region_alarm;
    
    unsigned int len;
    // motor单圈计数值, 连续5次检测
    unsigned int motor_cycle_cnt[5];
    // 零位距离值
    unsigned int zero_value[5];
    // 窗口灰尘计数器
    unsigned int dust_cnt[5];
    // 存储温度值, bit13 = 1, 温度为负值.
    unsigned int temp_value[5];
}Sys_warn;

extern Sys_warn sys_warn;

extern queue_item_t LaserData[];
extern Queue LaserDataQueue;

#define FRAME_HEAD              0x1234

#define DISTANCE_DATA           0xa003
#define UP_FPGA_STATUS          0xc100
#define UP_ALARM_REGION_STATUS  0xc101
#define UP_ALARM_IO_VALUE       0xc102
#define LASER_STATUS            0xa004
#define INSTRUCTION_CNT         0xa002

bool fpga_is_has_data();
unsigned int read_fpga_data();

/**
 * @brief 处理FPGA发送的数据.(目标距离 和 部分系统状态)
 * 将目标距离数据存放到CycleData.ascii_data里
 * 系统状态存放到sys_warn里
 * @return int 
 */
int fpga2nios_parse();

void process_motor_waring(Sys_warn *data);
void process_ld_waring(Sys_warn *data);
void process_window_dust_waring(Sys_warn *data);
void process_sys_temp_waring(Sys_warn *data);
#endif /* FPGA2NIOS_PROTOCOL_H_ */

