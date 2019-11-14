/*
 * region.c
 *
 *  Created on: 2018年10月11日
 *      Author: wangj
 */

#include "region.h"

/**
 * @brief
 * 将已经保存到数组的数据保存到e2prom里
 * 对于报警区域来说，如果270°范围内的某些角度没有边界，则其数据为FF
 * @param region
 * @return true
 * @return false
 */
bool save2rom(struct __region *region)
{
    unsigned int offset_addr;

    iic.write_byte(3, (unsigned char)region->select);  //
    delay_us(10000);

    offset_addr = GROUP_OFFSET_ADDR + REGION_SPACE_SIZE * region->wr_which;
    iic.write_page(offset_addr, (alt_u8 *)region->buffer, TARGET_NUMBER * 2);
    offset_addr += TARGET_NUMBER * 2;
    iic.write_page(offset_addr, (alt_u8 *)region->zenith_save, ZENITH_NUMBER);

    return true;
}

/**
 * @brief 将从E2PROM的读出来(上位机刚刚设置的)区域边界数据通过FIFO接口,写入到FPGA里面
 *
 * @param region
 * @param num 0,内层; 1, 中间层; 2:外层
 * @return true
 * @return false
 */
bool save2fpga(struct __region *region, int num)
{
    int          i;
    unsigned int data;
    if(num == 0)
        data = 0x12340000 + WR_REGION0_DATA;
    else if(num == 1)
        data = 0x12340000 + WR_REGION1_DATA;
    else if(num == 2)
        data = 0x12340000 + WR_REGION2_DATA;

    altera_avalon_fifo_write_fifo(PROTOCOL_FIFO_IN_BASE, PROTOCOL_FIFO_IN_CSR_BASE, (data >> 16) + (data << 16));
    data = 811;
    altera_avalon_fifo_write_fifo(PROTOCOL_FIFO_IN_BASE, PROTOCOL_FIFO_IN_CSR_BASE, (data >> 16) + (data << 16));

    //    data = 0x1000;
    for(i = 0; i < 811; i++)
    {
        data = region->buffer[i];
        altera_avalon_fifo_write_fifo(PROTOCOL_FIFO_IN_BASE, PROTOCOL_FIFO_IN_CSR_BASE, (data >> 16) + (data << 16));
    }
    data = 0xccccdddd;
    altera_avalon_fifo_write_fifo(PROTOCOL_FIFO_IN_BASE, PROTOCOL_FIFO_IN_CSR_BASE, (data >> 16) + (data << 16));
    return true;
}

/**
 * @brief 从e2prom里读取设置区域数据,存放buffer里,然后写入FPGA
 *
 * @param region
 * @param num e2prom内存空间编号. 0, 3内存; 1,4,中间层; 2,5 外层
 * @return true
 * @return false
 */
bool read_from_rom(struct __region *region, int num)
{
    unsigned int offset_addr;

    offset_addr = GROUP_OFFSET_ADDR + num * REGION_SPACE_SIZE;
    iic_sequential_read(offset_addr, (alt_u8 *)region->buffer, TARGET_NUMBER * 2);
    alarm_region.save2fpga(&alarm_region, num % 3);

    return true;
}

/**
 * @brief 将SysStatus里的系统运行参数保存到Flash里, 小端模式写入
 * TODO: 解决参数区域内容被意外擦除
 * @param data
 */
void save_sys_para(Sys_Para *data)
{
    unsigned char buf[384];
    memset(buf, 0, sizeof(buf));
    memcpy(buf, (unsigned char *)data, sizeof(Sys_Para));
    iic.write_page(SYS_PARA_ADDR, buf, sizeof(Sys_Para));
}

/**
 * @brief 如果Flash为空，则版本号为0.01。保存参数重新上电后，版本号正常
 *
 * @param status
 */
void read_sys_para(Sys_Para *status)
{
    unsigned int  num = 5;
    unsigned char buf[384];

    while(num--)
    {
        iic_sequential_read(SYS_PARA_ADDR, buf, sizeof(Sys_Para));
        status->dust_threshold = 400;
        // 简单判断从eeprom读出来的数据是否正确
        if(((buf[4] == 0x11) && (buf[5] == 0x11) && (buf[6] == 0x11) && (buf[7] == 0x11)) ||
           ((buf[4] == 0x22) && (buf[5] == 0x22) && (buf[6] == 0x22) && (buf[7] == 0x22)))
        {
            memcpy(status, buf, sizeof(Sys_Para));

            // 标识位即时写入E2PROM, 如果此时系统断电, 重新上电后系统状态会出错
            status->update_pos_flag = true;
            status->motor_enable    = ENABLE;
            status->laser_enable    = ENABLE;
            status->max_pwm_duty    = 10;
            status->dust_threshold = 400;
            memcpy(status->nios_ver, NIOS_VERSION, 4);
            memcpy(status->fpga_ver, FPGA_VERSION, 4);
            memcpy(status->dev_pn, DEV_PN_NUM, 20);

            return;
        }
    }
}

unsigned char rd_switch_io_value(void)
{
    unsigned char data;
    data = IORD_ALTERA_AVALON_PIO_DATA(ALARM_SELECT_BASE);
    data = (~data) & 0x0f;
    return data;
}

region_t alarm_region = {
    .select        = 0x07,
    .save2rom      = save2rom,
    .save2fpga     = save2fpga,
    .read_from_rom = read_from_rom};

