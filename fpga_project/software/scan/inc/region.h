/*
 * region.h
 *
 *  Created on: 2018年10月11日
 *      Author: wangj
 */

#ifndef INC_REGION_H_
#define INC_REGION_H_

#include <stdbool.h>
#include <sys/unistd.h>

#include "bsp.h"
#include "nios2fpga_protocol.h"
#include "iic.h"

#define     CUR_ALARM_GROUP         0x0000
#define     SYS_PARA_ADDR           0x0400

#define     GROUP_OFFSET_ADDR           0x1000
#define     REGION_SPACE_SIZE           0x0800

#define     GROUP0_INNER_START_ADDR     0x1000
#define     GROUP0_MIDDLE_START_ADDR    0x1800
#define     GROUP0_OUTER_START_ADDR     0x2000

#define     GROUP1_INNER_START_ADDR     0x2800
#define     GROUP1_MIDDLE_START_ADDR    0x3000
#define     GROUP1_OUTER_START_ADDR     0x3800

#define     GROUP2_INNER_START_ADDR     0x4000
#define     GROUP2_MIDDLE_START_ADDR    0x4800
#define     GROUP2_OUTER_START_ADDR     0x5000

#define     GROUP3_INNER_START_ADDR     0x5800
#define     GROUP3_MIDDLE_START_ADDR    0x6000
#define     GROUP3_OUTER_START_ADDR     0x6800

#define     GROUP4_INNER_START_ADDR     0x7000
#define     GROUP4_MIDDLE_START_ADDR    0x7800
#define     GROUP4_OUTER_START_ADDR     0x8000

#define     GROUP5_INNER_START_ADDR     0x8800
#define     GROUP5_MIDDLE_START_ADDR    0x9000
#define     GROUP5_OUTER_START_ADDR     0x9800

#define     GROUP6_INNER_START_ADDR     0xa000
#define     GROUP6_MIDDLE_START_ADDR    0xa800
#define     GROUP6_OUTER_START_ADDR     0xb000

#define     GROUP7_INNER_START_ADDR     0xb800
#define     GROUP7_MIDDLE_START_ADDR    0xc000
#define     GROUP7_OUTER_START_ADDR     0xc800

#define     GROUP8_INNER_START_ADDR     0xd000
#define     GROUP8_MIDDLE_START_ADDR    0xd800
#define     GROUP8_OUTER_START_ADDR     0xe000

#define     GROUP9_INNER_START_ADDR     0xe800
#define     GROUP9_MIDDLE_START_ADDR    0xf000
#define     GROUP9_OUTER_START_ADDR     0xf800

#define     GROUP10_INNER_START_ADDR    0x10000
#define     GROUP10_MIDDLE_START_ADDR   0x10800
#define     GROUP10_OUTER_START_ADDR    0x11000

#define     GROUP11_INNER_START_ADDR    0x11800
#define     GROUP11_MIDDLE_START_ADDR   0x12000
#define     GROUP11_OUTER_START_ADDR    0x12800

#define     GROUP12_INNER_START_ADDR    0x13000
#define     GROUP12_MIDDLE_START_ADDR   0x13800
#define     GROUP12_OUTER_START_ADDR    0x14000

#define     GROUP13_INNER_START_ADDR    0x14800
#define     GROUP13_MIDDLE_START_ADDR   0x15000
#define     GROUP13_OUTER_START_ADDR    0x15800

#define     GROUP14_INNER_START_ADDR    0x16000
#define     GROUP14_MIDDLE_START_ADDR   0x16800
#define     GROUP14_OUTER_START_ADDR    0x17000

#define     GROUP15_INNER_START_ADDR    0x17800
#define     GROUP15_MIDDLE_START_ADDR   0x18000
#define     GROUP15_OUTER_START_ADDR    0x18800

typedef struct __region
{
//	unsigned char idx;
	unsigned char last_io_value[2];

    unsigned char change_region_flag;       // 报警区域选择IO口状态发生改变
    unsigned char change_region_value;      // 报警区域选择IO口值
    unsigned char wr_which;                 // 本次接收的区域数据写入到E2PROM那个区域
    unsigned char rd_which;                 // 从E2PROM的那个区域读取报警设置区域
    //unsigned int edge_zenith;    // 报警区域由几个点组成
    unsigned char zenith_save[150];         // 最多存放10个点
    unsigned short int buffer[TARGET_NUMBER];       //  保存下发数据的临时缓冲区
    unsigned int select;                    // E2PROM里会存放好几个报警区域，当前使用那些报警区域

    bool (*init)(struct __region * region);
    bool (*save2rom)(struct __region * region);
    bool (*save2fpga)(struct __region * region, int num);

    /**
     * @brief 从指定region读取num个字节数据
     * 
     */
    bool (*read_from_rom)(struct __region * region, int num);


}region_t;

extern region_t alarm_region;

/**
 * @brief 将系统状态写入到E2PROM里
 * TODO: 何时保存及读取参数
 * @param data 
 */
void save_sys_para(Sys_Para *data);

/**
 * @brief 将E2PROM里保存的系统参数读取出来
 * 
 * @param data 
 */
void read_sys_para(Sys_Para *data);

/**
 * @brief 读取当前报警区域切换IO的值
 * 
 * @return unsigned char 
 */
unsigned char rd_switch_io_value(void);

#endif /* INC_REGION_H_ */
