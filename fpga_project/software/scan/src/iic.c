/*
 * iic.c
 *
 *  Created on: 2018年10月16日
 *      Author: wangj
 */

#include <stdio.h>
#include <sys/unistd.h>

#include <io.h>
#include "iic.h"
#include "alt_types.h"
#include "altera_avalon_pio_regs.h"
#include "system.h"

#include "bsp.h"

/*
 * === FUNCTION ===================================================
 * Name: start
 * Description: IIC启动
 * =================================================================
 */
static void start(void)
{
    IOWR_ALTERA_AVALON_PIO_DIRECTION(SDA_BASE, OUT);
    IOWR_ALTERA_AVALON_PIO_DATA(SDA_BASE, 1);
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 1);
    delay_us(2);
    IOWR_ALTERA_AVALON_PIO_DATA(SDA_BASE, 0);
    delay_us(1);
}
/*
 * === FUNCTION ===================================================
 * Name: uart_send_byte
 * Description: IIC停止
 * ==================================================================
 */
static void stop(void)
{
    IOWR_ALTERA_AVALON_PIO_DIRECTION(SDA_BASE, OUT);
    IOWR_ALTERA_AVALON_PIO_DATA(SDA_BASE, 0);
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 0);
    delay_us(2);
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 1);
    delay_us(1);
    IOWR_ALTERA_AVALON_PIO_DATA(SDA_BASE, 1);
    delay_us(2);
}
/*
 * === FUNCTION ===================================================
 * Name: ack
 * Description: IIC应答
 * =================================================================
 */
static void wait_slave_ack(void)
{
    alt_u8 tmp;
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 0);
    IOWR_ALTERA_AVALON_PIO_DIRECTION(SDA_BASE, IN);

    delay_us(2);
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 1);
    delay_us(1);
    tmp = IORD_ALTERA_AVALON_PIO_DATA(SDA_BASE);

    delay_us(1);
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 0);
    delay_us(2);
    if(tmp == 1)  // 不正确应答
        stop();
}

/**
 * @brief 主机发送一个低电平的应答信号, 继续读取数据
 * 
 */
static void master_send_ack(void)
{
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 0);
    IOWR_ALTERA_AVALON_PIO_DIRECTION(SDA_BASE, OUT);

    delay_us(2);
    IOWR_ALTERA_AVALON_PIO_DATA(SDA_BASE, 0);
    delay_us(1);
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 1);
    delay_us(1);
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 0);
    delay_us(2);
}

/**
 * @brief 
 * 
 */
static void no_ack(void)
{
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 0);
    IOWR_ALTERA_AVALON_PIO_DIRECTION(SDA_BASE, OUT);
    delay_us(2);
    IOWR_ALTERA_AVALON_PIO_DATA(SDA_BASE, 1);
    delay_us(1);
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 1);
    delay_us(1);
    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 0);
    delay_us(2);
}

/*
 * === FUNCTION ===================================================
 * Name: iic_write
 * Description: IIC写一个字节
 * =================================================================
 */
void iic_write(alt_u8 dat)
{
    alt_u8 i, tmp;
    IOWR_ALTERA_AVALON_PIO_DIRECTION(SDA_BASE, OUT);
    for(i = 0; i < 8; i++)
    {
        IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 0);
        delay_us(2);
        tmp = (dat & 0x80) ? 1 : 0;
        dat <<= 1;
        IOWR_ALTERA_AVALON_PIO_DATA(SDA_BASE, tmp);
        delay_us(1);
        IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 1);
        delay_us(2);
    }
}
/*
 * === FUNCTION ===================================================
 * Name: read
 * Description: IIC读一个字节
 * ==================================================================
 */
static alt_u8 iic_read(void)
{
    alt_u8 i, dat = 0;
    IOWR_ALTERA_AVALON_PIO_DIRECTION(SDA_BASE, IN);
    for(i = 0; i < 8; i++)
    {
        IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 0);
        delay_us(2);
        IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 1);
        delay_us(1);
        dat <<= 1;
        dat |= IORD_ALTERA_AVALON_PIO_DATA(SDA_BASE);
        delay_us(1);
    }
    delay_us(1);
    //    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 0);
    //    delay_us(1);
    //    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 1);
    //    delay_us(1);
    //    IOWR_ALTERA_AVALON_PIO_DATA(SCL_BASE, 0);
    return dat;
}

