#include <stdio.h>
#include <string.h>
#include "config.h"
#include "w5500.h"
#include "socket.h"

#include "sys/alt_dma.h"
#include "altera_avalon_fifo_util.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_spi_regs.h"

#ifdef __DEF_IINCHIP_PPP__
#include "md5.h"
#endif

static uint16 SSIZE[MAX_SOCK_NUM]; /**< Max Tx buffer size by each channel */
static uint16 RSIZE[MAX_SOCK_NUM]; /**< Max Rx buffer size by each channel */

void IINCHIP_CSoff()
{
    IOWR_ALTERA_AVALON_PIO_DATA(W5500_CS_BASE, 0);
}

void IINCHIP_CSon()
{
    IOWR_ALTERA_AVALON_PIO_DATA(W5500_CS_BASE, 1);
}


uint16 getIINCHIP_RxMAX(uint8 s)
{
    return RSIZE[s];
}
uint16 getIINCHIP_TxMAX(uint8 s)
{
    return SSIZE[s];
}

unsigned char IINCHIP_SpiSendData(uint16 dat)
{
    // return(alt_avalon_spi_command(SPI_BASE, 0, 1, &dat, 0, NULL, 0));
    altera_avalon_fifo_write_fifo(SPIWR_FIFO_IN_BASE, SPIWR_FIFO_IN_CSR_BASE, (dat>>16) + (dat<<16));
    return 0;
}

unsigned char SPI_I2S_ReceiveData()
{
    //unsigned char rxbuf = 0;
    //alt_avalon_spi_command(SPI_BASE, 0, 0, NULL, 1, &rxbuf, 0);
    //return rxbuf;
	int num;
	unsigned int data;
	unsigned char rxbuf = 0;
	num = altera_avalon_fifo_read_level(SPIRD_FIFO_IN_CSR_BASE);
	if(num > 0)
	{
		data = altera_avalon_fifo_read_fifo(SPIRD_FIFO_OUT_BASE, SPIRD_FIFO_IN_CSR_BASE);
		rxbuf = (unsigned char)( ((data>>16) + (data<<16))& 0xff);
	}

	num = altera_avalon_fifo_read_level(SPIRD_FIFO_IN_CSR_BASE);
	return rxbuf;
}

void IINCHIP_WRITE( uint32 addrbsb,  uint8 data)
{
    IINCHIP_ISR_DISABLE();                        // Interrupt Service Routine Disable
    IINCHIP_CSoff();                              // CS=0, SPI start
    IINCHIP_SpiSendData( (addrbsb & 0x00FF0000)>>16);// Address byte 1
    IINCHIP_SpiSendData( (addrbsb & 0x0000FF00)>> 8);// Address byte 2
    IINCHIP_SpiSendData( (addrbsb & 0x000000F8) + 4);    // Data write command and Write data length 1
    IINCHIP_SpiSendData(data);                    // Data write (write 1byte data)
    IINCHIP_CSon();                               // CS=1,  SPI end
    IINCHIP_ISR_ENABLE();                         // Interrupt Service Routine Enable
}

uint8 IINCHIP_READ(uint32 addrbsb)
{
	uint16 num;
    uint8 data = 0;
    IINCHIP_ISR_DISABLE();                        // Interrupt Service Routine Disable
    IINCHIP_CSoff();                              // CS=0, SPI start
    IINCHIP_SpiSendData( (addrbsb & 0x00FF0000)>>16);// Address byte 1
    IINCHIP_SpiSendData( (addrbsb & 0x0000FF00)>> 8);// Address byte 2
    IINCHIP_SpiSendData( (addrbsb & 0x000000F8))    ;// Data read command and Read data length 1
    IINCHIP_SpiSendData(1);
    for( num = 0; num < 2; num++ ) ;
    data = SPI_I2S_ReceiveData();
    IINCHIP_CSon();                               // CS=1,  SPI end
    IINCHIP_ISR_ENABLE();                         // Interrupt Service Routine Enable
    return data;
}

