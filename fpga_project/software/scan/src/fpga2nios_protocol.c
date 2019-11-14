/*
 * fpga2nios_protocol.c
 *
 *  Created on: 2018-3-27
 *      Author: wj
 */
// 处理从FPGA发送过来的数据

#include "fpga2nios_protocol.h"
#include "bsp.h"
#include "nios2fpga_protocol.h"
#include "region.h"

// PosFrameData laserData;
Fpga_data_packet fpga2nios_data;
Sys_warn sys_warn = {.motor_low_speed_alarm = 0,
                     .ld_not_work_alarm = 0,
                     .window_dust_alarm = 0,
                     .temp_out_alarm = 0,

                     .len = 0};

queue_item_t LaserData[2048];
Queue LaserDataQueue;


static inline unsigned int hex2ascii(unsigned int data)
{
    int tmp31_24 = ((data>>12)&0x0f);
    int tmp23_16 = ((data>> 8)&0x0f);
    int tmp15_08 = ((data>> 4)&0x0f);
    int tmp07_00 = ((data>> 0)&0x0f);

    tmp31_24 =  ( (tmp31_24 >= 0) && (tmp31_24 <= 9) ) ? tmp31_24 + 0x30 : tmp31_24 + 0x37;
    tmp23_16 =  ( (tmp23_16 >= 0) && (tmp23_16 <= 9) ) ? tmp23_16 + 0x30 : tmp23_16 + 0x37;
    tmp15_08 =  ( (tmp15_08 >= 0) && (tmp15_08 <= 9) ) ? tmp15_08 + 0x30 : tmp15_08 + 0x37;
    tmp07_00 =  ( (tmp07_00 >= 0) && (tmp07_00 <= 9) ) ? tmp07_00 + 0x30 : tmp07_00 + 0x37;

    return (tmp31_24<<24) + (tmp23_16<<16) + (tmp15_08<<8) + (tmp07_00<<0);
}

unsigned int big_swap_little(unsigned int data)
{
    data = ((data & 0xff) << 24) | ((data & 0xff00) << 8) | ((data & 0xff0000) >> 8) | ((data & 0xff000000) >> 24);
    return data;
}

bool fpga_is_has_data()
{
    int num = altera_avalon_fifo_read_level(LASER_FIFO_IN_CSR_BASE);

    // fifo 空， empty = 1
    if(num > 0)
        return true;
    else
        return false;
}

// 从FIFO中读出一个数据
inline unsigned int read_fpga_data()
{
    unsigned int data = altera_avalon_fifo_read_fifo(LASER_FIFO_OUT_BASE, LASER_FIFO_IN_CSR_BASE);
    return (data >> 16) + (data << 16);
}

int fpga2nios_parse()
{
    unsigned int i;
    unsigned int num = 0;
    unsigned int recv_data;
    unsigned int distance;
    unsigned int gray;
    char buf[10];

    {
        while(!queue_is_empty(&LaserDataQueue))
        {
        	recv_data = queue_pop(&LaserDataQueue);
			if(recv_data >> 16 == FRAME_HEAD)
			{
				fpga2nios_data.frame_head = (recv_data >> 16) & 0xffff;
				break;
			}
        }

        fpga2nios_data.command = recv_data & 0xffff;
        fpga2nios_data.data_len = queue_pop(&LaserDataQueue);
        if(fpga2nios_data.command == DISTANCE_DATA)
        {
            CycleData.distance_len = 0;
            CycleData.gray_len = 0;
            for(i = 0; i < fpga2nios_data.data_len; i++)
            {
                recv_data = queue_pop(&LaserDataQueue);
                distance = hex2ascii(recv_data);

                buf[0] = 0x20;

                buf[1] = (distance >> 24) & 0xff;
                buf[2] = (distance >> 16) & 0xff;
                buf[3] = (distance >> 8) & 0xff;
                buf[4] = (distance >> 0) & 0xff;
                num = 5;
                
                // num = hex2string(recv_data, buf);
                memcpy(CycleData.distance_data + CycleData.distance_len, buf, num);  // ascii码格式的  +距离数据              
                CycleData.distance_len += num;

                gray = hex2ascii((recv_data>>16) & 0xffff);
                buf[0] = 0x20;
                buf[1] = (gray >> 8) & 0xff;
                buf[2] = (gray >> 0) & 0xff;
                memcpy(CycleData.gray_data + CycleData.gray_len, buf, 3);  
                CycleData.gray_len += 3;
            }
            recv_data = queue_pop(&LaserDataQueue);
            fpga2nios_data.checksum = recv_data;

            if((fpga2nios_data.checksum & 0xfffffff) == 0xeeeeeee)  // bit[27:0], bit[31:28]作为FPGA上传的区域报警标志
            {
                if(SysPara.board_type == 1)       // NPN型, 报警时FPGA IO输出0, 外部才能输出为高
                    sys_warn.region_alarm = ~(fpga2nios_data.checksum >> 28) & 0x07;
                else
                    sys_warn.region_alarm = (fpga2nios_data.checksum >> 28) & 0x07;

                CycleData.pos_finish = true;
            }
            else
            {
                CycleData.pos_finish = false;
                memset(CycleData.distance_data, 0, sizeof(CycleData.distance_data));
                memset(CycleData.gray_data, 0, sizeof(CycleData.gray_data));
            }
            queue_clear(&LaserDataQueue);
        }
        else if(fpga2nios_data.command == UP_FPGA_STATUS)
        {
            sys_warn.len %= 5;
            // for(i = 0; i < fpga_data.data_len; i++)
            {
                recv_data = queue_pop(&LaserDataQueue);
                // CycleData.fpga_status[i] = recv_data;
                if(sys_warn.motor_low_speed_alarm == 0x00)
                    sys_warn.motor_cycle_cnt[sys_warn.len] = recv_data;
                SysPara.motor_real_speed = recv_data;

                recv_data = queue_pop(&LaserDataQueue);
                SysPara.zero_value = recv_data & 0xffff;

                recv_data = queue_pop(&LaserDataQueue);
                if(sys_warn.window_dust_alarm == 0x00)
                    sys_warn.dust_cnt[sys_warn.len] = recv_data;
                SysPara.placeholer1 = recv_data;

                recv_data = queue_pop(&LaserDataQueue); // 最高位作为上传状态
                if(sys_warn.temp_out_alarm == 0x00)
                    sys_warn.temp_value[sys_warn.len] = recv_data & 0xffff;
                SysPara.sys_temp = recv_data & 0xffff;
                SysPara.update_pos_flag = ((recv_data >> 31) & 0x01) ? true : false;
                

                SysPara.zero_pulse_width = queue_pop(&LaserDataQueue);
                if(sys_warn.ld_not_work_alarm == 0x00)
                    sys_warn.zero_value[sys_warn.len] = SysPara.zero_pulse_width;
            }
            sys_warn.len++;
            recv_data = queue_pop(&LaserDataQueue);
            fpga2nios_data.checksum = recv_data;
            if(fpga2nios_data.checksum == 0xeeeeeeee)
            {
                if(sys_warn.len == 5)
                {
                    process_motor_waring(&sys_warn);
                    process_ld_waring(&sys_warn);
                    process_window_dust_waring(&sys_warn);
                    process_sys_temp_waring(&sys_warn);
                }
            }
            queue_clear(&LaserDataQueue);
            if(sys_warn.motor_low_speed_alarm | sys_warn.ld_not_work_alarm | sys_warn.window_dust_alarm | sys_warn.temp_out_alarm)
            {
                send_buffer[0] = 0x12;
                send_buffer[1] = 0x34;
                send_buffer[2] = (UP_FPGA_STATUS >> 8) & 0xff;
                send_buffer[3] = (UP_FPGA_STATUS >> 0) & 0xff;

                send_buffer[4] = 0;
                send_buffer[5] = 0;
                send_buffer[6] = 0;
                send_buffer[7] = 16;
                memcpy(send_buffer + 8, (unsigned char *)&sys_warn, 16);
                send_buffer[24] = send_buffer[25] = send_buffer[26] = send_buffer[27] = 0xee;

                send(SOCKET0, send_buffer, 28);
                send(SOCKET1, send_buffer, 28);
            }
        }
    }
    return -1;
}