/**
 * @brief 向EEPROM写一个字节. 注意E2PROM的固有写入时间
 * @param addr
 * @param dat
 */
void eeprom_write_byte(alt_u32 addr, alt_u8 dat)
{
    alt_u8 cmd;
    cmd = 0xa0 | ((addr >> 15) & 0x02);
    start();
    iic_write(cmd);
    wait_slave_ack();
    iic_write((addr >> 8) & 0xff);
    wait_slave_ack();
    iic_write((addr >> 0) & 0xff);
    wait_slave_ack();
    iic_write(dat);
    wait_slave_ack();
    stop();
    delay_us(2500);
}

/**
 * @brief 通过 page write 模式,连续写入任意长度数据
 *
 * @param addr, 要写入E2PROM的起始地址
 * @param dat, 地址指针
 * @param len, 写入数据长度
 */
void eeprom_write_page(alt_u32 addr, alt_u8 *dat, alt_u16 len)
{
    alt_u8  cmd;
    alt_u16 i, j;
    alt_u8  number, remain;
    alt_32  i2c_addr;

    // 最高位地址放到bit6上
    cmd = 0xa0 | ((addr >> 15) & 0x02);

    number = len / EEPROM_PAGE_SIZE;
    remain = len % EEPROM_PAGE_SIZE;

    for(i = 0; i < number; i++)
    {
        i2c_addr = addr + i * EEPROM_PAGE_SIZE;
        start();
        iic_write(cmd);
        wait_slave_ack();
        iic_write((i2c_addr >> 8) & 0xff);
        wait_slave_ack();
        iic_write((i2c_addr >> 0) & 0xff);
        wait_slave_ack();
        for(j = 0; j < EEPROM_PAGE_SIZE; j++)
        {
            iic_write(dat[i * EEPROM_PAGE_SIZE + j]);
            wait_slave_ack();
        }
        stop();
        delay_us(10000);
        //        usleep(5000);
    }
    if(remain != 0)
    {
        i2c_addr = addr + number * EEPROM_PAGE_SIZE;
        start();
        iic_write(cmd);
        wait_slave_ack();
        iic_write((i2c_addr >> 8) & 0xff);
        wait_slave_ack();
        iic_write((i2c_addr >> 0) & 0xff);
        wait_slave_ack();
        for(j = 0; j < remain; j++)
        {
            iic_write(dat[number * EEPROM_PAGE_SIZE + j]);
            wait_slave_ack();
        }
        stop();
        delay_us(10000);
        //        usleep(5000);
    }
}
/*
 * === FUNCTION ===================================================
 * Name: read_byte
 * Description: 从EEPROM读一个字节
 * =================================================================
 */
alt_u8 eeprom_read_byte(alt_u32 addr)
{
    alt_u8 cmd, dat;

    if(addr > AT24C1024_MAX_ADDR)
        return 0xff;

    cmd = 0xa0 | ((addr >> 15) & 0x02);
    start();
    iic_write(cmd);
    wait_slave_ack();
    iic_write((addr >> 8) & 0xff);
    wait_slave_ack();
    iic_write((addr >> 0) & 0xff);
    wait_slave_ack();
    cmd |= 0x01;
    start();
    iic_write(cmd);
    wait_slave_ack();
    dat = iic_read();
    no_ack();
    stop();
    return dat;
}

void eeprom_sequential_read(alt_u32 addr, alt_u8 *dat, alt_u16 len)
{
    alt_u16 i;
    alt_u8  cmd;
    if(addr > AT24C1024_MAX_ADDR)
        return;
    cmd = 0xa0 | ((addr >> 15) & 0x02);
    start();
    iic_write(cmd);
    wait_slave_ack();
    iic_write((addr >> 8) & 0xff);
    wait_slave_ack();
    iic_write((addr >> 0) & 0xff);
    wait_slave_ack();
    cmd |= 0x01;
    start();
    iic_write(cmd);
    wait_slave_ack();
    //    dat = iic_read();

    for(i = 0; i < len; i++)
    {
        *dat = iic_read();
        master_send_ack();
        dat++;
    }
    no_ack();
    stop();
    eeprom_read_byte(addr);
}
