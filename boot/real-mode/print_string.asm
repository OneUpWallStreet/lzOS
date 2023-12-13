print_string:
    pusha
    mov ah, 0x0e

print_next_char:
    mov al, [bx]
    cmp al, 0
    je print_done
    int 0x10
    inc bx
    jmp print_next_char

print_done:
    popa
    ret 

print_newline:
    pusha
    mov ah, 0x0e
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    popa
    ret