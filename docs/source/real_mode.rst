Real Mode: Bootloader
====================

Real mode is the initial operating mode of x86 CPUs after reset. In this mode, the processor can address up to 1MB of memory and uses segmented addressing. Bootloaders run in real mode, allowing direct access to hardware and BIOS services. Key features:

- 16-bit instructions and registers
- No memory protection or multitasking
- Direct access to BIOS interrupts (e.g., INT 0x10 for screen output)
- Used for initializing hardware and loading the operating system

In the provided bootloader, real mode is used to print text and set up interrupt handlers before transitioning to further stages of OS loading.
