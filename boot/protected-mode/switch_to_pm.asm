[bits 16]
switch_to_pm:
    cli ; disable interrupts
    lgdt [gdt_descriptor] ; load the gdt

    mov eax, cr0
    ; For example if cr0 was 0100, it will be 0101 after this instruction
    ; In reality cr0 is 32 bits long, but we only care about the last 1 bit
    ; Example of what happens:
    ;    10000000000000000000000000000000
    ; OR 00000000000000000000000000000001
    ;    ----------------------------------
    ;    10000000000000000000000000000001

    or eax, 0x1
    mov cr0, eax

    ; This instruction is crucial for the CPU to fetch the next instruction 
    ; from the correct code segment in protected mode.
    
    ; It sets the cs register to point to CODE_SEG, effectively switching the
    ; CPU to fetch and execute instructions from the 32-bit code segment.

    jmp CODE_SEG:init_pm ; jump to the next instruction, but in 32 bit mode
    

[bits 32]
init_pm: ; we are now using 32-bit instructions
    mov ax, DATA_SEG ; 5. update the segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000 ; 6. update the stack right at the top of the free space
    mov esp, ebp

    call BEGIN_PM ; 7. Call a well-known label with useful code