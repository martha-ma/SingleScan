#include "sick_protocol.h"
char frame_start[] =
    "sSI 5A 1 1 103B7B4 0 0 9D9 9DD B3E30A9 B3E44BC 0 0 1 0 0 5DC A2 0 2 DIST1 "
    "3F800000 00000000 FFF92230 D05 32B";

char RSSI_Field_start[] = " RSSI1 3F800000 00000000 FFF92230 D05 32B";
char RSSI_Field_end[]   = " 0 0 0 0 0 0";

unsigned char sMI_3E_flag = 0;

/**
 * @brief hex字符串转换成16进制数据，放到发送缓冲区里
 * s = "123456abcd"  --->  0x12 0x34 0x56 0xab 0xcd
 *
 * @param src 源字符串
 * @param len 源字符串长度
 * @param dest
 */
static void string2hex(const char *src, int len, char *dest)
{
    int  i;
    char data[2];
    for(i = 0; i < len; i++)
    {
        data[0] = *src++;  // 取出前面2个字符
        data[1] = *src++;
        //        *dest = strtol(data, &pEnd, 16);
        *dest = ((data[0] - 0x30) << 4) + (data[1] - 0x30);
        dest++;
    }
}

static int find_index(char *str, int str_len, char **array, int length)
{
    int i;
    int len;
    for(i = 0; i < length; i++)
    {
        len = strlen(array[i]);
        if(strncmp(str, array[i], str_len) == 0 && (len == str_len))
            return i;
    }
    return -1;
}

