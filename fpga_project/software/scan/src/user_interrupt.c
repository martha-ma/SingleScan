#include "user_interrupt.h"
#include "fpga2nios_protocol.h"
#include "nios2fpga_protocol.h"
alt_u32 timer_isr_context;

void timer_initial(void)
{
    // 1s/8-1
    // 100ms/8-1 = 0xbebc1f
    // 10ms/8-1 = 0x1312cf
    // 1ms/10-1 = 0xf4240
    void *isr_context_ptr = (void *)&timer_isr_context;
    IOWR_ALTERA_AVALON_TIMER_PERIODH(LED_TIMER_BASE, 0x000f);
    IOWR_ALTERA_AVALON_TIMER_PERIODL(LED_TIMER_BASE, 0x4240);

    IOWR_ALTERA_AVALON_TIMER_CONTROL(
        LED_TIMER_BASE,
        ALTERA_AVALON_TIMER_CONTROL_START_MSK |
            ALTERA_AVALON_TIMER_CONTROL_CONT_MSK |
            ALTERA_AVALON_TIMER_CONTROL_ITO_MSK);

    alt_ic_isr_register(
        LED_TIMER_IRQ_INTERRUPT_CONTROLLER_ID,
        LED_TIMER_IRQ,
        timer_isr_interrupt,
        isr_context_ptr,
        0x00);
}

