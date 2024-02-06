#!Makefile
#
# --------------------------------------------------------
#
#    PiEOS内核的 Makefile
#    默认使用的C语言编译器是 GCC、汇编语言编译器是 nasm
#
# --------------------------------------------------------
#

# patsubst 处理所有在 C_SOURCES 字列中的字（一列文件名），如果它的 结尾是 '.c'，就用 '.o' 把 '.c' 取代
C_SOURCES = $(shell find . -name "*.c")
C_OBJECTS = $(patsubst %.c, %.o, $(C_SOURCES))
S_SOURCES = $(shell find . -name "*.s")
S_OBJECTS = $(patsubst %.s, %.o, $(S_SOURCES))

CC = gcc
LD = ld
ASM = nasm
RM = rm

C_FLAGS = -c -Wall -m32 -ggdb -gstabs+ -nostdinc -fno-builtin -fno-stack-protector -I include
LD_FLAGS = -T scripts/kernel.ld -m elf_i386 -nostdlib
ASM_FLAGS = -f elf -g -F stabs

all:$(S_OBJECTS) $(C_OBJECTS) link pieos_kernel.iso update_image

# The automatic variable `$<' is just the first prerequisite
.c.o:
	@echo 编译代码文件 $< ...
	$(CC) $(C_FLAGS) $< -o $@

.s.o:
	@echo 编译汇编文件 $< ...
	$(ASM) $(ASM_FLAGS) $<

link:
	@echo 链接内核文件...
	$(LD) $(LD_FLAGS) $(S_OBJECTS) $(C_OBJECTS) -o pieos_kernel

.PHONY:clean
clean:
	$(RM) $(S_OBJECTS) $(C_OBJECTS) pieos_kernel

.PHONY:iso
pieos_kernel.iso:pieos_kernel
	mkdir -p iso/boot/grub
	cp $< iso/boot/
	echo 'set timeout=5' > iso/boot/grub/grub.cfg
	echo 'set default=0' >> iso/boot/grub/grub.cfg
	echo 'menuentry "PiEOS"{' >> iso/boot/grub/grub.cfg
	echo '	multiboot /boot/pieos_kernel' >> iso/boot/grub/grub.cfg
	echo '	boot' >> iso/boot/grub/grub.cfg
	echo '}' >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=$@ iso
	rm -rf iso

.PHONY:update_image
update_image:
	sudo mkdir -p /mnt/kernel
	sudo mount pieos_kernel.img /mnt/kernel
	sudo cp pieos_kernel /mnt/kernel/pieos_kernel
	sleep 1
	sudo umount /mnt/kernel
	sudo rm -r /mnt/kernel

#.PHONY:mount_image
#mount_image:
#	sudo mount floppy.img /mnt/kernel

#.PHONY:umount_image
#umount_image:
#	sudo umount /mnt/kernel

.PHONY:qemu-iso
qemu-iso:
	qemu -cdrom pieos_kernel.iso

.PHONY:qemu-flp
qemu-flp:
	qemu -fda pieos_kernel.img -boot a
	#add '-nographic' option if using server or linux distro, such as fedora-server, or "gtk initialization failed" error will occur.

.PHONY:debug
debug:
	qemu -cdrom pieos_kernel.iso -S -s &
	sleep 5
	cgdb -x scripts/gdbinit

