
; Sets register AH to 0x0e, which is the BIOS teletype function.
mov ah, 0x0e

mov al, 'H'
int 0x10

mov al, 'e'
int 0x10

mov al, 'l'
int 0x10

mov al, 'l'
int 0x10

mov al, 'o'
int 0x10

jmp $ ; Infinite loop

times 510 - ($-$$) db 0 ; Fill the rest of the sector with 0s

dw 0xaa55 ; Magic number


