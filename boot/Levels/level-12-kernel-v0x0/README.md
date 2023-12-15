
### Good Docx

- Good video on ELF Files -> [What are Executables? | bin 0x00](https://youtu.be/WnqOhgI_8wA?si=UlrFWdSw87M_L417)
- How Makefile's work -> [Makefiles Make Your Life Easier](https://youtu.be/yWLkyN_Satk)

## Steps 

- Create object file for kernel -> `kernel.c` -> `kernel.o`
  - `i386-elf-gcc -ffreestanding -c kernel.c -o kernel.o`
- Create object file for kernel_entry -> `kernel_entry.asm` -> `kernel_entry.o`
  - `nasm kernel_entry.asm -f elf -o kernel_entry.o`
- Link `kernel_entry.o` & `kernel.o`
  - Kernel will be be placed in memory `0x1000`
- Compile bootsector, which does the following: 
  - loads kernel from disk 
  - switches to 32 bit protected mode 
  - gives control to the kernel
- Combine bootsector & kernel into single image
  - `cat bootsect.bin kernel.bin > os-image.bin`
- Run `qemu-system-i386 -fda os-image.bin`

---

### Q&A
In this code, we jump to the main fucntion in kernel.c file right?
```
[bits 32]
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    ; Now jump to the address of our loaded
    ; kernel code , assume the brace position ,
    ; and cross your fingers. Here we go    
    call KERNEL_OFFSET
    jmp $
```

Yes, in the provided code, the `call KERNEL_OFFSET` instruction in the `[bits 32] BEGIN_PM` section is intended to transfer control to the main function in the `kernel.c` file. However, there's a subtle but important detail to consider in how this is done. 

The `KERNEL_OFFSET` is set to `0x1000`, which is where the kernel is loaded into memory. This is a raw memory address, not a function pointer. So, this part of the code assumes that the entry point of the kernel (the very first code to be executed) is located at this exact memory location.

In typical scenarios, especially in more complex operating systems, the kernel's entry point is not necessarily the `main` function itself, but rather an initial setup routine, often written in assembly, that prepares the environment for the kernel to run (like setting up segments, stack, heap, etc.). This routine then calls the `main` function.

In your case, the `kernel_entry.asm` file contains the actual kernel entry point, which is expected to be loaded at `0x1000`. This assembly file then explicitly calls `main` in `kernel.c`.

So, the flow is like this:
1. The bootloader loads the kernel into memory at `0x1000`.
2. The bootloader switches to 32-bit protected mode and then uses `call KERNEL_OFFSET` to jump to the code at `0x1000`.
3. The code at `0x1000` (defined in `kernel_entry.asm`) executes, which in turn calls the `main` function defined in `kernel.c`.

The `call KERNEL_OFFSET` in the bootloader effectively starts the kernel's execution, but it's the assembly code at `KERNEL_OFFSET` that actually calls the `main` function in the C code.

---

### How does `kernel_entry.asm` work?

```
[bits 32]
[extern main] ;     Define calling point. Must have same name as kernel.c 'main' function
call main ;         Calls the C function. The linker will know where it is placed in memory
jmp $
```

The `[extern main]` directive in your assembly code is a way of declaring that the function `main` is defined somewhere else, not in the current assembly source file. This is typically used in situations where you're writing assembly code that interacts with C code. Here's how it works:

1. **Extern Keyword**: In assembly language, `extern` is used to declare that a symbol (like a function or variable) is defined in another file. This is necessary because, unlike high-level languages like C, assembly doesn't automatically link functions and variables from different files. You have to explicitly tell the assembler that a symbol is external.

2. **Linking to C Code**: When you write `call main`, the assembler doesn't know where `main` is defined—it just knows that `main` is an external symbol. During the linking stage, the linker resolves this symbol by finding where `main` is defined. In your case, `main` is presumably a function written in C. The linker combines your assembly object file with the C object file, replacing the external reference to `main` with the actual address of the `main` function defined in C.

3. **Jumping to C Code**: Once the linking is done, the `call main` instruction in your assembly code will correctly jump to the start of the `main` function defined in C. This is because `call` pushes the return address onto the stack and then jumps to the specified address (in this case, the address of `main`). After `main` finishes executing, the control will return to the instruction following `call main` in the assembly code, which is `jmp $`. This instruction causes the program to enter an infinite loop, effectively halting it.

In summary, the `extern` keyword is used to indicate that the `main` function is defined elsewhere (likely in a C file), and the linker resolves this external reference during the linking stage, allowing your assembly code to call into C code.