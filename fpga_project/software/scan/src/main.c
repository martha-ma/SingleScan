/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */
#include <sys/unistd.h>

#include "../inc/led.h"
#include "altera_avalon_epcs_flash_controller.h"
#include "altera_avalon_fifo_util.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_timer_regs.h"
#include "sys/alt_dma.h"
#include "sys/alt_flash.h"
#include "sys/alt_irq.h"
#include "system.h"

#include "bsp.h"
#include "device.h"
#include "pc2dev.h"
#include "fpga2nios_protocol.h"
#include "nios2fpga_protocol.h"
#include "sick_protocol.h"
#include "region.h"
#include "socket.h"
#include "user_interrupt.h"
#include "w5500.h"

void init_avalon_fifo(void)
{
    altera_avalon_fifo_init(PROTOCOL_FIFO_IN_CSR_BASE, 0, 2, PROTOCOL_FIFO_IN_FIFO_DEPTH - 2);
    altera_avalon_fifo_init(LASER_FIFO_IN_CSR_BASE, 0, 2, LASER_FIFO_OUT_FIFO_DEPTH - 2);
    altera_avalon_fifo_init(SPIWR_FIFO_IN_CSR_BASE, 0, 2, 120);
    altera_avalon_fifo_init(SPIRD_FIFO_IN_CSR_BASE, 0, 2, 120);
}