void sick_protocol_process(SOCKET s, unsigned char *buf, int len)
{
    int            send_len;
    int            i;
    unsigned char  enable_flag  = 0;  //  enable = 1, 上传数据， enable = 2 停止上传数据
    unsigned char *recv_command = buf + 1;
    int            pos          = 0;
    pos                         = find_index((char *)recv_command, len - 2, tim561_index, 572);
    if(pos != -1)  // 命令属于tim561协议
    {
        /*
         *  "sMI 0 3 F4724744" , "sMI 2"需要回复很多命令，需要特殊处理
         */
        if(strncmp((char *)recv_command, "sMI 0 3 F4724744", strlen((char *)"sMI 0 3 F4724744")) == 0)
        {
            if(SysPara.update_pos_flag == false)  //   没有上传数据时，sops软件电机点击stop measure响应下面数据
            {
                for(i = 0; i < 2; i++)
                {
                    send_len = strlen(sMI_0_3_F4724744_start[i]);
                    memcpy(send_buffer + 1, sMI_0_3_F4724744_start[i], send_len);
                    send_buffer[0]            = 0x02;
                    send_buffer[send_len + 1] = 0x03;
                    send(s, send_buffer, send_len + 2);
                }
            }
            else  // 上传数据
            {
                for(i = 0; i < 4; i++)
                {
                    send_len = strlen(sMI_0_3_F4724744_stop[i]);
                    memcpy(send_buffer + 1, sMI_0_3_F4724744_stop[i], send_len);
                    send_buffer[0]            = 0x02;
                    send_buffer[send_len + 1] = 0x03;
                    send(s, send_buffer, send_len + 2);
                }
            }
        }

        else if(strncmp((char *)recv_command, "sMI 2", strlen((char *)"sMI 2")) == 0)
        {
            // if(SysStatus.update_pos_flag == false)
            if(sMI_3E_flag == 1)
            {
                for(i = 0; i < 11; i++)
                {
                    send_len = strlen(sMI_reply[i]);
                    memcpy(send_buffer + 1, sMI_reply[i], send_len);
                    send_buffer[0]            = 0x02;
                    send_buffer[send_len + 1] = 0x03;
                    send(s, send_buffer, send_len + 2);
                }
                enable_flag = 1;
            }
            else
            {
                send_len = strlen(sMI_reply[0]);
                memcpy(send_buffer + 1, sMI_reply[0], send_len);
                send_buffer[0]            = 0x02;
                send_buffer[send_len + 1] = 0x03;
                send(s, send_buffer, send_len + 2);
                enable_flag = 2;
            }
        }
        /*
         * 正常的tim561协议中，数据分成两种：ascii格式和hex格式
         * 只需要从对应的表中找到需要回复的字符串响应上去就可以了
         */
        else if(tim561_respons[pos][0] == 0x30)  // hex字符串
        {
            send_len = strlen(tim561_respons[pos]);
            string2hex(tim561_respons[pos], send_len, (char *)send_buffer);
            send(s, send_buffer, send_len / 2);
        }
        else if(tim561_respons[pos][0] == 0x73)  // 's' 开头， ascii字符串
        {
            send_len = strlen(tim561_respons[pos]);
            memcpy(send_buffer + 1, tim561_respons[pos], send_len);
            send_buffer[0]            = 0x02;
            send_buffer[send_len + 1] = 0x03;
            send(s, send_buffer, send_len + 2);
        }

        if(strncmp((char *)recv_command, "sMI 3E", strlen((char *)"sMI 3E")) == 0)
        {
            sMI_3E_flag = 1;
        }
        else if(strncmp((char *)recv_command, "sMI 3F", strlen((char *)"sMI 3F")) == 0)
        {
            sMI_3E_flag = 0;
        }

        if(strncmp((char *)recv_command, "sRI E6", strlen((char *)"sRI E6")) == 0)  // 长字符串，分开处理
        {
            for(i = 0; i < 5; i++)
            {
                send_len = strlen(sRI_E6_reply[i]);
                string2hex(sRI_E6_reply[i], send_len, (char *)send_buffer);
                send(s, send_buffer, send_len / 2);
            }
        }
        else if(strncmp((char *)recv_command, "sRI 15B", strlen((char *)"sRI 15B")) == 0)
        {
            send_len = strlen(sRI_15B_reply);
            string2hex(sRI_15B_reply, send_len, (char *)send_buffer);
            send(s, send_buffer, send_len / 2);
        }
        else if(strncmp((char *)recv_command, "sRI 1DC", strlen((char *)"sRI 1DC")) == 0)
        {
            send_len = strlen(sRI_1DC_reply);
            string2hex(sRI_1DC_reply, send_len, (char *)send_buffer);
            send(s, send_buffer, send_len / 2);
        }
    }

    if(enable_flag == 1)  // 上传数据
    {
        enable_flag = 0;
        set_laser_paramter(&Nios2FPGA_pck, UPLOAD_EN, ENABLE);
        SysPara.update_pos_flag = true;
    }
    else if(enable_flag == 2)
    {
        enable_flag = 0;
        set_laser_paramter(&Nios2FPGA_pck, UPLOAD_EN, DISABLE);
        SysPara.update_pos_flag = false;
    }
}

void sick_pos_packet(void)
{
    int offset = 0;
    int len    = 0;
    memset(send_buffer, 0, 8448);
    send_buffer[0] = 0x02;

    len = strlen(frame_start);  // 108
    memcpy(send_buffer + 1, frame_start, len);
    offset = offset + len + 1;

    memcpy(send_buffer + offset, CycleData.distance_data,
           CycleData.distance_len);  // 4055
    offset = offset + CycleData.distance_len;

    len = strlen(RSSI_Field_start);                       // 41
    memcpy(send_buffer + offset, RSSI_Field_start, len);  // frame_end放到后面
    offset = offset + len;

    memcpy(send_buffer + offset, CycleData.gray_data,
           CycleData.gray_len);  // 4055
    offset = offset + CycleData.gray_len;

    len = strlen(RSSI_Field_end);                       // 12
    memcpy(send_buffer + offset, RSSI_Field_end, len);  // frame_end放到后面
    offset = offset + len;

    send_buffer[offset] = 0x03;
}
