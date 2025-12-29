#!/bin/sh
set -e
# $1 = target dir, $2 = kernel elf name
dd if=/dev/zero of=$1/floppy.img bs=512 count=1
dd if=$1/bootsector.bin of=$1/floppy.img bs=512 conv=notrunc
dd if=$1/$2 of=$1/floppy.img bs=512 seek=1 conv=notrunc
