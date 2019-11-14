#include "altera_avalon_epcs_flash_controller.h"
#include "sys/alt_flash.h"

#include "system.h"

#define EPCS_BLOCK_SIZE 65536

#define PC_REMOTE_UPDATE_WRITE 0x4100
#define PC_REMOTE_UPDATE_READ 0x4101
#define PC_REMOTE_UPDATE_ERASE 0x4102
#define NIOS_REMOTE_WRITE_REPONSE 0x5100
#define NIOS_UP_REMOTE_UPDATE_IMAGE 0x5101

typedef struct __update
{
    unsigned int  addr;
    unsigned char data[256];
} update_t;
// extern update_t  var;
// 上面的放到.h文件，下面的放到.c文件
// update_t var = {
//  .var1 = 0x01
//}

extern update_t image;

/**
 * @brief
 *
 * @param addr
 * @param data
 *
 * @return
 */
int image_write(int addr, unsigned char *data);
int image_read(int addr, unsigned char *data);
int image_erase(int block_offset);