void timer_isr_interrupt(void *isr_context, alt_u32 id)
{
    IOWR_ALTERA_AVALON_TIMER_STATUS(LED_TIMER_BASE, ~ALTERA_AVALON_TIMER_STATUS_TO_MSK);

    if(led_time_flag.cnt_1s == 50)
    {
        led_time_flag.cnt_1s             = 0;
        led_time_flag.status_led_1s_flag = 0x01;

//        led_time_flag.power_led_value = (~led_time_flag.power_led_value) & 0x01;

//        led_power_light(led_time_flag.power_led_value);
    }
    else
        led_time_flag.cnt_1s++;

    if(led_time_flag.cnt_300ms == 15)
        {
            led_time_flag.cnt_300ms             = 0;
            led_time_flag.status_led_300ms_flag = 0x01;
        }
        else
            led_time_flag.cnt_300ms++;


 //����2sѡ��
    if(led_time_flag.cnt_2s_p == 100)
    {
        led_time_flag.cnt_2s_p             = 0;
        led_time_flag.power_led_2s_flag = 0x01;
    }
    else
        led_time_flag.cnt_2s_p++;

    if(led_time_flag.cnt_1s_p == 50)
    {
        led_time_flag.cnt_1s_p             = 0;
        led_time_flag.power_led_1s_flag = 0x01;
    }
    else
        led_time_flag.cnt_1s_p++;
    if(led_time_flag.cnt_300ms_p == 15)
    {
        led_time_flag.cnt_300ms_p             = 0;
        led_time_flag.power_led_300ms_flag = 0x01;
    }
    else
        led_time_flag.cnt_300ms_p++;
  //  if(led_time_flag.cnt_30ms_p == 1)
   //     {
   //         led_time_flag.cnt_30ms_p             = 0;
   //         led_time_flag.power_led_30ms_flag = 0x01;
   //     }
    //    else
    //        led_time_flag.cnt_30ms_p++;
    if(led_time_flag.cnt_30ms == 3)
        {
            alarm_region.last_io_value[0] = rd_switch_io_value();
            if(alarm_region.last_io_value[0] != alarm_region.last_io_value[1])
            {
                alarm_region.change_region_flag  = 0x01;
                alarm_region.change_region_value = alarm_region.last_io_value[0];
            }
            alarm_region.last_io_value[1] = alarm_region.last_io_value[0];
            led_time_flag.cnt_30ms        = 0;
        }
        else
            led_time_flag.cnt_30ms++;



       if(sys_warn.region_alarm)
       {

           if(sys_warn.region_alarm & 0x01)
           {
           	if(led_time_flag.power_led_300ms_flag)
           	{
          	    led_time_flag.power_led_300ms_flag = 0x00;
           	led_time_flag.power_led_value      = (~led_time_flag.power_led_value) & 0x01;
           	led_power_light(led_time_flag.power_led_value);
           	}
           }
           else if(sys_warn.region_alarm & 0x02)
           {
           	if(led_time_flag.power_led_1s_flag)
           	{
           	led_time_flag.power_led_1s_flag = 0x00;
           	led_time_flag.power_led_value      = (~led_time_flag.power_led_value) & 0x01;
           	led_power_light(led_time_flag.power_led_value);
           	}
           }
           else if(sys_warn.region_alarm & 0x04)
           {
           	if(led_time_flag.power_led_2s_flag)
           	{
               led_time_flag.power_led_2s_flag = 0x00;
               led_time_flag.power_led_value      = (~led_time_flag.power_led_value) & 0x01;
               led_power_light(led_time_flag.power_led_value);
           	}
           }
       }
       else if(~sys_warn.region_alarm |isPowerUp)
       {
       	led_power_light(LED_ON);
       }
       if(sys_warn.motor_low_speed_alarm | sys_warn.ld_not_work_alarm)
               {
                   led_status_light(LED_ON);
                   set_laser_paramter(&Nios2FPGA_pck, LASER_FREQ,
                                      sys_warn.motor_low_speed_alarm | sys_warn.ld_not_work_alarm | sys_warn.temp_out_alarm | sys_warn.window_dust_alarm);
               }
               else if(sys_warn.window_dust_alarm)
               {
                   if(led_time_flag.status_led_1s_flag)
                   {
                       led_time_flag.status_led_1s_flag = 0x00;
                       led_time_flag.status_led_value   = (~led_time_flag.status_led_value) & 0x01;
                       led_status_light(led_time_flag.status_led_value);
                   }
                   set_laser_paramter(&Nios2FPGA_pck, LASER_FREQ,
                                      sys_warn.motor_low_speed_alarm | sys_warn.ld_not_work_alarm | sys_warn.temp_out_alarm | sys_warn.window_dust_alarm);
               }
               else if(sys_warn.temp_out_alarm)
               {
                   if(led_time_flag.status_led_300ms_flag)
                   {
                       led_time_flag.status_led_300ms_flag = 0x00;
                       led_time_flag.status_led_value      = (~led_time_flag.status_led_value) & 0x01;
                       led_status_light(led_time_flag.status_led_value);
                   }
                   set_laser_paramter(&Nios2FPGA_pck, LASER_FREQ,
                                      sys_warn.motor_low_speed_alarm | sys_warn.ld_not_work_alarm | sys_warn.temp_out_alarm | sys_warn.window_dust_alarm);
               }
}
//void alarm_select_pio_initial(void)
//{
//    // 使能中断
//    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(ALARM_SELECT_BASE, 0xff);
//    // 清中断边沿捕获寄存器
//    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(ALARM_SELECT_BASE, 0xff);
//    alt_ic_isr_register(
//        ALARM_SELECT_IRQ_INTERRUPT_CONTROLLER_ID,
//        ALARM_SELECT_IRQ,
//        alarm_select_pio_isr_interrupt,
//        0x00,
//        0x00
//    );
//}
//void alarm_select_pio_isr_interrupt(void)
//{
//    alarm_region.change_region_flag = 0x01;
////    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(ALARM_SELECT_BASE, 0x00);
//    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(ALARM_SELECT_BASE, 0xff);
//}

void watchdog_init(void)
{
    IOWR_ALTERA_AVALON_TIMER_CONTROL(WATCHDOG_BASE, ALTERA_AVALON_TIMER_CONTROL_START_MSK);
}

void watchdog_feed(void)
{
    IOWR_ALTERA_AVALON_TIMER_PERIODL(WATCHDOG_BASE, 0x1234);
}
