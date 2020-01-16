#!/bin/sh
#
# This file was automatically generated.
#
# It can be overwritten by nios2-flash-programmer-generate or nios2-flash-programmer-gui.
#

#
# Converting SOF File: E:\work\SingleScan\fpga_project\output_files\SingleScan.sof to: "..\flash/SingleScan_epcs_flash.flash"
#
sof2flash --input="E:/work/SingleScan/fpga_project/output_files/SingleScan.sof" --output="../flash/SingleScan_epcs_flash.flash" --epcs --verbose 

#
# Programming File: "..\flash/SingleScan_epcs_flash.flash" To Device: epcs_flash
#
nios2-flash-programmer "../flash/SingleScan_epcs_flash.flash" --base=0x81000 --epcs --sidp=0x821F0 --id=0x12345 --accept-bad-sysid --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --override=nios2-flash-override.txt

#
# Converting ELF File: E:\work\SingleScan\fpga_project\software\scan\scan.elf to: "..\flash/scan_epcs_flash.flash"
#
elf2flash --input="E:/work/SingleScan/fpga_project/software/scan/scan.elf" --output="../flash/scan_epcs_flash.flash" --epcs --after="../flash/SingleScan_epcs_flash.flash" --verbose 

#
# Programming File: "..\flash/scan_epcs_flash.flash" To Device: epcs_flash
#
nios2-flash-programmer "../flash/scan_epcs_flash.flash" --base=0x81000 --epcs --sidp=0x821F0 --id=0x12345 --accept-bad-sysid --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --override=nios2-flash-override.txt

