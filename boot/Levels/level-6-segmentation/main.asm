
mov ah, 0x0e

; Try to access secret directly 
; It will fail because of offset
mov al, [the_secret]
int 0x10

; Try to access secret indirectly
; This will work because we are adding the offset 0x7c00 to 
; data segment register
mov bx, 0x7c0
mov ds, bx
mov al, [the_secret]
int 0x10

; This will not work because es is not set, it's current value is 0x000
mov al, [es:the_secret]
int 0x10

; This will work, now es is set to 0x7c0
mov bx, 0x7c0
mov es, bx
mov al, [es:the_secret]
int 0x10

jmp $

the_secret: 
    db "X" 

times 510-($-$$) db 0
dw 0xaa55