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
    unsigned char cnt_2s_p;
    unsigned char power_led_2s_flag;
    unsigned char power_led_1s_flag;
    unsigned char cnt_1s_p;

    unsigned char cnt_1s;
    unsigned char status_led_1s_flag;

    unsigned char power_led_300ms_flag;
    unsigned char cnt_300ms_p;

    unsigned char status_led_300ms_flag;
    unsigned char cnt_300ms;
    unsigned char cnt_30ms;
}led_time_flag_t;

extern led_time_flag_t led_time_flag;

/**
 * @brief led 寮�鎴栬�呭叧
 * 缁胯壊(鐢垫簮)鎸囩ず鐏�  bit[1]
 * @param status 
 */
void led_power_light(unsigned char status);

/**
 * @brief 鎺у埗led2 闂儊棰戠巼 1Hz  /  5Hz
 * 绾㈣壊(鐘舵��)鎸囩ず鐏�   bit[0]
 * @param time  鍗曚綅us
 */
void led_status_light(unsigned char status);
#endif
