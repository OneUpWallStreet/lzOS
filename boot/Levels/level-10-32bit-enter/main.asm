[org 0x7c00]

    mov bp, 0x9000
    mov sp, bp  

    mov bx, MSG_REAL_MODE
    call print_string

    call switch_to_pm
    
    ; Will never reach here
    ; Becuase if you look at the switch_to_pm.asm
    ; at the end we call BEGIN_PM

    jmp $
    
    %include "../../real-mode/print_string.asm"
    %include "../../protected-mode/gdt.asm"
    %include "../../protected-mode/print_string_pm.asm"
    %include "switch_to_pm.asm"


[bits 32]
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    jmp $
    


MSG_REAL_MODE db "Started in 16-bit real mode", 0
MSG_PROT_MODE db "Loaded 32-bit protected mode", 0

; bootsector
times 510-($-$$) db 0
dw 0xaa55