[org 0x7c00]

; Kernel starts at 0x1000, saw from console output
KERNEL_OFFSET equ 0x1000

mov [BOOT_DRIVE], dl ; Store the boot drive number in memory
mov bp, 0x9000 ; Set the stack at 0x9000
mov sp, bp

mov bx, MSG_REAL_MODE
call print_string
call print_newline

call load_kernel
call switch_to_pm
jmp $


%include "boot/real-mode/print_string.asm"
%include "boot/real-mode/disk_load.asm"
%include "boot/real-mode/print_hex.asm"
%include "boot/protected-mode/gdt.asm"
%include "boot/protected-mode/print_string_pm.asm"
%include "boot/protected-mode/switch_to_pm.asm"


[bits 16]
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_string
    call print_newline

    ; Set -up parameters for our disk_load routine 
    mov bx, KERNEL_OFFSET
    mov dh, 2 ; Number of sectors to read
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

[bits 32]
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    ; Now jump to the address of our loaded
    ; kernel code , assume the brace position ,
    ; and cross your fingers. Here we go    
    call KERNEL_OFFSET
    jmp $


BOOT_DRIVE db 0 ; It is a good idea to store it in memory because 'dl' may get overwritten
MSG_REAL_MODE db "Started in 16-bit Real Mode", 0
MSG_PROT_MODE db "Landed in 32-bit Protected Mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory", 0

; padding
times 510 - ($-$$) db 0
dw 0xaa55