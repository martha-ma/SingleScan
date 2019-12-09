/*
 * bsp.c
 *
 *  Created on: 2018-3-29
 *      Author: wj
 */

#include "bsp.h"
#include "region.h"
uint8         buffer[2048];
unsigned char isTcpEstablished;
unsigned char isPowerUp;
Sys_Para      SysPara = {.update_pos_flag      = false,
                    .laser_enable         = 0x11111111,
                    .laser_freq           = 100000000,
                    .laser_pulse_width    = 7,
                    .laser_recv_delay     = 2,
                    .motor_enable         = 0x11111111,
                    .motor_expect_speed   = 15,
                    .zero_distance_revise = 0,
                    .zero_angle_revise    = 135,

                    .gray_distance_revise1 = 35,
                    .gray_distance_revise2 = 140,
                    .gray_distance_revise3 = 140,
                    .gray_inflection1      = 59,
                    .gray_inflection2      = 120,
                    .gray_inflection3      = 200,

                    .noise_diff_setting1 = 180,
                    .noise_diff_setting2 = 100,

                    .signal_thresold = 100,
                    .apd_vol_base    = 520,
                    .placeholer1     = 0xeeeeeeee,
                    .nios_ver        = "0.01",
                    .fpga_ver        = "0.01",

                    .temp_volt_cof1       = 35,
                    .temp_volt_cof2       = 38,
                    .temp_volt_inflection = 25,

                    .temp_distance_cof1       = 13,
                    .temp_distance_cof2       = 9,
                    .temp_distance_inflection = 16,

                    .min_display_distance = 50,
                    .first_noise_filter   = 3,
                    .dust_alarm_threshold = 35,
                    .board_type           = 1,

                    .zero_value       = 0,
                    .sys_temp         = 0,
                    .motor_real_speed = 0,
                    .max_pwm_duty     = 10,
                    .min_pwm_duty     = 0,
                    .dust_threshold   = 400,
                    .da_cycle_para1   = 88,
                    .da_cycle_para2   = 112,
                    .da_cycle_para3   = 136,
                    .da_cycle_para4   = 160,
                    .da_cycle_para5   = 172,
                    .da_cycle_para6   = 148,
                    .da_cycle_para7   = 124,
                    .da_cycle_para8   = 100,
                    .da_cycle_para9   = 76,
					.min_target_size = 0,
					.alarm_output_threshold = 1
};

Sys_Status SysStatus;
// 500us宸﹀彸
void delay_ms(unsigned int d)
{
    int i = 0;
    while(i < d * 1000)
        i++;
}

// 1.4us宸﹀彸
void delay_us(unsigned int d)
{
    int i = 0;
    int j = 0;
    for(i = 0; i < d; i++)
    {
        for(j = 0; j < 2; j++)
        {
            ;
        }
    }
}

