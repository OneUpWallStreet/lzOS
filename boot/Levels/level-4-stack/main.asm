
mov ah, 0x0e

mov bp, 0x8000
mov sp, bp

push 'A'
push 'B'
push 'C'

; Access the stack from the bottom i.e. 0x8000 - 2
mov al, [0x7FFE]
int 0x10

; Access the stack from the top i.e. 0x8000, this does not work
mov al, [0x8000]
int 0x10

; recover our characters using the standard procedure: 'pop'
; We can only pop full words so we need an auxiliary register to manipulate
; the lower byte
pop bx
mov al, bl
int 0x10

pop bx
mov al, bl
int 0x10

pop bx
mov al, bl
int 0x10

mov al, [0x8000]
int 0x10

jmp $ 

times 510-($-$$) db 0
dw 0xaa55
