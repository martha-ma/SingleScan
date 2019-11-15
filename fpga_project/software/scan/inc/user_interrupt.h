/*
 * user_interrupt.h
 *
 *  Created on: 2019年4月9日
 *      Author: wj
 */

#ifndef INC_USER_INTERRUPT_H_
#define INC_USER_INTERRUPT_H_

#include <sys/unistd.h>
#include "system.h"
#include "altera_avalon_fifo_util.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_timer_regs.h"
#include "led.h"
#include "sys/alt_dma.h"
#include "sys/alt_irq.h"

#include "region.h"

extern alt_u32 timer_isr_context;
void timer_initial(void);
void timer_isr_interrupt(void * isr_context, alt_u32 id);

void alarm_select_pio_initial(void);
void alarm_select_pio_isr_interrupt(void);

void watchdog_init(void);
void watchdog_feed(void);

#endif /* INC_USER_INTERRUPT_H_ */