uint16 wiz_write_buf(uint32 addrbsb, uint8* buf,uint16 len)
{
    uint16 idx = 0;
    // uint8 send_buf[3];
    // send_buf[0] = (addrbsb & 0x00FF0000)>>16;
    // send_buf[1] = (addrbsb & 0x0000FF00)>> 8;
    // send_buf[2] = (addrbsb & 0x000000F8) + 4;

    IINCHIP_ISR_DISABLE();
    IINCHIP_CSoff();
                             // CS=0, SPI start
    IINCHIP_SpiSendData( (addrbsb & 0x00FF0000)>>16);// Address byte 1
    IINCHIP_SpiSendData( (addrbsb & 0x0000FF00)>> 8);// Address byte 2
    IINCHIP_SpiSendData( (addrbsb & 0x000000F8) + 4);    // Data write command and Write data length 1
    for(idx = 0; idx < len; idx++)                // Write data in loop
    {
        IINCHIP_SpiSendData(buf[idx]);
    }
//	alt_dma_txchan  tx;
//	tx = alt_dma_txchan_open("/dev/dma");
//	if(tx != NULL)
//	{
//		alt_avalon_dma_tx_ioctl(tx, ALT_DMA_SET_MODE_8, NULL);
//		alt_avalon_dma_tx_ioctl(tx, ALT_DMA_TX_ONLY_ON, (void*)(SPI_BASE+4));
//		idx = alt_avalon_dma_send(tx, buf, (len<<1), NULL, NULL);
//	}
    // alt_avalon_spi_command(SPI_BASE, 0, 3, send_buf, 0, NULL, 0);
    // alt_avalon_spi_command(SPI_BASE, 0, len, buf, 0, NULL, 0);
    IINCHIP_CSon();                               // CS=1, SPI end
    IINCHIP_ISR_ENABLE();                         // Interrupt Service Routine Enable

    return len;
}


uint16 wiz_read_buf(uint32 addrbsb, uint8* buf,uint16 len)
{
    uint16 idx = 0;
    uint16 num = 0;

//    uint8 send_buf[3];
//    send_buf[0] = (addrbsb & 0x00FF0000)>>16;
//    send_buf[1] = (addrbsb & 0x0000FF00)>> 8;
//    send_buf[2] = (addrbsb & 0x000000F8);

    num = altera_avalon_fifo_read_level(SPIRD_FIFO_IN_CSR_BASE);  // 清空数据
    while(num > 0)
    {
        num = altera_avalon_fifo_read_level(SPIRD_FIFO_IN_CSR_BASE);
        idx = altera_avalon_fifo_read_fifo(SPIRD_FIFO_OUT_BASE, SPIRD_FIFO_IN_CSR_BASE);
    }

    IINCHIP_CSoff();                                      // CS=0, SPI开启
//    alt_avalon_spi_command(SPI_BASE, 0, 3, send_buf, len, buf, 0);
    IINCHIP_SpiSendData( (addrbsb & 0x00FF0000)>>16);		// 通过SPI发送16位地址段给MCU
    IINCHIP_SpiSendData( (addrbsb & 0x0000FF00)>> 8);		//
    IINCHIP_SpiSendData( (addrbsb & 0x000000F8));    		// 设置SPI为读操作

    IINCHIP_SpiSendData(len);
    for( num = 0; num < 4; num++ )
    {
        ;
    }
    for(idx = 0; idx < len; idx++)                    	// 将buf中的数据通过SPI发送给MCU
    {
        //buf[idx] = IINCHIP_SpiSendData(0x00);
        buf[idx] = SPI_I2S_ReceiveData();
    }

    num = altera_avalon_fifo_read_level(SPIRD_FIFO_IN_CSR_BASE);  // 清空数据
    while(num > 0)
    {
        num = altera_avalon_fifo_read_level(SPIRD_FIFO_IN_CSR_BASE);
        idx = altera_avalon_fifo_read_fifo(SPIRD_FIFO_OUT_BASE, SPIRD_FIFO_IN_CSR_BASE);
    }
    IINCHIP_CSon();                                       // CS=1, SPI关闭

    return len;                                                                                                                                                                   // 返回已接收数据的长度值
}


/**
  @brief  This function is for resetting of the iinchip. Initializes the iinchip to work in whether DIRECT or INDIRECT mode
  */
