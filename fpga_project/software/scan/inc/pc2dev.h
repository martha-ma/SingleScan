/*
 * communicate_pc.h
 *
 *  Created on: 2018-3-28
 *      Author: wj
 */

#ifndef COMMUNICATE_PC_H_
#define COMMUNICATE_PC_H_

#include <sys/unistd.h>
#include "bsp.h"
#include "w5500.h"
#include "tim561.h"
#include "nios2fpga_protocol.h"
#include "socket.h"
#include "iic.h"

#include "remote_update.h"

#define PC_SET_ALARM_REGION 0x4001
#define PC_READ_ALARM_REGION 0x4002
#define PC_LOAD_REGION_DATA 0x4003
#define PC_REQ_REGION_DATA 0x4004
#define PC_REQ_RADAR_PARA 0x4005
#define PC_SET_HW_TYPE 0x4006
#define PC_SAVA_SYS_PARA 0x4007
#define PC_RESET_NIOS 0x4008
#define PC_SET_SN 0x4009
#define PC_SET_DEV_TYPE 0x4010
#define PC_SET_DUST_THRESHOLD 0x4011

#define NIOS_UP_RESPONSE_PC 0x5000
#define NIOS_UP_ALARM_REGION 0x5001
#define NIOS_UP_REGION_DATA 0x5002
#define NIOS_UP_RADAR_PARA 0x5005

// w5500发送缓冲区, 给w5500的数据封装到此处
extern unsigned char send_buffer[];

typedef struct __pc2nios
{
    unsigned int head;
    unsigned int command;
    unsigned int data_len;
    unsigned int checksum;  // 异或校验
    // void (*function)(struct __pc2nios var);   // 结构体的相关操作可以使用函数指针封装到这里
} pc2nios_t;
extern pc2nios_t pc2nios;

/**
 * @brief 0x1234,   0x5001,     0x00000004,    0x1234abcd,  0xchecksum
 *
 */
typedef struct __nios2pc
{
    unsigned int head;
    unsigned int command;
    unsigned int data_len;  // 单位：字节
    unsigned int value;
    // data
    unsigned int checksum;  // 异或校验
} nios2pc_t;
extern nios2pc_t nios2pc;

/**
 * @brief 处理sick协议流程
 *
 * @param s
 * @param buf
 * @param len
 */
void pc2dev_parse(SOCKET s, unsigned char *buf, int len);
int  hex2string(unsigned short num, char *str);

int pc2dev_packet(struct __nios2pc *data, unsigned char *buf);
#endif /* COMMUNICATE_PC_H_ */
