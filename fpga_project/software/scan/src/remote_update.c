#include "remote_update.h"

update_t image;

int image_write(int addr, unsigned char *data)
{
    int           block_addr;
    int           offset;
    int           ret_code;
    alt_flash_fd *fd;

    block_addr = (int)(addr / EPCS_BLOCK_SIZE) * EPCS_BLOCK_SIZE;
    offset     = addr % EPCS_BLOCK_SIZE;
    fd         = alt_flash_open_dev(EPCS_FLASH_NAME);
    if(!fd)
        return 0;
    else
    {
        ret_code = alt_write_flash_block(fd, block_addr, block_addr + offset, data, 256);
        alt_flash_close_dev(fd);
        return ret_code;
    }
}

int image_read(int addr, unsigned char *data)
{
    int           ret_code;
    alt_flash_fd *fd;

    fd = alt_flash_open_dev(EPCS_FLASH_NAME);
    if(!fd)
        return 0;
    else
    {
        ret_code = alt_read_flash(fd, addr, data, 256);
        alt_flash_close_dev(fd);

        return ret_code;
    }
}

int image_erase(int block_offset)
{
    int           ret_code;
    alt_flash_fd *fd;

    fd = alt_flash_open_dev(EPCS_FLASH_NAME);
    if(!fd)
        return 0;
    else
    {
        ret_code = alt_erase_flash_block(fd, block_offset * EPCS_BLOCK_SIZE, EPCS_BLOCK_SIZE);
        alt_flash_close_dev(fd);
        return ret_code;
    }
}
