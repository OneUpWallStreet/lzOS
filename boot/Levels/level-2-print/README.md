This bootloader just prints the string, it uses the interrupts provided by the BIOS. This allows use to see the output on emulator.

![Image](level-2-demo-image.png)

`nasm main.asm -f bin -o main.bin`
`qemu-system-x86_64 main.bin`