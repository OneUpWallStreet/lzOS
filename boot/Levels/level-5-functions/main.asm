[org 0x7c00]

mov bx, HELLO
call print_string

call print_newline

mov bx, BYE
call print_string

call print_newline

mov dx, 0x1234
call print_hex

jmp $

%include "print_string.asm"
%include "print_hex.asm"

HELLO: 
    db "Hello World!", 0
BYE: 
    db 'Goodbye World!', 0


times 510-($-$$) db 0
dw 0xaa55
