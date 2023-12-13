gdt_start:
; null descriptor
; total 8 bytes because of dd is 4 bytes each
; segment descriptor is 8 bytes each
; so null descriptor is 8 bytes
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff ; limit low (16 bit)
    dw 0x0    ; base low (16 bit)
    db 0x0    ; base middle (8 bit)
    ; 1st flags : ( present )1 ( privilege )00 ( descriptor type )1 -> 1001 
    ; -> 1001

    ; type flags : ( code )1 ( conforming )0 ( readable )1 ( accessed )0 -> 1010 
    ; -> 1010

    db 10011010b ; access flags
    ; 2nd flags : ( granularity )1 (32 - bit default )1 (64 - bit seg )0 ( AVL )0 -> 1100 b
    ; -> 1100

    ; Limit 
    ; -> 1111
    
    db 11001111b ; 2nd flags , Limit ( bits 16 -19)
    db 0x0    ; base high (8 bit)

gdt_data:

;   same as code segment
    dw 0xffff
    dw 0x0
    db 0x0

    ; 1st flags, same as code segment
    ; -> 1001

    ; The CPU knows whether a segment is readable 
    ; or writable based on the Type field within 
    ; the segment descriptor's access byte.

    ; type flags are different
    ; -> 0010
    ; 0 for code
    ; 0 for conforming (Expand down)
    ; 1 for writable
    ; 0 for accessed

    db 10010010b
    
    ; 2nd flags, same as code segment
    ; -> 1100

    ; Limit is same as code segment
    ; -> 1111 
    db 11001111b
    
    ; same as code segment
    db 0x0

gdt_end: 

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; size (16 bit)
    dd gdt_start ; address (32 bit)

; We are going to use these later
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start