// function.bin
// Assembly code for this program
// 00000000  55                push ebp
// 00000001  89E5              mov ebp,esp
// 00000003  B8BABA0000        mov eax,0xbaba
// 00000008  5D                pop ebp
// 00000009  C3                ret
int my_function() {
    return 0xbaba;
}