void iinchip_init(void)
{
    setMR( MR_RST );
}

/**
  @brief  This function set the transmit & receive buffer size as per the channels is used
  Note for TMSR and RMSR bits are as follows\n
  bit 1-0 : memory size of channel #0 \n
  bit 3-2 : memory size of channel #1 \n
  bit 5-4 : memory size of channel #2 \n
  bit 7-6 : memory size of channel #3 \n
  bit 9-8 : memory size of channel #4 \n
  bit 11-10 : memory size of channel #5 \n
  bit 12-12 : memory size of channel #6 \n
  bit 15-14 : memory size of channel #7 \n
  Maximum memory size for Tx, Rx in the W5500 is 16K Bytes,\n
  In the range of 16KBytes, the memory size could be allocated dynamically by each channel.\n
  Be attentive to sum of memory size shouldn't exceed 8Kbytes\n
  and to data transmission and receiption from non-allocated channel may cause some problems.\n
  If the 16KBytes memory is already  assigned to centain channel, \n
  other 3 channels couldn't be used, for there's no available memory.\n
  If two 4KBytes memory are assigned to two each channels, \n
  other 2 channels couldn't be used, for there's no available memory.\n
  */
void sysinit( uint8 * tx_size, uint8 * rx_size  )
{
    int16 i;
    int16 ssum,rsum;

    ssum = 0;
    rsum = 0;

    for (i = 0 ; i < MAX_SOCK_NUM; i++)       // Set the size, masking and base address of Tx & Rx memory by each channel
    {
        IINCHIP_WRITE( (Sn_TXMEM_SIZE(i)), tx_size[i]);
        IINCHIP_WRITE( (Sn_RXMEM_SIZE(i)), rx_size[i]);
        SSIZE[i] = (int16)(0);
        RSIZE[i] = (int16)(0);

        // W5500有8个Socket，每个Socket有对应独立的收发缓存区。
        // 每个Socket的发送/接收缓存区都在一个16KB的物理发送内存中，初始化分配为2KB。
        // 无论给每个Socket分配多大的收/发缓存，都必须在16KB以内。

        if (ssum <= 16384)                                                                          // 设置Socket发送缓存空间的大小
        {
            switch( tx_size[i] )
            {
                case 1:
                    SSIZE[i] = (int16)(1024);                       // i=1，tx_size=1KB
                    break;
                case 2:
                    SSIZE[i] = (int16)(2048);                       // i=2，tx_size=2KB
                    break;
                case 4:
                    SSIZE[i] = (int16)(4096);                       // i=4，tx_size=4KB
                    break;
                case 8:
                    SSIZE[i] = (int16)(8192);                       // i=8，tx_size=8KB
                    break;
                case 16:
                    SSIZE[i] = (int16)(16384);              // i=16，tx_size=16KB
                    break;
                default :
                    RSIZE[i] = (int16)(2048);                       // 默认i=2，tx_size=2KB
                    break;
            }
        }

        if (rsum <= 16384)                                                                      // 设置Socket接收缓存空间的大小
        {
            switch( rx_size[i] )
            {
                case 1:
                    RSIZE[i] = (int16)(1024);               // i=1，rx_size=1KB
                    break;
                case 2:
                    RSIZE[i] = (int16)(2048);               // i=2，rx_size=2KB
                    break;
                case 4:
                    RSIZE[i] = (int16)(4096);               // i=4，rx_size=4KB
                    break;
                case 8:
                    RSIZE[i] = (int16)(8192);               // i=8，rx_size=8KB
                    break;
                case 16:
                    RSIZE[i] = (int16)(16384);      // i=16，rx_size=16KB
                    break;
                default :
                    RSIZE[i] = (int16)(2048);               // 默认i=2，rx_size=2K
                    break;
            }
        }
        ssum += SSIZE[i];
        rsum += RSIZE[i];
    }
}

// added

/**
  @brief  This function sets up gateway IP address.
  */
void setGAR(
        uint8 * addr  /**< a pointer to a 4 -byte array responsible to set the Gateway IP address. */
        )
{
    wiz_write_buf(GAR0, addr, 4);
}
void getGWIP(uint8 * addr)
{
    wiz_read_buf(GAR0, addr, 4);
}

