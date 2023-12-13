[org 0x7c00]

    mov bp, 0x8000
    mov sp, bp

    ; Stack will grow dowards, so this memmory is safe to use
    mov bx, 0x9000
    mov dh, 2 ; read 2 sectors

    call disk_load


    ; If you look at the bottom we are adding 0xdada and 0xface to the disk
    ; so sector 1 will just be filled with 0xdada.
    mov dx, [0x9000]
    call print_hex

    call print_newline

    ; Sector 2 will be filled with 0xface, we jump by 512 bytes to get to the next sector
    ; because each sector is 512 bytes
    mov dx, [0x9000 + 512]
    call print_hex

    jmp $


%include "disk_load.asm"
%include "../../real-mode/print_string.asm"
%include "../../real-mode/print_hex.asm"


times 510-($-$$) db 0

dw 0xaa55

; SAMPLE OS BOOT SECTOR DATA

; Notice how we write some extra data which does not actually belong to the boot sector, 
; since it is outside the 512 bits mark. 

; times is how many times a instruction is repeated
; so 256 times dw 0xdada will write 512 bytes of 0xdada to the disk
; because 256 * 2 = 512, and each dw is 2 bytes

times 256 dw 0xdada ; sector 2 = 512 bytes
times 256 dw 0xface ; sector 3 = 512 bytes