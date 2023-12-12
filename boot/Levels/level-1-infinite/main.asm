
loop: 
    ; infinite loop
    jmp loop

times 510-($-$$) db 0

; magic number, indicates bootable device
dw 0xaa55
