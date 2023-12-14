


Good video on how Compilers work -> [How do computers read code?](https://www.youtube.com/watch?v=QXjU9qTsYCc&t=494s)


## Helper Shell Script

By the way, to build the object file, binary file, obtain a hex dump, and decompile the binary file, you just need to run the script `create-bin-o-hex-dump.sh`. It will perform the necessary tasks and print out the content for you.

Simply execute it like this: `./create-bin-o-hex-dump FILE_NAME` (excluding the .c extension).

## Code Expl. 

### function.c
```
int my_function() {
    return 0xbaba;
}
```

Decompiled main.bin

```
00000000  55                push ebp
00000001  89E5              mov ebp,esp
00000003  B8BABA0000        mov eax,0xbaba
00000008  5D                pop ebp
00000009  C3                ret
```

Look at this @Swarom, its pretty cool!! It essentially creates a stack inside a stack wtf!!

Although our function does a very simple thing, there is some addtional code in there that seems to be manipulating the stack’s base and top registers, `ebp` and `esp`. C makes heavy use of the stack for storing variables that are local to a function (i.e. variables that are no-longer needed when the function returns), so upon entering a function, the stack’s base pointer (`ebp`) is increased to the current top of the stack `mov ebp, esp`, effectively creating a local, initially empty stack above the stack of the function that called our function. 

This process is often referred to as the function setting up its stack frame, in which it will allocate any local variables.

However, if prior to returning from our function we failed to restore the stack frame to that originally set up by our caller, the calling function would get in a real mess when trying to access its local variables; so before updating the base pointer for our stack frame, we must store it, and there is no better place to store it than the top of the stack (`push ebp`).

After preparing our stack frame, which, sadly, doesn’t actually get used in our simple function (which is why you were confused about why we are doing this if we never used `sp`), we see how the compiler handles the line return `0xbaba`;: the value `0xbaba` is stored in the 32-bit register `eax`, which is where the calling function (if there were one) would expect to find the returned value, similarly to how we had our own convention of using certain registers to pass arguments to our earlier assembly routines, for example: our print string routine expected to find the address of the string to be printed in the register `bx`.

Finally, before issuing ret to return to the caller, the function pops the original stack base pointer off the stack (pop ebp), so the calling function will be unaware that its own stack frame was ever changed by the called function. Note that we didn’t actuall change the top of the stack (`esp`), since in this case our stack frame was used to store nothing, so the untouched `esp` register did not require restoring.

### vars.c

```
int my_function() {
    int my_var = 0xbaba;
    return my_var;
} 
```

Decompiled main.bin

```
00000000  55                push ebp
00000001  89E5              mov ebp,esp
00000003  83EC10            sub esp,byte +0x10
00000006  C745FCBABA0000    mov dword [ebp-0x4],0xbaba
0000000D  8B45FC            mov eax,[ebp-0x4]
00000010  C9                leave
00000011  C3                ret
```

The only difference now is that we actually allocate a local variable, my var, but this provokes an interesting response from the compiler. As before, the stack frame is established, but then we see sub esp, byte +0x10, which is subtracting 16 (0x10) bytes from the top of the stack. 

Firstly, we have to (constantly) remind ourselves that the stack grows downwards in terms of memory addresses, so in simpler terms this instructions means, ’allocate another 16 bytes on the top of stack’. We are storing an int, which is a 4-byte (32-bit) data type, so why have 16 bytes been allocated on the stack for this variable, and why not use push, which allocates new stack space automatically? 

The reason the compiler manipulates the stack in this way is one of optimsation, since CPUs often operate less efficiently on a datatype that is not aligned on memory boundaries that are multiples of the datatype’s size. Since C would like all variables to be properly aligned, it uses the maximum datatype width (i.e. 16 bytes) for all stack elements, at the cost of wasting some memory.

The next instruction, mov dword [`ebp-0x4`],0xbaba, actually stores our variable’s value in the newly allocated space on the stack, but without using push, for the previously given reason of stack efficiency (i.e. the size of the datatype stored is less than the stack space reserved). We understand the general use of the mov instruction, but two things that deserve some explanation here are the use of dword and [`ebp-0x4`]:

- `dword` states explicitly that we are storing a double word (i.e. 4 bytes) on the stack, which is the size of our int datatype. So the actual bytes stored would be `0x0000baba`, but without being explicit could easily be `0xbaba` (i.e. 2 bytes) or `0x000000000000baba` (i.e. 8 bytes), which, although the same value, have different ranges
- [`ebp-0x4`] is an example of a modern CPU shortcut called effective address computation, which is more impressive that the assembly code seems to reflect. This part of the instruction references an address that is calculated on-the-fly by the CPU, based on the current address of register `ebp`. At a glance, we might think our assembler is manipulating a constant value, as it would if we wrote something like this `mov ax, 0x5000 + 0x20`, where our assembler would simply pre-process this into mov ax, `0x5020`. But only once the code is run would the value of any register be known, so this definitely is not pre-processing; it forms a part of the CPU instruction. With this form of addressing the CPU is allowing us to do more per instruction cycle, and is good example of how CPU hardware has adapted to better suit programmers. We could write the equivalent, without such address manipulation, less efficiently in the following three lines of code:

```
mov eax , ebp ; EAX = EBP
sub eax , 0 x4 ; EAX = EAX - 0x4
mov [eax] , 0 xbaba ; store 0 xbaba at address EAX
```

So the value `0xbaba` is stored directly to the appropriate position of the stack, such that it will occupy the first 4 bytes above (though physically below, since the stack grows downwards) the base pointer.

Now, being a computer program, our compiler can distinguish different numbers as easily as we can distinguish different variable names, so what we think of as the variable my var, the compiler will think of as the address `ebp-0x4` (i.e. the first 4 bytes of the stack). We see this in the next instruction, `mov eax,[ebp-0x4]`, which basically means, ’store the contents of my var in eax’, again using efficiently address computation; and we know from the previous function that eax is used to return a variable to the caller of our function.

Now, before the ret instruction, we see something new: the leave instruction. Actually, the leave instruction is an alternative to the following steps, that restore the original stack of the caller, recipricol of the first two instruction of the function:

```
mov esp , ebp ; Put the stack back to as we found it.
pop ebp
```

### functioncalls.c

functioncalls.c
```
void caller() {
    my_func(0xdede);
}

int my_func(int arg) {
    return arg;
}
```

main.bin
```
00000000 55                 push ebp
00000001 89                 E5 mov ebp , esp
00000003 83                 EC08 sub esp , byte +0 x8
00000006 C70424DEDE0000     mov dword [ esp ] ,0 xdede
0000000D E802000000         call dword 0 x14
00000012 C9                 leave
00000013 C3                 ret
00000014 55                 push ebp
00000015 89 E5              mov ebp , esp
00000017 8 B4508            mov eax ,[ ebp +0 x8 ]
0000001A 5D                 pop ebp
0000001B C3                 ret
```

Firstly, notice how we can differntiate between assembly code of the two functions by looking for the tell-tale ret instruction that always appears as the last instruction of a function. Next, notice how the upper function uses the assembly instruction call, which we know is used to jump to another routine from which usually we expect to return. This must be our caller function, that is calling callee function at offset `0x14` of the machine code. 

The most interesting lines here are those immediately before the call, since they are somehow ensuring that the argument my arg is passed to callee function. After establishing its stack frame, as we have seen to be common to all functions, caller function allocates 8 bytes on the top of the stack (`sub esp,byte +0x8`), then stores our passed value, 0xdede, into that stack space (`mov dword [esp],0xdede`).

So let’s see how callee function accesses that argument. From offset `0x14`, we see that callee function establishes its stack frame as usual, but then look at what it stores in the eax register, a register that we know from our earlier analysis is used to hold a function’s return value: it stores the contents of address `[ebp + 0x8]`. 

Here we have to remind ourselves again of that confusing fact that the stack grows downwards in memory, so in terms of logically-more-sensible upward growing stack, ebp + `0x8` is 8 bytes below our stack’s base, so we are actually reaching into the stack frame of the function that called us to get the argument’s value. This is what we’d expect, of course, because the caller put that value onto the top of their stack, then we put our stack base at the top of their stack to establish our stack frame.

### add.c

add.c
```
int func() {
    int a = 0x1;
    int b = 0x2;
    int total = a + b;
    return total;
}
```

main.bin

```
00000000  55                push ebp
00000001  89E5              mov ebp,esp
00000003  83EC10            sub esp,byte +0x10
00000006  C745FC01000000    mov dword [ebp-0x4],0x1
0000000D  C745F802000000    mov dword [ebp-0x8],0x2
00000014  8B55FC            mov edx,[ebp-0x4]
00000017  8B45F8            mov eax,[ebp-0x8]
0000001A  01D0              add eax,edx
0000001C  8945F4            mov [ebp-0xc],eax
0000001F  8B45F4            mov eax,[ebp-0xc]
00000022  C9                leave
00000023  C3                ret
```

<!-- Q&A wid GPT4 -->

I have a very simple program, but when I look at the decompiled code, I don't understand this part: 'mov [ebp-0xc],eax.' Aren't we supposed to store the return value in EAX? Why is it being stored at the address [ebp-0xc]?

The line `mov [ebp-0xc], eax` in the disassembled code is part of the function's process for handling local variable storage and manipulation. Let's break down this particular line in the context of the provided assembly and C code.

### Understanding the Assembly Code

Your assembly code seems to correspond to a function like this in C:

```c
void func() {
    int a = 0x1;
    int b = 0x2;
    int total = a + b;
    return total;
}
```

Now, let's analyze the relevant parts of the assembly code:

1. **Local Variables Setup**:
   - `C745FC01000000`: This moves the value `0x1` into the location `ebp-0x4`, which corresponds to the local variable `a` in your C code.
   - `C745F802000000`: This moves the value `0x2` into the location `ebp-0x8`, which corresponds to the local variable `b`.

2. **Addition of Local Variables**:
   - `8B55FC` and `8B45F8`: These instructions move the contents of `ebp-0x4` (a) into `edx` and `ebp-0x8` (b) into `eax`, respectively.
   - `01D0`: This adds `edx` to `eax`, effectively performing `a + b`.

3. **Storing the Result**:
   - `8945F4`: This is the line in question. It moves the contents of `eax` (which now holds the sum of `a` and `b`) into the memory location `ebp-0xc`. This location corresponds to the local variable `total` in your C code.

### Why `mov [ebp-0xc], eax`?

- **Local Variable Storage**: In C, when you declare a local variable like `int total`, it doesn't necessarily use the `eax` register to store its value. Instead, it is stored in a location on the stack. In your function, `total` is stored at `ebp-0xc`. 
- **`eax` Register Usage**: `eax` is often used for arithmetic operations and to store the return value of a function. In this case, it's being used as a temporary holder of the result of `a + b` before moving that result to the stack where `total` resides.
- **Returning the Value**: Even though your function intends to return `total`, the value must first be stored in the location designated for `total` (here, `ebp-0xc`). When the `return` statement is executed, this value would typically be moved into `eax` as per the standard calling convention for returning values.

### Conclusion

In summary, the line `mov [ebp-0xc], eax` is storing the result of the addition into the stack memory allocated for the local variable `total`. It's a part of standard stack-based management of local variables in C functions as compiled into assembly language.


## What is the main.o file? What's an object file basically...

The `.o` file in programming, specifically in the context of C or C++ programming, is an object file. Here's a brief overview of what it is and its role in the compilation process:

1. **Compilation Process**: When you compile a C or C++ source code file (typically with extensions `.c` or `.cpp`), the compiler first converts it into an object file. This is an intermediate form that represents the compiled but not yet linked code.

2. **Object File**: An object file (with the extension `.o` in Unix-like systems or `.obj` in Windows) contains machine code, which is the binary representation of the program, but it is not yet executable. This machine code is specific to the architecture for which the program is being compiled.

3. **Linking**: The object file contains all the machine code for the functions and variables defined in the source file, but it does not yet include external code (like libraries or other modules) that the program might use. The process of linking combines one or more object files and libraries into a single executable file.

4. **Purpose**: The primary purpose of object files is to allow modular compilation. Each source code file in a large program can be compiled separately into an object file. After all source files are compiled, these object files are linked together to create the final executable.

5. **Advantages**: This modular approach to compiling and linking improves efficiency, especially for large projects. If you make a change in one source file, only that file needs to be recompiled into an object file. The rest of the object files, which haven't changed, can be directly used in the linking phase to create the updated executable.

In summary, a `.o` file is a crucial part of the compilation process, representing a compiled version of a single source file, ready to be linked into a complete executable program.

## What is `-ffreestanding` flag?

The `-ffreestanding` flag used in GCC (GNU Compiler Collection) indicates that the code is being compiled for a "freestanding" environment. This is an important concept in certain areas of software development, particularly in system programming. Here's what it means and its implications:

1. **Freestanding Environment**: In a freestanding environment, standard library functions, including the startup code, are not necessarily available. This environment is typical for kernel development, embedded systems programming, and writing bootloaders where standard library facilities (like `main`, `printf`, etc.) provided by the operating system are not present.

2. **System Independence**: Using `-ffreestanding` doesn't make the code "system independent" in the sense that it can run on any hardware or operating system. Rather, it means that the code is not relying on the host system's standard library or runtime environment. This is essential for code that must run in environments where these facilities are absent or different from the standard ones.

3. **Implications of `-ffreestanding`**:
    - The compiler does not assume the presence of standard library functions.
    - It's the programmer's responsibility to provide implementations for any required library functions or to avoid them entirely.
    - Only a few basic requirements are mandated by the C standard for freestanding environments, such as basic types and some essential macros.

4. **The Compilation Command**: The command `i386-elf-gcc -ffreestanding -c function.c -o function.o` indicates several things:
    - `i386-elf-gcc`: You are using a cross-compiler targeting the i386 architecture. This is common in OS development or when compiling for a different architecture than your development machine.
    - `-ffreestanding`: As explained, this tells the compiler that the standard library may not be available.
    - `-c`: This compiles the source file `function.c` into an object file (`function.o`) without linking.
    - `function.c`: The source file.
    - `-o function.o`: Specifies the output file name for the object file.

5. **Cross-Platform and Architecture Specifics**: Remember, even with `-ffreestanding`, the compiled code is specific to the architecture you are compiling for (in this case, i386). To make it run on different architectures, you would need to compile it with a cross-compiler targeted at those specific architectures.

In conclusion, the `-ffreestanding` flag is essential for developing low-level code that operates independently of the standard library and runtime environment provided by an operating system, particularly in system-level programming. However, it does not automatically make the code runnable on any system. The compiled code is still tied to the architecture and environment for which it is specifically compiled.