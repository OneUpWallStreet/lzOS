

## Steps to Enter 32 Bit Mode

- Disable interrupts
- Load our GDT
- Set a bit on the CPU control register cr0
- Flush the CPU pipeline by issuing a carefully crafted far jump
- Update all the segment registers
- Update the stack
- Call to a well-known label which contains the first useful code in 32 bits
  - We will just use the print code we wrote for 32-bit lol


## Step 1 - Disable interrupts

The first thing we have to do is disable interrupts using the cli (clear interrupt) instruction, which means the CPU will simply ignore any future interrupts that may happen, at least until interrupts are later enabled. This is very important, because, like segment based addressing, interrupt handling is implemtented completely differently in protected mode than in real mode, making the current IVT that BIOS set up at the start of memory completely meaningless; and even if the CPU could map interrupt signals to their correct BIOS routines (e.g. when the user pressed a key, store its value in a buffer), the BIOS routines would be executing 16-bit code, which will have no concept of the 32-bit segments we defined in our GDT and so will ulimately crash the CPU by having segment register values that assume the 16-bit real mode segmenting 


## Step 2 - LOAD GDT

The next step is to tell the CPU about the GDT that we just prepared --- with great pain. We use a single instruction to do this, to which we pass the GDT descriptor:

`lgdt [gdt_descriptor]`


## Step 3 - SET cr0 to 1

Understand how or operation works, for example if you are doing or between `0100` & `0001` (`0x1`) then the result would flip all bits have 1 in either so -> `0101`

```
mov eax , cr0 ; To make the switch to protected mode , we set
or eax , 0x1 ; the first bit of CR0 , a control register
mov cr0 , eax ; Update the control register
```

This switch involves modifying a special CPU control register, `cr0`. Let's break down the steps and explain each part in detail:

### The Control Register `cr0`

- `cr0` is a control register in x86 architecture CPUs. Control registers govern the operation of the processor and are used to control things like memory management and task switching.
- The first bit of `cr0` (bit 0) is particularly important as it is used to enable or disable protected mode.

### Steps to Enable Protected Mode

1. **Move `cr0` to a General-Purpose Register**:
   - `mov eax, cr0`: This instruction moves the current value of `cr0` into the general-purpose register `EAX`. Direct manipulation of `cr0` is not allowed, so it needs to be loaded into a general-purpose register like `EAX`.

2. **Set the First Bit of `EAX`**:
   - `or eax, 0x1`: The `OR` instruction is used to set specific bits in a value. Here, `0x1` (which is `0001` in binary) is OR'ed with the value in `EAX`. This operation sets the least significant bit (the first bit) of `EAX` to 1, without changing the other bits. Setting this bit is necessary to enable protected mode.

3. **Move the Updated Value Back to `cr0`**:
   - `mov cr0, eax`: This instruction moves the updated value from `EAX` back into `cr0`. Since the first bit of `cr0` is now set, the CPU switches to protected mode.

### Explanation of the `OR` Instruction

- The `OR` bitwise operation is ideal for setting specific bits in a binary number because it changes a bit to 1 if any of the corresponding bits in the two operands are 1.
- In your example, `or eax, 0x1` ensures that the first bit of `EAX` is set to 1 (enabling protected mode) while leaving the other bits unchanged. This is crucial because other bits in `cr0` might control different important CPU features, and altering them unintentionally could cause problems.

### Importance of This Procedure

- Switching to protected mode is crucial for modern operating systems as it enables them to use features like hardware-based memory protection, larger address space, and advanced task management.
- This process must be done carefully to ensure system stability, as the `cr0` register controls critical CPU functions.

In summary, the process you're describing is how a system enters protected mode on x86 architecture CPUs, by carefully setting the first bit of the `cr0` register using a combination of `MOV` and `OR` instructions. This is a critical step in the boot process of modern operating systems.