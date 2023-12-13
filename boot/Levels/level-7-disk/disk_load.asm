disk_load:

    pusha

    ; reading from disk requires setting specific values in all registers
    ; so we will overwrite our input parameters from 'dx'. Let's save it
    ; to the stack for later use.

    ; We will be using dh to store head number and dl to store drive number
    ; dl is set by bios. But if you remember, we set dh to how many sectors we want to read
    ; thats why we store it on the stack. We will restore it later.
    push dx

    mov ah, 0x02 ; ah <- int 0x13 function. 0x02 = 'read'

    mov al, dh ; number of sectors to read i.e. 2 because we stored 2 sectors in dh
    mov cl, 0x02 ; sector number  0x01 is our boot sector, 0x02 is the first 'available' sector
    mov ch, 0x00 ; cylinder number  
    mov dh, 0x00 ; head number


    ; dl <- drive number. Our caller sets it as a parameter and gets it from BIOS
    ; (0 = floppy, 1 = floppy2, 0x80 = hdd, 0x81 = hdd2)


    ; [es:bx] <- pointer to buffer where the data will be stored
    ; caller sets it up for us, and it is actually the standard location for int 13h


    int 0x13 ; BIOS interrupt call

    ; Jump if carry flag is set (i.e. error)
    ; Return Status: After the interrupt 0x13 function is executed, 
    ; the BIOS will set or clear the carry flag in the flags register based on the outcome of the operation. 
    ; If the disk operation is successful, the carry flag will be cleared. 
    ; If there's an error (like a read error), the carry flag will be set.
    jc disk_error

    ; lets bring back dx because we want to use it to compare the number of sectors read
    pop dx
    cmp al, dh ; check if the number of sectors read is the same as the number of sectors we wanted to read
    jne sector_error
    popa
    ret


disk_error:
    mov bx, DISK_ERROR
    call print_string
    call print_newline
    mov dh, ah
    call print_hex
    jmp disk_loop
    

sector_error:
    mov bx, SECTOR_ERROR
    call print_string
    

; This is just a infinite loop to stop the CPU from executing random stuff
disk_loop: 
    jmp $


DISK_ERROR: db "Disk read error!", 0
SECTOR_ERROR: db "Incorrect number of sectors read!", 0