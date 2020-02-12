/*
 * scan_config.h
 *
 *  Created on: 2019骞�5鏈�8鏃�
 *      Author: wj
 */

#ifndef INC_SCAN_CONFIG_H_
#define INC_SCAN_CONFIG_H_

//#define RELEASE_VERSION
#define NPN (0x01)
#define PNP (0x02)

#define EEPROM_PAGE_SIZE (256)
#define FPGA_VERSION "4.13"
#define NIOS_VERSION FPGA_VERSION

#define DEV_TYPE "SCA01-011331525P"
#define DEV_PN_NUM "01 0113 1525"
#define DEV_SN_NUM "1936 000001"

#define TEMP_OUT_VALUE 76
#define DUST_OUT_VALUE 500
#define LD_NO_WORK_VALUE 7
#define MOTOR_LOW_SPEED_VALUE 100000000

#endif /* INC_SCAN_CONFIG_H_ */
