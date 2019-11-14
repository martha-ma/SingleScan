#include "device.h"
#include "config.h"
#include "socket.h"
#include "w5500.h"
#include <stdio.h>
#include <string.h>

CONFIG_MSG  ConfigMsg, RecvMsg;

// socket 0 1 tcp server 2112
// socket 4 5 tcp server 2111
// socket 7 udp
//                            0  1  2  3  4  5  6  7
uint8 txsize[MAX_SOCK_NUM] = {4, 4, 0, 0, 2, 2, 2, 2};         // 选择8个Socket每个Socket发送缓存的大小，在w5500.c的void sysinit()有设置过程
uint8 rxsize[MAX_SOCK_NUM] = {4, 4, 0, 0, 2, 2, 2, 2};         // 选择8个Socket每个Socket接收缓存的大小，在w5500.c的void sysinit()有设置过程

// extern uint8 MAC[6];

uint8 pub_buf[1460];


void Reset_W5500(void)
{
    IOWR_ALTERA_AVALON_PIO_DATA(W5500_RST_BASE, 0x00);
    delay_ms(5);
    IOWR_ALTERA_AVALON_PIO_DATA(W5500_RST_BASE, 0x01);
    delay_ms(5);
}
//reboot
void reboot(void)
{
    pFunction Jump_To_Application;
    uint32 JumpAddress;
    JumpAddress = *(unsigned int*) (0x00000004);
    Jump_To_Application = (pFunction) JumpAddress;
    Jump_To_Application();
}

void set_network(void)                                                                                                          // 配置初始化IP信息并打印，初始化8个Socket
{
    uint8 ip[4];
    setSHAR(ConfigMsg.mac);
    setSUBR(ConfigMsg.sub);
    setGAR(ConfigMsg.gw);
    setSIPR(ConfigMsg.lip);

    sysinit(txsize, rxsize);                                                                                              // 初始化8个socket

    setRTR(5000);                                                                                                                                         // 设置超时时间
    setRCR(3);                                                                                                                                                    // 设置最大重新发送次数

    getSIPR (ip);
    getSUBR(ip);
    getGAR(ip);
}

void set_default(void)                                                                                                          // 设置默认MAC、IP、GW、SUB、DNS
{
    uint8 mac[6]={0x00,0x06,0x77,0x25,0x3D,0x28};
    uint8 lip[4]={192,168,0,1};
    uint8 sub[4]={255,255,255,0};
    uint8 gw[4]={192,168,0,1};
    uint8 dns[4]={8,8,8,8};
    memcpy(ConfigMsg.lip, lip, 4);
    memcpy(ConfigMsg.sub, sub, 4);
    memcpy(ConfigMsg.gw,  gw, 4);
    memcpy(ConfigMsg.mac, mac,6);
    memcpy(ConfigMsg.dns,dns,4);

    ConfigMsg.dhcp=0;
    ConfigMsg.debug=1;
    ConfigMsg.fw_len=0;

    ConfigMsg.state=NORMAL_STATE;
    ConfigMsg.sw_ver[0]=FW_VER_HIGH;
    ConfigMsg.sw_ver[1]=FW_VER_LOW;

}
