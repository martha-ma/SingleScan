/*
 * iic.h
 *
 *  Created on: 2018年10月16日
 *      Author: wangj
 */

#ifndef INC_IIC_H_
#define INC_IIC_H_

#include "scan_config.h"
#include "system.h"

#define AT24C512_MAX_ADDR	(65536 - 5536)
#define AT24C1024_MAX_ADDR	(131072 - 11072)

#define OUT 1
#define IN 0

#define HIGH_TIME	2
#define LOW_TIME	1

typedef struct
{
	void (* write_byte)(unsigned int addr, unsigned char dat);
	void (* write_page)(alt_u32 addr, alt_u8 *dat, alt_u16 len);
	unsigned char (* read_byte)(unsigned int addr);
}IIC;

extern IIC iic;

/**
 * @brief 
 * 
 * @param addr 
 * @param dat 
 * @param len 
 */
void iic_sequential_read(alt_u32 addr, alt_u8 *dat, alt_u16 len);

#endif /* INC_IIC_H_ */
