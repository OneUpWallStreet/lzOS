[bits 32]
; Mark the function as extern i.e. not present in this file
[extern main]
; This will call the main function in the Kernel
call main
jmp $