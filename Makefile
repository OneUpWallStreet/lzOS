# $@ = target file
# $< = first dependency
# $^ = all dependencies

# First rule is the one executed when no parameters are fed to the Makefile
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)
OBJ = ${C_SOURCES:.c=.o}


CC = x86_64-elf-gcc
# Get x86_64-elf-gcc by `brew install x86_64-elf-gcc`
GDB = i386-elf-gdb
# Get i386-elf-gdb by `brew install i386-elf-gdb`
LD = x86_64-elf-ld
# Get x86_64-elf-ld by `brew install x86_64-elf-binutils`

CFLAGS = -g

all: run

kernel.bin: boot/kernel_entry.o ${OBJ}
	${LD} -m elf_i386 -o $@ -Ttext 0x1000 --entry _start $^ --oformat binary

kernel.elf: boot/kernel_entry.o ${OBJ}
	${LD} -m elf_i386 -o $@ -Ttext 0x1000 --entry _start $^

kernel_entry.o: kernel_entry.asm
	nasm $< -f elf -o $@

kernel.o: kernel.c
	${CC} -m32 -march=i386 -ffreestanding -c $< -o $@

kernel.dis: kernel.bin
	ndisasm -b 32 $< > $@

bootsect.bin: bootsect.asm
	nasm $< -f bin -o $@

os-image.bin: boot/bootsect.bin kernel.bin
	cat $^ > $@

run: os-image.bin
	qemu-system-i386 -fda $<

debug: os-image.bin kernel.elf
	qemu-system-i386 -s -fda os-image.bin &
	${GDB} -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"

%.o : %.c ${HEADERS}
	${CC} ${CFLAGS} -m32 -march=i386 -ffreestanding -c $< -o $@

%.o : %.asm
	nasm $< -f elf -o $@

%.bin : %.asm
	nasm $< -f bin -o $@

clean:
	rm -fr *.bin *.dis *.o os-image.bin *.elf
	rm -fr kernel/*.o boot/*.bin boot/*.o drivers/*.o cpu/*.o libc/*.o