

; Sets register ah to 0x0e, which is the BIOS teletype function.

mov ah, 0x0e

; Attemp 1. Try to print directly from the register al.
; the_secret contains the address. 
; FAIL
mov al, '1'
int 0x10
mov al, the_secret
int 0x10

; Attempt 2. Try to print from the memory location pointed to by al.
; FAIL
mov al, '2'
int 0x10
mov al, [the_secret]
int 0x10

; Attempt 3. Try to print from the memory location pointed to by al.
; This time add 0x7c00 to the address. This will point to the memory
; location in the boot sector.
; SUCCESS
mov al, '3'
int 0x10
mov bx, the_secret
add bx, 0x7c00
mov al, [bx]
int 0x10

; Directly jump to memory by adding 2 bytes to the address.
; SUCCESS
; Recounting label offsets is not fun.
mov al, '4'
int 0x10
mov al, [0x7c2d]
int 0x10

jmp $


; the_secret contains memory location of the_secret
the_secret: 
    ; ASCII code 0x58 ('X') is stored just before the zero-padding.
    ; On this code that is at byte 0x2d (check it out using 'xxd file.bin')
    db "X"

    
times 510 - ($-$$) db 0
dw 0xaa55
