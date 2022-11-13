#!/bin/sh

# This script assembles the Macro_OS bootloader, kernel and programs
# with NASM, and then creates floppy and CD images (on Linux)



if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e Diskimg/macroos.flp ]
then
	echo ">>> Creating new noobOS floppy image..."
	mkdosfs -C Diskimg/macroos.flp 1440 || exit
fi


echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o bootloader.bin bootloader.asm || exit


echo ">>> Assembling Macro_OS kernel..."


nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit



echo ">>> Assembling programs..."





echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=bootloader.bin of=Diskimg/macroos.flp || exit


echo ">>> Copying Macro_OS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat Diskimg/macroos.flp tmp-loop && cp kernel.bin tmp-loop/



sleep 0.2

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop


echo ">>> Creating CD-ROM ISO image..."

rm -f disk_img/noobOS.iso
mkisofs -quiet -V 'Macroos' -input-charset iso8859-1 -o Diskimg/macroos.iso -b macroos.flp Diskimg/ || exit

echo '>>> Done!'
