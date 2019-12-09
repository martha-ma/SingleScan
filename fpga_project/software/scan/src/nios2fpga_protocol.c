/*
 * nios2fpga_protocol.c
 *
 *  Created on: 2018-3-28
 *      Author: wj
 */

#include "nios2fpga_protocol.h"

UpDataFrame     CycleData;
NIOS2FPGA_Pck_t Nios2FPGA_pck;

static unsigned int check_sum(unsigned int *data, unsigned char len)
{
    int          i;
    unsigned int checksum = 0;
    for(i = 0; i < len; i++)
    {
        checksum ^= data[i];
    }

    return checksum;
}

void motor_init()
{
}

/*
 * 鎵撳寘鏁版嵁骞跺彂閫�
 */
void nios2fpga_data_packet(unsigned short command, unsigned char len, unsigned int *src)
{
    int          i;
    unsigned int buf[30];
    buf[0] = (0x1234 << 16) + command;
    buf[1] = len;

    for(i = 0; i < len; i++)
    {
        buf[i + 2] = src[i];
    }
    buf[len + 2] = check_sum(buf, len + 2);

    nios2fpga_data_write(buf, len + 3);
}

/*
 * niso 鏁版嵁閫氳繃fifo鍐欏埌 FPGA
 */
bool nios2fpga_data_write(unsigned int *data, unsigned int len)
{
    int i;
    for(i = 0; i < len; i++)
    {
        altera_avalon_fifo_write_fifo(PROTOCOL_FIFO_IN_BASE, PROTOCOL_FIFO_IN_CSR_BASE, (data[i] >> 16) + (data[i] << 16));
        // usleep(1000);
    }
    return true;
}

void set_laser_paramter(NIOS2FPGA_Pck_t *pck, unsigned short command, unsigned int data)
{
    unsigned char len = 1;
    pck->command      = command;
    nios2fpga_data_packet(pck->command, len, &data);
}