/**
  @brief  It sets up SubnetMask address
  */
void setSUBR(uint8 * addr)
{
    wiz_write_buf(SUBR0, addr, 4);
}
/**
  @brief  This function sets up MAC address.
  */
void setSHAR(
        uint8 * addr  /**< a pointer to a 6 -byte array responsible to set the MAC address. */
        )
{
    wiz_write_buf(SHAR0, addr, 6);
}

/**
  @brief  This function sets up Source IP address.
  */
void setSIPR(
        uint8 * addr  /**< a pointer to a 4 -byte array responsible to set the Source IP address. */
        )
{
    wiz_write_buf(SIPR0, addr, 4);
}

/**
  @brief  W5500心跳检测程序，设置Socket在线时间寄存器Sn_KPALVTR，单位为5s
  */
void setkeepalive(SOCKET s)
{
    IINCHIP_WRITE(Sn_KPALVTR(s),0x02);
}

/**
  @brief  This function sets up Source IP address.
  */
void getGAR(uint8 * addr)
{
    wiz_read_buf(GAR0, addr, 4);
}
void getSUBR(uint8 * addr)
{
    wiz_read_buf(SUBR0, addr, 4);
}
void getSHAR(uint8 * addr)
{
    wiz_read_buf(SHAR0, addr, 6);
}
void getSIPR(uint8 * addr)
{
    wiz_read_buf(SIPR0, addr, 4);
}

void setMR(uint8 val)
{
    IINCHIP_WRITE(MR,val);
}

/**
  @brief  This function gets Interrupt register in common register.
  */
uint8 getIR( void )
{
    return IINCHIP_READ(IR);
}

/**
  @brief  This function sets up Retransmission time.

  If there is no response from the peer or delay in response then retransmission
  will be there as per RTR (Retry Time-value Register)setting
  */
void setRTR(uint16 timeout)
{
    IINCHIP_WRITE(RTR0,(uint8)((timeout & 0xff00) >> 8));
    IINCHIP_WRITE(RTR1,(uint8)(timeout & 0x00ff));
}

/**
  @brief  This function set the number of Retransmission.

  If there is no response from the peer or delay in response then recorded time
  as per RTR & RCR register seeting then time out will occur.
  */
void setRCR(uint8 retry)
{
    IINCHIP_WRITE(WIZ_RCR,retry);
}

/**
  @brief  This function set the interrupt mask Enable/Disable appropriate Interrupt. ('1' : interrupt enable)

  If any bit in IMR is set as '0' then there is not interrupt signal though the bit is
  set in IR register.
  */
void clearIR(uint8 mask)
{
    IINCHIP_WRITE(IR, ~mask | getIR() ); // must be setted 0x10.
}

/**
  @brief  This sets the maximum segment size of TCP in Active Mode), while in Passive Mode this is set by peer
  */
void setSn_MSS(SOCKET s, uint16 Sn_MSSR)
{
    IINCHIP_WRITE( Sn_MSSR0(s), (uint8)((Sn_MSSR & 0xff00) >> 8));
    IINCHIP_WRITE( Sn_MSSR1(s), (uint8)(Sn_MSSR & 0x00ff));
}
/*
   void setSn_TTL(SOCKET s, uint8 ttl)
   {
   IINCHIP_WRITE( Sn_TTL(s) , ttl);
   }

*/

/**
  @brief  get socket interrupt status

  These below functions are used to read the Interrupt & Soket Status register
  */
uint8 getSn_IR(SOCKET s)
{
    return IINCHIP_READ(Sn_IR(s));
}


/**
  @brief   get socket status
  */
uint8 getSn_SR(SOCKET s)
{
    return IINCHIP_READ(Sn_SR(s));
}


/**
  @brief  get socket TX free buf size

  This gives free buffer size of transmit buffer. This is the data size that user can transmit.
  User shuold check this value first and control the size of transmitting data
  */
