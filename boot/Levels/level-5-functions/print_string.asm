print_string:
    pusha 
    mov ah, 0x0e

print_next_char:
    mov al, [bx]
    cmp al, 0 
    je print_end
    int 0x10
    inc bx
    jmp print_next_char

print_end:
    popa
    ret


print_newline: 
    pusha 
    mov ah, 0x0e
    mov al, 0x0a ; New Line
    int 0x10
    mov al, 0x0d ; Carriage Return
    int 0x10
    popa
    ret