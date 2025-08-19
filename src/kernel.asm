[BITS 32]
global _start    ; Make the _start label visible to the linker as the entry point for the program

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    mov ax, DATA_SEG    ; Load data segment selector (0x10) into AX
    mov ds, ax          ; Set DS (Data Segment) to DATA_SEG
    mov es, ax          ; Set ES (Extra Segment) to DATA_SEG
    mov fs, ax          ; Set FS to DATA_SEG
    mov gs, ax          ; Set GS to DATA_SEG
    mov ss, ax          ; Set SS (Stack Segment) to DATA_SEG

    mov ebp, 0x00200000 ; Set base pointer to 2MB (stack base)
    mov esp, ebp        ; Set stack pointer to 2MB (stack top)

    in al, 0x92         ; Read System Control Port A (0x92) into AL
    or al, 2            ; Enable A20 line by setting bit 1 in AL
    out 0x92, al        ; Write back to port 0x92 to activate A20 (access above 1MB)

    jmp $               ; Infinite loop