uint16 getSn_TX_FSR(SOCKET s)
{
    uint16 val=0,val1=0;
    do
    {
        val1 = IINCHIP_READ(Sn_TX_FSR0(s));
        val1 = (val1 << 8) + IINCHIP_READ(Sn_TX_FSR1(s));
        if (val1 != 0)
        {
            val = IINCHIP_READ(Sn_TX_FSR0(s));
            val = (val << 8) + IINCHIP_READ(Sn_TX_FSR1(s));
        }
    } while (val != val1);
    return val;
}


/**
  @brief   get socket RX recv buf size

  This gives size of received data in receive buffer.
  */
uint16 getSn_RX_RSR(SOCKET s)                                                                                                           // 获取空闲接收缓存寄存器的值
{
    uint16 val=0,val1=0;
    do
    {
        val1 = IINCHIP_READ(Sn_RX_RSR0(s));                                                                 // MCU读Sn_RX_RSR的低8位，并赋给val1
        val1 = (val1 << 8) + IINCHIP_READ(Sn_RX_RSR1(s));           // 读高8位，并与低8位相加赋给val1
        if(val1 != 0)                                                                                                                                                               // 若Sn_RX_RSR的值不为0，将其赋给val
        {
            val = IINCHIP_READ(Sn_RX_RSR0(s));
            val = (val << 8) + IINCHIP_READ(Sn_RX_RSR1(s));
        }
    } while (val != val1);                                                                                                                                // 判断val与val1是否相等，若不等，重新返回do循环，若相等，跳出循环
    return val;                                                                                                                                                                  // 将val的值返回给getSn_RX_RSR
}


/**
  @brief   This function is being called by send() and sendto() function also.

  This function read the Tx write pointer register and after copy the data in buffer update the Tx write pointer
  register. User should read upper byte first and lower byte later to get proper value.
  */
void send_data_processing(SOCKET s, uint8 *data, uint16 len)
{
    uint16 ptr =0;
    uint32 addrbsb =0;
    if(len == 0)
    {
        return;
    }


    ptr = IINCHIP_READ( Sn_TX_WR0(s) );
    ptr = ((ptr & 0x00ff) << 8) + IINCHIP_READ(Sn_TX_WR1(s));

    addrbsb = (uint32)(ptr<<8) + (s<<5) + 0x10;
    wiz_write_buf(addrbsb, data, len);

    ptr += len;
    IINCHIP_WRITE( Sn_TX_WR0(s) ,(uint8)((ptr & 0xff00) >> 8));
    IINCHIP_WRITE( Sn_TX_WR1(s),(uint8)(ptr & 0x00ff));
}


/**
  @brief  This function is being called by recv() also.

  This function read the Rx read pointer register
  and after copy the data from receive buffer update the Rx write pointer register.
  User should read upper byte first and lower byte later to get proper value.
  */
void recv_data_processing(SOCKET s, uint8 *data, uint16 len)
{
    uint16 ptr = 0;
    uint32 addrbsb = 0;

    if(len == 0)                                          // 若接收数据的长度为0，则串口打印“"CH: 0 Unexpected2 length 0”
    {
        return;
    }

    // MCU读取Sn_RX_RD接收写指针寄存器的值，并赋给ptr
    // Sn_RX_RD保存接收缓存中数据的首地址，若有数据接收，则接收完后该寄存器值要更新
    ptr = IINCHIP_READ( Sn_RX_RD0(s) );
    ptr = ((ptr & 0x00ff) << 8) + IINCHIP_READ( Sn_RX_RD1(s) );

    addrbsb = (uint32)(ptr<<8) + (s<<5) + 0x18;           // 获取接收到的数据的绝对地址
    wiz_read_buf(addrbsb, data, len);                                                     // 通过绝对地址，将接收到的数据发给MCU

    // 更新Sn_RX_RD寄存器的值
    ptr += len;                                                                                                             //
    IINCHIP_WRITE( Sn_RX_RD0(s), (uint8)((ptr & 0xff00) >> 8));
    IINCHIP_WRITE( Sn_RX_RD1(s), (uint8)(ptr & 0x00ff));
}

void setSn_IR(uint8 s, uint8 val)
{
    IINCHIP_WRITE(Sn_IR(s), val);
}




