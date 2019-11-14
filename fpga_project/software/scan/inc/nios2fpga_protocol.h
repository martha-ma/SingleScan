/*
 * nios2fpga_protocol.h
 *
 *  Created on: 2018-3-28
 *      Author: wj
 */

#ifndef NIOS2FPGA_PROTOCOL_H_
#define NIOS2FPGA_PROTOCOL_H_

#include "bsp.h"
#include "altera_avalon_fifo_util.h"

#define     START_MEASURE               "sMI 3E"
#define     STOP_MEASURE                "sMI 3F"



#define     ENABLE                      0x11111111
#define     DISABLE                     0x22222222

/*
 * enum spectrum {red, orange, yellow}
 * enum spectrum color;
 * if(color == red)
 */
typedef enum __NIOS2FPGA_Command
{
    UPLOAD_EN = 0xb000,

    LASER_ENABLE = 0xa100,
    LASER_FREQ = 0xa101,
    LASER_PULSE_WIDTH = 0xa102,
    LASER_RECV_DELAY = 0xa103,
    LASER_PRESDO = 0xa104,

    MOTOR_ENABLE = 0xa200,
    MOTOR_SPEED = 0xa201,

    ZERO_DISTANCE_REVISE = 0xa301,
    ZERO_ANGLE_REVISE = 0xa302,

    GRAY_DISTANCE_REVISE1 = 0xa401,
    GRAY_DISTANCE_REVISE2 = 0xa402,
    GRAY_DISTANCE_REVISE3 = 0xa403,
    GRAY_DISTANCE_REVISE4 = 0xa404,
    GRAY_DISTANCE_REVISE5 = 0xa405,
    
    NOISE_DIFF_SETTING1 = 0xa501,
    NOISE_DIFF_SETTING2 = 0xa502,

    GRAY_INFLECTION1 = 0xa601,
    GRAY_INFLECTION2 = 0xa602,
    GRAY_INFLECTION3 = 0xa603,
    GRAY_INFLECTION4 = 0xa604,

    SIGNAL_THRESHOLD = 0xa701,
    APD_VOL_SETTING = 0xa702,
    TEMP_VOL_COF1 = 0xa703,
    TEMP_VOL_COF2 = 0xa704,
    TEMP_VOL_INFLECTION = 0xa705,

    TEMP_DISTANCE_COF1 = 0xa706,
    TEMP_DISTANCE_COF2 = 0xa707,
    TEMP_DISTANCE_INFLECTION = 0xa708,

    VALID_NUM_THRESHOLD = 0xa709,
    
    MIN_DISTANCE_VALUE = 0xaa01,
    DUST_ALARM = 0xaa02,
    FIRST_NOISE_FILTER = 0xaa03,

    DUST_ALARM_THRESHOLD = 0xab00,

    DA_CYCLE_PARA1 = 0xac01,
    DA_CYCLE_PARA2 = 0xac02,
    DA_CYCLE_PARA3 = 0xac03,
    DA_CYCLE_PARA4 = 0xac04,
    DA_CYCLE_PARA5 = 0xac05,
    DA_CYCLE_PARA6 = 0xac06,
    DA_CYCLE_PARA7 = 0xac07,
    DA_CYCLE_PARA8 = 0xac08,
    DA_CYCLE_PARA9 = 0xac09,

    WR_REGION0_DATA =0xb100,
    WR_REGION1_DATA =0xb101,
    WR_REGION2_DATA =0xb102,

}NIOS2FPGA_Command_t;

typedef struct __NIOS2FPGA_Pck
{
    NIOS2FPGA_Command_t command;
}NIOS2FPGA_Pck_t;

/*
 * 保存从FPGA部分接收到一圈数据，以及相关操作状态
 */
typedef struct _UpDataFrame
{
    // 从FPGA接收系统状态完成, 可以发送给上位机
    bool pos_finish;
    unsigned int distance_len;
    unsigned int gray_len;
    
    unsigned char distance_data[811*5];		// 存放ascii码格式数据，拼接后传给上位机
    unsigned char gray_data[811*5];		// 存放ascii码格式数据，拼接后传给上位机
}UpDataFrame;

extern UpDataFrame CycleData;
extern NIOS2FPGA_Pck_t Nios2FPGA_pck;

void nios2fpga_packet(unsigned short command, unsigned char len, unsigned int *src);
bool write_data_to_fpga(unsigned int * data, unsigned int len);

/**
 * @brief 将command和data封装好, 发送到FPGA部分
 * Ex. set_laser_paramter(&Nios2FPGA_pck, MOTOR_ENABLE, DISABLE);
 * @param pck 
 * @param command   要发送的命令
 * @param data  要发送的数据
 */
void set_laser_paramter(NIOS2FPGA_Pck_t *pck, unsigned short command, unsigned int data);

/**
 * @brief 系统报警时, 关闭外围设备
 * 
 */
void close_peripheral_dev(void);

/**
 * @brief 上电后, 从E2PROM里读取参数后, 将参数同步设置给FPGA
 * 
 */
void init_fpga_sys(void);


void write_laser_presdo(unsigned char *arr);
#endif /* NIOS2FPGA_PROTOCOL_H_ */
