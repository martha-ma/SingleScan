/*
 * communicate_pc.c
 *
 *  Created on: 2018-3-28
 *      Author: wj
 */
// 完成和上位的通讯，协议解析相关功能

#include "pc2dev.h"
#include "bsp.h"
#include "iic.h"
#include "region.h"
#include "sick_protocol.h"

unsigned char send_buffer[8448];  // 定义一个2KB的数组，用来存放Socket的通信数据
/*
 *转发pc数据到fpga
 */
bool pc_data_to_fpga(unsigned int *data, unsigned int len)
{
    int i;
    for(i = 0; i < len; i++)
    {
        // nios 采用小端格式，char 数组 转 unsigned int 数组， 字节顺序会颠倒
        data[i] = ((data[i] & 0xff000000) >> 24) | ((data[i] & 0x00ff0000) >> 8) | ((data[i] & 0x0000ff00) << 8) | ((data[i] & 0x000000ff) << 32);

        altera_avalon_fifo_write_fifo(PROTOCOL_FIFO_IN_BASE, PROTOCOL_FIFO_IN_CSR_BASE, (data[i] >> 16) + (data[i] << 16));
    }
    return true;
}

void pc2dev_parse(SOCKET s, unsigned char *buf, int len)
{
    int            i;
    int            send_len;
    unsigned short recv_pos;
    unsigned int   para;        // PC 传给 nios 的参数值
    int            packet_len;  // buf里可能有多包数据，本包数据长度

    while(len != 0)
    {
        if(buf[0] == 0x02)  // 命令属于tim561协议
        {
            sick_protocol_process(s, buf, len);
            len = 0;
        }
        else  // 自定义协议
        {
            para = (buf[8] << 24) + (buf[9] << 16) + (buf[10] << 8) + buf[11];
            /*
             *
             */
            pc2nios.head     = (buf[0] << 8) + buf[1];
            pc2nios.command  = (buf[2] << 8) + buf[3];
            pc2nios.data_len = (buf[4] << 24) + (buf[5] << 16) + (buf[6] << 8) + (buf[7]);
            SysPara.pc_command_value++;

            switch(pc2nios.command)
            {
                // 设置使用那个报警区域，这个值会写到E2PROM，每次设置值都会有3bit为1
                // 从E2PROM里读出报警区域数据，作为比较
                case PC_SET_ALARM_REGION:
                    alarm_region.select = para;

                    if(alarm_region.select <= 15)  // 范围保护
                    {
                        eeprom_write_byte(CUR_ALARM_GROUP + 2, buf[10]);
                        eeprom_write_byte(CUR_ALARM_GROUP + 3, buf[11]);
                    }
                    else
                        return;
                    //  接受到设置后, 从E2PROM里读出之前的设置数据
                    region_read_from_rom(&alarm_region, alarm_region.select * 3 + 0);
                    region_read_from_rom(&alarm_region, alarm_region.select * 3 + 1);
                    region_read_from_rom(&alarm_region, alarm_region.select * 3 + 2);
                    break;
                case PC_READ_ALARM_REGION:
                    if(para <= 15)
                    {
                        nios2pc.command  = NIOS_UP_ALARM_REGION;
                        nios2pc.data_len = 4;
                        send_len         = pc2dev_packet(&nios2pc, send_buffer);
                        send(s, send_buffer, send_len);
                    }
                    break;
                case PC_LOAD_REGION_DATA:
                    // 下传区域边界数据,写入E2PROM的时候,同时写入
                    alarm_region.wr_which = buf[8];
                    for(i = 0; i < TARGET_NUMBER * 2; i = i + 2)
                    {
                        recv_pos                    = (buf[i + 9] << 8) + buf[i + 1 + 9];
                        alarm_region.buffer[i >> 1] = recv_pos;
                    }
                    // 8+1+TARGET_NUMBER*2 		+ 1 + 102
                    for(i = 0; i < ZENITH_NUMBER; i++)
                    {
                        alarm_region.zenith_save[i] = buf[1631 + i];
                    }
                    // 异或值暂不读取
                    if(SysPara.update_pos_flag)
                    {
                        set_laser_paramter(&Nios2FPGA_pck, UPLOAD_EN, DISABLE);
                        region_save2eeprom(&alarm_region);
                        set_laser_paramter(&Nios2FPGA_pck, UPLOAD_EN, ENABLE);
                    }
                    else
                        region_save2eeprom(&alarm_region);
                    // 如果当前开关输入量的值和修改区域的值一样，才去修改FPGA内报警区域值
                    if(alarm_region.change_region_value == alarm_region.wr_which / 3)
                        alarm_region.change_region_flag = 0x01;
                    break;
                case PC_REQ_REGION_DATA:
                    alarm_region.rd_which = (unsigned char)para;
                    nios2pc.command       = NIOS_UP_REGION_DATA;
                    nios2pc.data_len      = 1 + TARGET_NUMBER * 2 + ZENITH_NUMBER;
                    send_len              = pc2dev_packet(&nios2pc, send_buffer);
                    send(s, send_buffer, send_len);
                    break;
                case PC_REQ_RADAR_PARA:  // 请求系统状态参数
                    nios2pc.command  = NIOS_UP_RADAR_PARA;
                    nios2pc.data_len = sizeof(SysPara);
                    send_len         = pc2dev_packet(&nios2pc, send_buffer);
                    send(s, send_buffer, send_len);

                    set_laser_paramter(&Nios2FPGA_pck, 0xc000, 0xaaaa);
                    break;
                case PC_SET_HW_TYPE:
                    SysPara.board_type = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case PC_SAVA_SYS_PARA:
                    save_sys_para(&SysPara);
                    break;
                case PC_RESET_NIOS:
                    SysStatus.reset_nios = para;
                    break;
                case PC_SET_SN:
                    memset(SysPara.dev_sn, 0, sizeof(SysPara.dev_sn));
                    memcpy(SysPara.dev_sn, &buf[8], sizeof(SysPara.dev_sn));
                    break;
                case PC_SET_DEV_TYPE:
                    memset(SysPara.dev_type, 0, sizeof(SysPara.dev_type));
                    memcpy(SysPara.dev_type, &buf[8], sizeof(SysPara.dev_type));
                    break;
                case PC_SET_DUST_THRESHOLD:
                    SysPara.dust_threshold = para;
                    break;
                case LASER_ENABLE:
                    if((para == ENABLE) || (para == DISABLE))
                    {
                        SysPara.laser_enable = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case LASER_FREQ:
                    SysPara.laser_freq = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case LASER_PULSE_WIDTH:
                    if((para >= 3) && (para <= 10))
                    {
                        SysPara.laser_pulse_width = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case LASER_PRESDO:
                    memset(SysPara.laser_presdo, 0, sizeof(SysPara.laser_presdo));
                    memcpy(SysPara.laser_presdo, &buf[8], sizeof(SysPara.laser_presdo));
                    break;
                case LASER_RECV_DELAY:
                    if(para <= 16)
                    {
                        SysPara.laser_recv_delay = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case MOTOR_ENABLE:
                    if((para == ENABLE) || (para == DISABLE))
                    {
                        SysPara.motor_enable = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case MOTOR_SPEED:
                    if((para >= 8) && (para <= 15))
                    {
                        SysPara.motor_expect_speed = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case ZERO_DISTANCE_REVISE:
                    if(para <= 1024)
                    {
                        SysPara.zero_distance_revise = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case ZERO_ANGLE_REVISE:
                    if((para >= 2) && (para <= 240))
                    {
                        SysPara.zero_angle_revise = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case GRAY_DISTANCE_REVISE1:
                    SysPara.gray_distance_revise1 = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case GRAY_DISTANCE_REVISE2:
                    SysPara.gray_distance_revise2 = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case GRAY_DISTANCE_REVISE3:
                    SysPara.gray_distance_revise3 = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case GRAY_DISTANCE_REVISE4:
                    SysPara.gray_distance_revise4 = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case GRAY_DISTANCE_REVISE5:
                    SysPara.gray_distance_revise5 = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case GRAY_INFLECTION1:
                    SysPara.gray_inflection1 = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case GRAY_INFLECTION2:
                    SysPara.gray_inflection2 = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case GRAY_INFLECTION3:
                    SysPara.gray_inflection3 = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case GRAY_INFLECTION4:
                    SysPara.gray_inflection4 = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case NOISE_DIFF_SETTING1:
                    SysPara.noise_diff_setting1 = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;
                case NOISE_DIFF_SETTING2:
                    SysPara.noise_diff_setting2 = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    break;

                case SIGNAL_THRESHOLD:
                    if(para <= 1024)
                    {
                        SysPara.signal_thresold = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case APD_VOL_SETTING:
                    if((para & 0x3f) <= 1024)
                    {
                        if((para >> 15 & 0x01) == 0x01)
                            SysPara.signal_thresold = para;
                        else
                            SysPara.apd_vol_base = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case TEMP_VOL_COF1:
                    if((para >= 20) && (para <= 45))
                    {
                        SysPara.temp_volt_cof1 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case TEMP_VOL_COF2:
                    if((para >= 20) && (para <= 45))
                    {
                        SysPara.temp_volt_cof2 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case TEMP_VOL_INFLECTION:
                    if(para <= 50)
                    {
                        SysPara.temp_volt_inflection = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case TEMP_DISTANCE_COF1:
                    if(para <= 128)
                    {
                        SysPara.temp_distance_cof1 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;

                case TEMP_DISTANCE_COF2:
                    if(para <= 128)
                    {
                        SysPara.temp_distance_cof2 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case TEMP_DISTANCE_INFLECTION:
                    if(para <= 60)
                    {
                        SysPara.temp_distance_inflection = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case VALID_NUM_THRESHOLD:
                    if((para > 1) && (para < 40))
                    {
                        SysPara.valid_num_threshold = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case MIN_DISTANCE_VALUE:
                    if(para <= 500)
                    {
                        SysPara.min_display_distance = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case FIRST_NOISE_FILTER:
                    if((para >= 2) && (para <= 12))
                    {
                        SysPara.first_noise_filter = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case DUST_ALARM_THRESHOLD:
                    if(para <= 100)
                    {
                        SysPara.dust_alarm_threshold = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;

                case DA_CYCLE_PARA1:
                    if(para <= 1023)
                    {
                        SysPara.da_cycle_para1 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case DA_CYCLE_PARA2:
                    if(para <= 1023)
                    {
                        SysPara.da_cycle_para2 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case DA_CYCLE_PARA3:
                    if(para <= 1023)
                    {
                        SysPara.da_cycle_para3 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case DA_CYCLE_PARA4:
                    if(para <= 1023)
                    {
                        SysPara.da_cycle_para4 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case DA_CYCLE_PARA5:
                    if(para <= 1023)
                    {
                        SysPara.da_cycle_para5 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case DA_CYCLE_PARA6:
                    if(para <= 1023)
                    {
                        SysPara.da_cycle_para6 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case DA_CYCLE_PARA7:
                    if(para <= 1023)
                    {
                        SysPara.da_cycle_para7 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case DA_CYCLE_PARA8:
                    if(para <= 1023)
                    {
                        SysPara.da_cycle_para8 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case DA_CYCLE_PARA9:
                    if(para <= 1023)
                    {
                        SysPara.da_cycle_para9 = para;
                        set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                    }
                    break;
                case MIN_TARGET_SIZE:
                	if((para >= 0) && (para <= 8000))
                	{
                    SysPara.min_target_size = para;
                    set_laser_paramter(&Nios2FPGA_pck, pc2nios.command, para);
                	}
                    break;

                case PC_REMOTE_UPDATE_WRITE:
                    image.addr = (buf[8] << 24) + (buf[9] << 16) + (buf[10] << 8) + (buf[11]);
                    memcpy(image.data, &buf[12], 256);
                    image_write(image.addr, image.data);

                    image_read(image.addr, image.data);
                    nios2pc.command  = NIOS_REMOTE_WRITE_REPONSE;
                    nios2pc.data_len = 4 + 256;
                    send_len         = pc2dev_packet(&nios2pc, send_buffer);
                    send(s, send_buffer, send_len);
                    break;
                case PC_REMOTE_UPDATE_READ:
                    image.addr = (buf[8] << 24) + (buf[9] << 16) + (buf[10] << 8) + (buf[11]);
                    image_read(image.addr, image.data);

                    nios2pc.command  = NIOS_UP_REMOTE_UPDATE_IMAGE;
                    nios2pc.data_len = 4 + 256;
                    send_len         = pc2dev_packet(&nios2pc, send_buffer);
                    send(s, send_buffer, send_len);
                    break;
                case PC_REMOTE_UPDATE_ERASE:
                    for(i = 0; i < para; i++)
                        image_erase(i);
                    break;
                default:
                    break;
            }
            packet_len = pc2nios.data_len + 12;
            len        = len - packet_len;
            buf        = buf + packet_len;
            // nios2pc.command = NIOS_UP_RESPONSE_PC;
            // nios2pc.data_len = 4;
            // send_len = pc2dev_packet(&nios2pc, send_buffer);
            // send(s, send_buffer, send_len);
        }
    }
}

/**
 * @brief 将data里的command打包到buf里，准备发送给上位机
 * @param data
 * @param buf
 * @return int 打包后要发送给上位机的字节数
 */
int pc2dev_packet(struct __nios2pc *data, unsigned char *buf)
{
    int           i;
    int           offset_addr;
    int           buf_len;
    unsigned char checksum;
    unsigned char temp;
    buf[0] = (data->head >> 8) & 0xff;
    buf[1] = (data->head >> 0) & 0xff;
    buf[2] = (data->command >> 8) & 0xff;
    buf[3] = (data->command >> 0) & 0xff;

    buf[4] = (data->data_len >> 24) & 0xff;  // 数据长度
    buf[5] = (data->data_len >> 16) & 0xff;
    buf[6] = (data->data_len >> 8) & 0xff;
    buf[7] = (data->data_len >> 0) & 0xff;

    switch(data->command)
    {
        case NIOS_UP_ALARM_REGION:
            offset_addr = CUR_ALARM_GROUP;
            for(i = 0; i < data->data_len; i++)
            {
                buf[i + 8] = eeprom_read_byte(offset_addr + i);
            }
            buf[8]   = 0x00;
            buf[9]   = 0x00;
            buf[10]  = 0x00;
            buf[11]  = alarm_region.change_region_value;
            checksum = 0;
            for(i = 0; i < 8 + data->data_len; i++)
            {
                checksum ^= buf[i];
            }
            buf[8 + data->data_len + 0] = 0x00;
            buf[8 + data->data_len + 1] = 0x00;
            buf[8 + data->data_len + 2] = 0x00;
            buf[8 + data->data_len + 3] = checksum;

            buf_len = (8 + data->data_len + 4);
            break;
        case NIOS_UP_REGION_DATA:
            // 8 + TARGET_NUMBER*2 + 1 + 102
            offset_addr = GROUP_OFFSET_ADDR + alarm_region.rd_which * REGION_SPACE_SIZE;
            buf[8]      = alarm_region.rd_which;
            buf_len     = 9;
            eeprom_sequential_read(offset_addr, buf + 9, TARGET_NUMBER * 2 + 1 + 102);
            for(i = 9; i < 9 + TARGET_NUMBER * 2; i += 2)
            {
                temp       = buf[i + 1];
                buf[i + 1] = buf[i];
                buf[i]     = temp;
            }

            buf_len += TARGET_NUMBER * 2 + 1 + 102;

            checksum = 0;
            for(i = 0; i < buf_len; i++)
            {
                checksum ^= buf[i];
            }
            buf[buf_len + 1] = 0x00;
            buf[buf_len + 2] = 0x00;
            buf[buf_len + 3] = 0x00;
            buf[buf_len + 4] = checksum;
            buf_len += 4;
            break;
        case NIOS_UP_RESPONSE_PC:
            buf[8]  = (SysPara.pc_command_value >> 24) & 0xff;
            buf[9]  = (SysPara.pc_command_value >> 16) & 0xff;
            buf[10] = (SysPara.pc_command_value >> 8) & 0xff;
            buf[11] = (SysPara.pc_command_value >> 0) & 0xff;
            for(i = 0; i < 12; i++)
            {
                checksum ^= buf[i];
            }
            buf[12] = 0;
            buf[13] = 0;
            buf[14] = 0;
            buf[15] = checksum;
            buf_len = 16;
            break;
        case NIOS_UP_RADAR_PARA:
            memcpy(&buf[8], (unsigned char *)&SysPara, sizeof(SysPara));
            for(i = 0; i < 8 + sizeof(SysPara); i++)
            {
                checksum ^= buf[i];
            }
            buf[8 + sizeof(SysPara) + 0] = 0xaa;
            buf[8 + sizeof(SysPara) + 1] = 0xbb;
            buf[8 + sizeof(SysPara) + 2] = 0xcc;
            buf[8 + sizeof(SysPara) + 3] = checksum;
            buf_len                      = 8 + sizeof(SysPara) + 4;
            break;
        case NIOS_REMOTE_WRITE_REPONSE:
        case NIOS_UP_REMOTE_UPDATE_IMAGE:
            buf[8]  = (image.addr >> 24) & 0xff;
            buf[9]  = (image.addr >> 16) & 0xff;
            buf[10] = (image.addr >> 8) & 0xff;
            buf[11] = (image.addr >> 0) & 0xff;
            memcpy(&buf[12], image.data, 256);
            for(i = 0; i < 8 + 4 + 256; i++)
                checksum ^= buf[i];
            buf[272] = buf[273] = buf[274] = 0;
            buf[275]                       = checksum;
            buf_len                        = 8 + 4 + 256 + 4;
            break;
        default:
            buf[8]  = (data->value >> 24) & 0xff;
            buf[9]  = (data->value >> 16) & 0xff;
            buf[10] = (data->value >> 8) & 0xff;
            buf[11] = (data->value >> 0) & 0xff;
            for(i = 0; i < 12; i++)
            {
                checksum ^= buf[i];
            }
            buf[12] = 0;
            buf[13] = 0;
            buf[14] = 0;
            buf[15] = checksum;
            buf_len = 16;
            break;
    }

    return buf_len;
}

pc2nios_t pc2nios = {.head = 0x1234};

nios2pc_t nios2pc = {.head = 0x1234};