void init_fpga_sys(void)
{
    set_laser_paramter(&Nios2FPGA_pck, UPLOAD_EN, ENABLE);
    set_laser_paramter(&Nios2FPGA_pck, LASER_ENABLE, SysPara.laser_enable);
    set_laser_paramter(&Nios2FPGA_pck, LASER_FREQ, SysPara.laser_freq);
    set_laser_paramter(&Nios2FPGA_pck, LASER_PULSE_WIDTH, SysPara.laser_pulse_width);
    set_laser_paramter(&Nios2FPGA_pck, LASER_RECV_DELAY, SysPara.laser_recv_delay);
    set_laser_paramter(&Nios2FPGA_pck, MOTOR_ENABLE, SysPara.motor_enable);
    set_laser_paramter(&Nios2FPGA_pck, MOTOR_SPEED, SysPara.motor_expect_speed);
    set_laser_paramter(&Nios2FPGA_pck, ZERO_DISTANCE_REVISE, SysPara.zero_distance_revise);
    set_laser_paramter(&Nios2FPGA_pck, ZERO_ANGLE_REVISE, SysPara.zero_angle_revise);
    set_laser_paramter(&Nios2FPGA_pck, GRAY_DISTANCE_REVISE1, SysPara.gray_distance_revise1);
    set_laser_paramter(&Nios2FPGA_pck, GRAY_DISTANCE_REVISE2, SysPara.gray_distance_revise2);
    set_laser_paramter(&Nios2FPGA_pck, GRAY_DISTANCE_REVISE3, SysPara.gray_distance_revise3);
    set_laser_paramter(&Nios2FPGA_pck, GRAY_DISTANCE_REVISE4, SysPara.gray_distance_revise4);
    set_laser_paramter(&Nios2FPGA_pck, GRAY_DISTANCE_REVISE5, SysPara.gray_distance_revise5);
    set_laser_paramter(&Nios2FPGA_pck, GRAY_INFLECTION1, SysPara.gray_inflection1);
    set_laser_paramter(&Nios2FPGA_pck, GRAY_INFLECTION2, SysPara.gray_inflection2);
    set_laser_paramter(&Nios2FPGA_pck, GRAY_INFLECTION3, SysPara.gray_inflection3);
    set_laser_paramter(&Nios2FPGA_pck, GRAY_INFLECTION4, SysPara.gray_inflection4);
    set_laser_paramter(&Nios2FPGA_pck, NOISE_DIFF_SETTING1, SysPara.noise_diff_setting1);
    set_laser_paramter(&Nios2FPGA_pck, NOISE_DIFF_SETTING2, SysPara.noise_diff_setting2);

    set_laser_paramter(&Nios2FPGA_pck, APD_VOL_SETTING, SysPara.signal_thresold);
    set_laser_paramter(&Nios2FPGA_pck, APD_VOL_SETTING, SysPara.apd_vol_base);

    set_laser_paramter(&Nios2FPGA_pck, TEMP_VOL_COF1, SysPara.temp_volt_cof1);
    set_laser_paramter(&Nios2FPGA_pck, TEMP_VOL_COF2, SysPara.temp_volt_cof2);
    set_laser_paramter(&Nios2FPGA_pck, TEMP_VOL_INFLECTION, SysPara.temp_volt_inflection);
    set_laser_paramter(&Nios2FPGA_pck, TEMP_DISTANCE_COF1, SysPara.temp_distance_cof1);
    set_laser_paramter(&Nios2FPGA_pck, TEMP_DISTANCE_COF2, SysPara.temp_distance_cof2);
    set_laser_paramter(&Nios2FPGA_pck, TEMP_DISTANCE_INFLECTION, SysPara.temp_distance_inflection);
    set_laser_paramter(&Nios2FPGA_pck, MIN_DISTANCE_VALUE, SysPara.min_display_distance);
    set_laser_paramter(&Nios2FPGA_pck, FIRST_NOISE_FILTER, SysPara.first_noise_filter);

    set_laser_paramter(&Nios2FPGA_pck, DA_CYCLE_PARA1, SysPara.da_cycle_para1);
    set_laser_paramter(&Nios2FPGA_pck, DA_CYCLE_PARA2, SysPara.da_cycle_para2);
    set_laser_paramter(&Nios2FPGA_pck, DA_CYCLE_PARA3, SysPara.da_cycle_para3);
    set_laser_paramter(&Nios2FPGA_pck, DA_CYCLE_PARA4, SysPara.da_cycle_para4);
    set_laser_paramter(&Nios2FPGA_pck, DA_CYCLE_PARA5, SysPara.da_cycle_para5);
    set_laser_paramter(&Nios2FPGA_pck, DA_CYCLE_PARA6, SysPara.da_cycle_para6);
    set_laser_paramter(&Nios2FPGA_pck, DA_CYCLE_PARA7, SysPara.da_cycle_para7);
    set_laser_paramter(&Nios2FPGA_pck, DA_CYCLE_PARA8, SysPara.da_cycle_para8);
    set_laser_paramter(&Nios2FPGA_pck, DA_CYCLE_PARA9, SysPara.da_cycle_para9);
    set_laser_paramter(&Nios2FPGA_pck, MIN_TARGET_SIZE, SysPara.min_target_size);
    set_laser_paramter(&Nios2FPGA_pck, ALARM_OUTPUT_THRESHOLD, SysPara.alarm_output_threshold);
    set_laser_paramter(&Nios2FPGA_pck, PC_SET_HW_TYPE, SysPara.board_type);
    write_laser_presdo(SysPara.laser_presdo);
}

void close_peripheral_dev(void)
{
#ifdef RELEASE_VERSION
    SysPara.motor_enable = DISABLE;
    set_laser_paramter(&Nios2FPGA_pck, MOTOR_ENABLE, DISABLE);
    set_laser_paramter(&Nios2FPGA_pck, UPLOAD_EN, DISABLE);
    // set_laser_paramter(&Nios2FPGA_pck, LASER_ENABLE, DISABLE);
    // set_laser_paramter(&Nios2FPGA_pck, APD_VOL_SETTING, 550);
#endif
}

void write_laser_presdo(unsigned char *arr)
{
    int          i;
    unsigned int data;
    data = 0x1234a104;

    altera_avalon_fifo_write_fifo(PROTOCOL_FIFO_IN_BASE, PROTOCOL_FIFO_IN_CSR_BASE, (data >> 16) + (data << 16));
    data = 30;
    altera_avalon_fifo_write_fifo(PROTOCOL_FIFO_IN_BASE, PROTOCOL_FIFO_IN_CSR_BASE, (data >> 16) + (data << 16));

    //    data = 0x1000;
    for(i = 0; i < sizeof(SysPara.laser_presdo); i = i + 4)
    {
        data = (arr[i] << 24) + (arr[i + 1] << 16) + (arr[i + 2] << 8) + (arr[i + 3] << 0);
        altera_avalon_fifo_write_fifo(PROTOCOL_FIFO_IN_BASE, PROTOCOL_FIFO_IN_CSR_BASE, (data >> 16) + (data << 16));
    }
    data = 0xccccdddd;
    altera_avalon_fifo_write_fifo(PROTOCOL_FIFO_IN_BASE, PROTOCOL_FIFO_IN_CSR_BASE, (data >> 16) + (data << 16));
}
