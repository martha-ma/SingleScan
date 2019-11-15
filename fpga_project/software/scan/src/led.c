
#include "../inc/led.h"

led_time_flag_t led_time_flag;

// 电源指示灯 绿色
void led_power_light(unsigned char status)
{
    IOWR_ALTERA_AVALON_PIO_DATA(POWER_LED_BASE, status);
}

// 状态指示灯 红色
void led_status_light(unsigned char status)
{
    IOWR_ALTERA_AVALON_PIO_DATA(STATUS_LED_BASE, status);
}