/**
 * @brief 连续5次检测电机计数值
 * 
 * @param data 
 */
void process_motor_waring(Sys_warn *data)
{
    if(SysPara.motor_enable == ENABLE)
    {
        if( 
                (data->motor_cycle_cnt[0] >= MOTOR_LOW_SPEED_VALUE) && 
                (data->motor_cycle_cnt[1] >= MOTOR_LOW_SPEED_VALUE) && 
                (data->motor_cycle_cnt[2] >= MOTOR_LOW_SPEED_VALUE) && 
                (data->motor_cycle_cnt[3] >= MOTOR_LOW_SPEED_VALUE) && 
                (data->motor_cycle_cnt[4] >= MOTOR_LOW_SPEED_VALUE)
        )
            data->motor_low_speed_alarm = 0x01;
        else
            data->motor_low_speed_alarm = 0x00;
        }
    else
        data->motor_low_speed_alarm = 0x00;
}

/**
 * @brief 连续5次获得的零位距离值大于设定值，报警
 * 
 * @param data 
 */
void process_ld_waring(Sys_warn *data)
{
    if( 
            (data->zero_value[0] < LD_NO_WORK_VALUE) && 
            (data->zero_value[1] < LD_NO_WORK_VALUE) && 
            (data->zero_value[2] < LD_NO_WORK_VALUE) && 
            (data->zero_value[3] < LD_NO_WORK_VALUE) && 
            (data->zero_value[4] < LD_NO_WORK_VALUE)
      )
        data->ld_not_work_alarm = 0x01;
    else
        data->ld_not_work_alarm = 0x00;
}

/**
 * @brief 连续5次的灰尘计数值大于设定值，报警
 * 
 * @param data 
 */
void process_window_dust_waring(Sys_warn *data)
{
    if( 
            (data->dust_cnt[0] > SysPara.dust_threshold) && 
            (data->dust_cnt[1] > SysPara.dust_threshold) && 
            (data->dust_cnt[2] > SysPara.dust_threshold) && 
            (data->dust_cnt[3] > SysPara.dust_threshold) && 
            (data->dust_cnt[4] > SysPara.dust_threshold)
      )
        data->window_dust_alarm = 0x01;
    else
        data->window_dust_alarm = 0x00;
}


void process_sys_temp_waring(Sys_warn *data)
{
    int i;
    unsigned char sign_bit = 0;

    for(i = 0; i < 5; i++)
    {
        sign_bit = (data->temp_value[i] >> 13) & 0x01;
        if(sign_bit == 0)  // 温度是正值
        {
            if((data->temp_value[i] & 0x00ff) > TEMP_OUT_VALUE)
                data->temp_out_alarm = 0x01;
            else
                data->temp_out_alarm = 0x00;
        }
        else
        {
            if((data->temp_value[i] & 0x00ff) > 20)
                data->temp_out_alarm = 0x01;
            else
                data->temp_out_alarm = 0x00;
        }
    }
}
