#ifndef STATUS_LED_H
#define STATUS_LED_H
#include <system.h>
#include <sys/unistd.h>
#include "altera_avalon_pio_regs.h"

#define LED_ON  0x00
#define LED_OFF 0x01

typedef struct __led_time_flag
{
    unsigned char power_led_value;
    unsigned char status_led_value;
    unsigned char power_led_1s_flag;
    unsigned char cnt_1s;
    unsigned char status_led_1s_flag;
    unsigned char status_led_300ms_flag;
    unsigned char cnt_300ms;
    unsigned char cnt_30ms;
}led_time_flag_t;

extern led_time_flag_t led_time_flag;

/**
 * @brief led 开或者关
 * 绿色(电源)指示灯  bit[1]
 * @param status 
 */
void power_led_light(unsigned char status);

/**
 * @brief 控制led2 闪烁频率 1Hz  /  5Hz
 * 红色(状态)指示灯   bit[0]
 * @param time  单位us
 */
void status_led_light(unsigned char status);
#endif
