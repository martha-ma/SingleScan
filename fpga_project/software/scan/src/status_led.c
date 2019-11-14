
#include "status_led.h"

led_time_flag_t led_time_flag;

// 电源指示灯 绿色
void power_led_light(unsigned char status)
{
    IOWR_ALTERA_AVALON_PIO_DATA(POWER_LED_BASE, status);
}

// 状态指示灯 红色
void status_led_light(unsigned char status)
{
    IOWR_ALTERA_AVALON_PIO_DATA(STATUS_LED_BASE, status);
}

