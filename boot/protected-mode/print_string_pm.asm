[bits 32]

; Constants
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f


print_string_pm: 
    pusha
    ; This is the address of memory location
    ; where we want to print the string
    mov edx, VIDEO_MEMORY

print_string_pm_loop:

    mov al, [ebx]
    mov ah, WHITE_ON_BLACK

    cmp al, 0
    je print_string_done

    ; We store char + attribute in memory
    mov [edx], ax

    ; increment ebx by 1 because we want to 
    ; move to the next character in the string
    add ebx, 1

    ; increment edx by 2 because we want to
    ; move to the next memory location
    ; 1 is char & 1 is attribute
    add edx, 2

    jmp print_string_pm_loop


print_string_done:
    popa
    ret