void tim561_run(void)
{
    uint8  boardcast_ip[4] = {255, 255, 255, 255};
    uint16 local_port      = 30718;
    uint8  remote_ip[4];
    uint16 remote_port;
    uint16 len = 0;
    uint8  status;
    uint8  socket0_error = 0;
    uint8  socket2_error = 0;
    uint8  socket0_close = 0;
    uint8  socket2_close = 0;
    status               = getSn_SR(SOCKET0);
    switch(status)
    {
        case SOCK_INIT:
            listen(SOCKET0);
            break;
        case SOCK_ESTABLISHED:
            if(getSn_IR(SOCKET0) & Sn_IR_CON)
            {
                setSn_IR(SOCKET0, Sn_IR_CON);
            }
            len = getSn_RX_RSR(SOCKET0);
            if(len > 0)
            {
                recv(SOCKET0, buffer, len);
                pc2dev_parse(SOCKET0, buffer, len);
                // send(0, buffer, len);
            }
            isTcpEstablished = 1;
            break;
        case SOCK_CLOSE_WAIT:
            socket0_close++;
            close_socket(SOCKET0);
            break;
        case SOCK_CLOSED:
            socket(SOCKET0, Sn_MR_TCP, 2111, Sn_MR_ND);
            if(isTcpEstablished)
            {
                Reset_W5500();
                delay_ms(500);
                set_default();  // 璁剧疆榛樿MAC銆両P銆丟W銆丼UB銆丏NS
                set_network();  // 閰嶇疆鍒濆鍖朓P淇℃伅骞舵墦鍗帮紝鍒濆鍖�8涓猄ocket
                isTcpEstablished = 0;
            }
            break;
        case SOCK_LISTEN:
        case SOCK_SYNRECV:
            break;
        case 0x11:
            socket0_error++;
            break;
        default:
            len = 0;
            break;
    }

    status = getSn_SR(SOCKET1);
    switch(status)
    {
        case SOCK_INIT:
            listen(SOCKET1);
            break;
        case SOCK_ESTABLISHED:
            if(getSn_IR(SOCKET1) & Sn_IR_CON)
            {
                setSn_IR(SOCKET1, Sn_IR_CON);
            }
            len = getSn_RX_RSR(SOCKET1);
            if(len > 0)
            {
                recv(SOCKET1, buffer, len);
                pc2dev_parse(SOCKET1, buffer, len);
            }
            break;
        case SOCK_CLOSE_WAIT:
            socket2_close++;
            close_socket(SOCKET1);
            break;
        case SOCK_CLOSED:
            socket(SOCKET1, Sn_MR_TCP, 2111, Sn_MR_ND);
            if(isTcpEstablished)
            {
                // Reset_W5500();
                // delay_ms(500);
                // set_default();  // 璁剧疆榛樿MAC銆両P銆丟W銆丼UB銆丏NS
                // set_network();  // 閰嶇疆鍒濆鍖朓P淇℃伅骞舵墦鍗帮紝鍒濆鍖�8涓猄ocket
                isTcpEstablished = 0;
            }
            break;
        case SOCK_LISTEN:
        case SOCK_SYNRECV:
            break;
        case 0x11:
            socket2_error++;
            break;
        default:
            len = 0;
            break;
    }

    status = getSn_SR(SOCKET4);
    switch(status)
    {
        case SOCK_INIT:
            listen(SOCKET4);
            break;
        case SOCK_ESTABLISHED:
            if(getSn_IR(SOCKET4) & Sn_IR_CON)
            {
                setSn_IR(SOCKET4, Sn_IR_CON);
            }
            len = getSn_RX_RSR(SOCKET4);
            if(len > 0)
            {
                recv(SOCKET4, buffer, len);
                pc2dev_parse(SOCKET4, buffer, len);
                // send(0, buffer, len);
            }
            break;
        case SOCK_CLOSE_WAIT:
            socket2_close++;
            close_socket(SOCKET4);
            break;
        case SOCK_CLOSED:
            socket(SOCKET4, Sn_MR_TCP, 2112, Sn_MR_ND);
            break;
        case SOCK_LISTEN:
        case SOCK_SYNRECV:
            break;
        case 0x11:
            socket2_error++;
            break;
        default:
            len = 0;
            break;
    }

    status = getSn_SR(SOCKET5);
    switch(status)
    {
        case SOCK_INIT:
            listen(SOCKET5);
            break;
        case SOCK_ESTABLISHED:
            if(getSn_IR(SOCKET5) & Sn_IR_CON)
            {
                setSn_IR(SOCKET5, Sn_IR_CON);
            }

            len = getSn_RX_RSR(SOCKET5);
            if(len > 0)
            {
                recv(SOCKET5, buffer, len);
                pc2dev_parse(SOCKET5, buffer, len);
                // send(0, buffer, len);
            }
            break;
        case SOCK_CLOSE_WAIT:
            socket2_close++;
            close_socket(SOCKET5);
            break;
        case SOCK_CLOSED:
            socket(SOCKET5, Sn_MR_TCP, 2112, Sn_MR_ND);
            break;
        case SOCK_LISTEN:
        case SOCK_SYNRECV:
            break;
        case 0x11:
            socket2_error++;
            break;
        default:
            len = 0;
            break;
    }

    switch(getSn_SR(SOCKET7))
    {
        case SOCK_UDP:  // Socket???????(??)??
            delay_ms(10);
            if(getSn_IR(SOCKET7) & Sn_IR_RECV)
            {
                setSn_IR(SOCKET7, Sn_IR_RECV);
            }

            if((len = getSn_RX_RSR(SOCKET7)) > 0)
            {
                memset(buffer, 0, len + 1);
                recvfrom(SOCKET7, buffer, len, remote_ip, &remote_port);
                // sendto(1, buffer, len, remote_ip, remote_port);
                sendto(SOCKET7, udp_reponse, 1213, boardcast_ip, remote_port);
                alarm_region.change_region_flag = 0x01;
                isPowerUp                       = 0x01;
            }
            break;
        case SOCK_CLOSED:
            socket(SOCKET7, Sn_MR_UDP, local_port, 0);
            break;
    }
}

void test(void)
{
    IINCHIP_CSon();
    Reset_W5500();
    delay_ms(500);
    int           time        = 1;
    unsigned char data        = 0x1e;
    int           offset_addr = 4096;
    int           len         = TARGET_NUMBER * 2;
    unsigned char buf[811 * 2];
    IOWR_ALTERA_AVALON_PIO_DATA(W5500_INT_BASE, 0x00);
    while(1)
    {
        if(time)
        {
            for(int i = 0; i < 811 * 2; i++)
                buf[i] = data;
            eeprom_write_page(offset_addr, buf, len);
            memset(buf, 0, TARGET_NUMBER * 2);
        }
        //		alarm_region.read_from_rom(&alarm_region, alarm_region.change_region_value * 3);
        eeprom_sequential_read(offset_addr, buf, len);
        delay_us(1000);
    }
#if 0
	int i;
	unsigned char buf[256];
	int delay = 10*1000;
	int flag = 0;
	unsigned int addr = SYS_PARA_ADDR;
	int len = 41;

	while(1)
	{
	    IOWR_ALTERA_AVALON_PIO_DIRECTION(SDA_BASE, OUT);
	    IOWR_ALTERA_AVALON_PIO_DATA(SDA_BASE, 1);
		eeprom_sequential_read(addr, buf, len);
		iic.read_byte(addr);
	    IOWR_ALTERA_AVALON_PIO_DIRECTION(SDA_BASE, OUT);
	    IOWR_ALTERA_AVALON_PIO_DATA(SDA_BASE, 1);

//		if(flag == 1)
//			IOWR_ALTERA_AVALON_PIO_DATA(SDA_BASE, 1);
		usleep(delay);
	}
#endif
}
