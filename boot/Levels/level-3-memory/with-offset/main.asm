; Global Offset, 0x7c00
[org 0x7c00]

mov ah, 0x0e

; Attemp 1. Try to print directly from the register al.
; the_secret contains the address. 
; FAIL
mov al, '1'
int 0x10
mov al, the_secret
int 0x10

; Attempt 2. Try to print from the memory location pointed to by al.
; Now this will work because of global offset
; SUCCESS
mov al, '2'
int 0x10
mov al, [the_secret]
int 0x10


; Attempt 3. Add 0x7c00.
; Not ofc this won't work because we already have the global offset
; and we are adding it again.
; FAIL
mov al, '3'
int 0x10
mov bx, the_secret
add bx, 0x7c00
mov al, [bx]
int 0x10

; Attempt 4. Add offset of 0x2d to point direcly at X.
; Look at Hex Dump explanation in README to get a better understanding 
; of why this works.
; SUCCESS
mov al, '4'
int 0x10
mov al, [0x7c2d]
int 0x10

jmp $

the_secret:
    db "X"


times 510-($-$$) db 0
dw 0xaa55