int main()
{
#if 0
    test();
#else
    unsigned int len, offset, recv_data;
    init_avalon_fifo();
    IINCHIP_CSon();

    /***** 硬重启W5500 *****/
    Reset_W5500();
    IOWR_ALTERA_AVALON_PIO_DATA(POWER_LED_BASE, LED_ON);
    IOWR_ALTERA_AVALON_PIO_DATA(STATUS_LED_BASE, LED_OFF);

    /***** W5500的IP信息初始化 *****/
    delay_ms(500);
    set_default();  // 设置默认MAC、IP、GW、SUB、DNS
    set_network();  // 配置初始化IP信息并打印，初始化8个Socket
    /***** 打开W5500的Keepalive功能 *****/
    //     setkeepalive(0);

    alarm_region.change_region_value = rd_switch_io_value();
    alarm_region.change_region_flag  = 0x01;
    isPowerUp                        = 0x01;
    // 从默认地址读取数据作为默认报警区域
    region_read_from_rom(&alarm_region, alarm_region.change_region_value * 3);
    region_read_from_rom(&alarm_region, alarm_region.change_region_value * 3 + 1);
    region_read_from_rom(&alarm_region, alarm_region.change_region_value * 3 + 2);
    read_sys_para(&SysPara);
    init_fpga_sys();
    timer_initial();
    //    alarm_select_pio_initial();
        watchdog_init();
    queue_init(&LaserDataQueue, &LaserData[0], 2048);
    while(1)
    {
        tim561_run();
        while(fpga_is_has_data())
        {
            if(queue_is_full(&LaserDataQueue))
                queue_clear(&LaserDataQueue);
            recv_data = read_fpga_data();
            if(recv_data >> 16 == FRAME_HEAD)
                len = 0;

            queue_push(&LaserDataQueue, recv_data);
            if((recv_data & 0xffff) == 0xeeee)
            {
                LaserDataQueue.frame_over_flag = 0x01;
                break;
            }
        }
        if(LaserDataQueue.frame_over_flag == 0x01)
        {
            fpga2nios_parse();
            LaserDataQueue.frame_over_flag = 0x00;
            //            if(queue_is_empty(&LaserDataQueue))
            //            	LaserDataQueue.frame_over_flag = 0x00;
        }
        // 打包 获得数据到(sick数据协议) send_buffer;
        if(CycleData.pos_finish)
        {
            CycleData.pos_finish = false;
            sick_pos_packet();
            offset = 0;

            while(1)  // 分包发送
            {
                IOWR_ALTERA_AVALON_PIO_DATA(W5500_INT_BASE, 0x01);
                len = strlen((char *)send_buffer);
                if(len - offset >= 1460)
                {
                    send(SOCKET0, send_buffer + offset, 1460);
                    send(SOCKET1, send_buffer + offset, 1460);
                    offset += 1460;
                }
                else if((len - offset < 1460) && (len - offset > 0))
                {
                    send(SOCKET0, send_buffer + offset, len - offset);
                    send(SOCKET1, send_buffer + offset, len - offset);
                    IOWR_ALTERA_AVALON_PIO_DATA(W5500_INT_BASE, 0x00);

                    // if(sys_warn.region_alarm != 0)
                    {
                        send_buffer[0]  = 0x12;
                        send_buffer[1]  = 0x34;
                        send_buffer[2]  = (UP_ALARM_REGION_STATUS >> 8) & 0xff;
                        send_buffer[3]  = (UP_ALARM_REGION_STATUS >> 0) & 0xff;
                        send_buffer[4]  = 0;
                        send_buffer[5]  = 0;
                        send_buffer[6]  = 0;
                        send_buffer[7]  = 4;
                        send_buffer[8]  = 0;
                        send_buffer[9]  = 0;
                        send_buffer[10] = 0;
                        send_buffer[11] = (unsigned char)sys_warn.region_alarm;
                        send_buffer[12] = send_buffer[13] = send_buffer[14] = send_buffer[15] = 0xee;  // 当做校验码
                        send(SOCKET0, send_buffer, 16);
                        send(SOCKET1, send_buffer, 16);
                    }
                    break;
                }
                else
                    break;
            }
        }

        if(sys_warn.motor_low_speed_alarm | sys_warn.ld_not_work_alarm)
        {
             led_status_light(LED_ON);
             set_laser_paramter(&Nios2FPGA_pck, LASER_FREQ,
            		 sys_warn.motor_low_speed_alarm | sys_warn.ld_not_work_alarm | sys_warn.temp_out_alarm | sys_warn.window_dust_alarm);
             set_laser_paramter(&Nios2FPGA_pck, LASER_ENABLE, 0x00000000);
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




         alarm_region.last_io_value[0] = rd_switch_io_value();
         if(alarm_region.last_io_value[0] != alarm_region.last_io_value[1])
         {
             alarm_region.change_region_flag = 0x01;
             alarm_region.change_region_value = alarm_region.last_io_value[0];
         }
         alarm_region.last_io_value[1] = alarm_region.last_io_value[0];

        if(isTcpEstablished & isPowerUp)  // 刚上电且TCP连接建立时，发送一次
        {
            isPowerUp        = 0x00;
            nios2pc.command  = UP_ALARM_IO_VALUE;
            nios2pc.data_len = 4;
            nios2pc.value    = alarm_region.change_region_value;
            len              = pc2dev_packet(&nios2pc, send_buffer);
            send(SOCKET0, send_buffer, len);
            send(SOCKET1, send_buffer, len);
        }

        if(alarm_region.change_region_flag == 0x01)
        {
            alarm_region.change_region_flag = 0x00;
            region_read_from_rom(&alarm_region, alarm_region.change_region_value * 3);
            region_read_from_rom(&alarm_region, alarm_region.change_region_value * 3 + 1);
            region_read_from_rom(&alarm_region, alarm_region.change_region_value * 3 + 2);

            //            if(isTcpEstablished)
            {
                nios2pc.command  = UP_ALARM_IO_VALUE;
                nios2pc.data_len = 4;
                nios2pc.value    = alarm_region.change_region_value;
                len              = pc2dev_packet(&nios2pc, send_buffer);
                send(SOCKET0, send_buffer, len);
                send(SOCKET1, send_buffer, len);
            }
        }
        if(SysStatus.reset_nios != ENABLE)
            watchdog_feed();
    }

#endif
    return 0;
}
