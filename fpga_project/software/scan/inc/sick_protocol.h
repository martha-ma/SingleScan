#ifndef INC_SICK_PROTOCOL_H_
#define INC_SICK_PROTOCOL_H_
#include <string.h>
#include <sys/unistd.h>

#include "tim561.h"
#include "pc2dev.h"
#include "bsp.h"
#include "w5500.h"
#include "nios2fpga_protocol.h"
#include "socket.h"
#include "iic.h"
#include "region.h"

/**
 * @brief
 *
 * @param buf
 * @param len
 */
void sick_protocol_process(SOCKET s, unsigned char *buf, int len);

/**
 * @brief 将已经收到的一圈距离数据和sick协议其他数据封装好
 *
 */
void sick_pos_packet(void);

#endif /* INC_SICK_PROTOCOL_H_ */
