#!/bin/bash

# Output all the things you need 
# just pass c file name as argument

filename=$1

echo "Source Code"
echo "-------------------"
echo

cat "${filename}.c"

echo
echo "-------------------"
echo


echo "Creating Object file"
echo "-------------------"
echo

i386-elf-gcc -ffreestanding -c "${filename}.c" -o main.o


echo "Obj dump of main.o"
echo "-------------------"
echo

i386-elf-objdump -d main.o


echo "-------------------"
echo "creating binary file, we use linker"
echo

i386-elf-ld -o main.bin -Ttext 0x0 --oformat binary main.o
echo "-------------------"
echo

echo "Hex dump of main.bin"
echo

xxd -b main.bin
echo "-------------------"

echo "Hex dump of main.o"
echo "-------------------"
echo

xxd -b main.o

echo "Decompile main.bin"
echo "-------------------"
echo

ndisasm -b 32 main.bin