ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop

times 33 db 0      ; Reserve 33 bytes for BIOS Parameter

start:
    jmp 0x0000:step2    ; Jump to the 'step2' label at segment 0x7c0 (bootloader)

step2:
    cli                 ; Disable interrupts (clear interrupt flag)
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti                 ; Enable interrupts (set interrupt flag)

.load_protected:
    cli
        lgdt [gdt_descriptor]    ; Load the Global Descriptor Table (GDT) pointer
        ; The GDT pointer (limit and base address) is read from memory at gdt_descriptor,
        ; not from CPU registers. The CPU loads these values into its internal GDTR register.
        mov eax, cr0             ; Move current value of control register CR0 into EAX
        or eax, 0x0001           ; Set the PE (Protection Enable) bit to enable protected mode
        mov cr0, eax             ; Write the updated value back to CR0
        jmp CODE_SEG:load32      ; Far jump to flush the instruction pipeline and switch to protected mode (CS=CODE_SEG)

;Global Descriptor Table

gdt_start:
gdt_null:
    dd 0x0000      ; First 32 bits of the null GDT entry (all zeros)
    dd 0x0000      ; Second 32 bits of the null GDT entry (all zeros)
    ; This defines a 64-bit (8-byte) null descriptor for the Global Descriptor

; Offset 0x8
gdt_code:     ; CS should point to this  
    dw 0xffff ; Segment limit first 0-15 bits
    dw 0x0000 ; Base address first 0-15 bits
    db 0x00   ; Base address bits 16-23
    db 0x9A   ; Access byte (present, ring 0, code segment) --> byte masks, basically
    db 0xCF   ; High four bit flags and the low four bit flags (granularity (32-bit, 4KB))
    db 0x00   ; Base address bits 24-31

; Offset 0x10
gdt_data:     ; DS, SS, ES, FS, GS
    dw 0xffff ; Segment limit first 0-15 bits
    dw 0x0000 ; Base address first 0-15 bits
    db 0x00   ; Base address bits 16-23
    db 0x92   ; Access byte (present, ring 0, code segment) --> byte masks, basically
    db 0xCF   ; High four bit flags and the low four bit flags (granularity (32-bit, 4KB))
    db 0x00   ; Base address bits 24-31

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1    ; Limit: size of GDT minus 1 (here, 0x17 for 3 entries)
    dd gdt_start                  ; Base: address of GDT in memory (offset of gdt_start)

[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    in al, 0x92      ; Read the value from port 0x92 (System Control Port A) into AL
    or al, 2         ; Set bit 1 (Fast A20 Gate enable) in AL
    out 0x92, al     ; Write the modified value back to port 0x92 to enable the A20 line
    ; This sequence enables the A20 address line, allowing access to memory above 1MB

    jmp $

times 510 - ($ - $$) db 0
dw 0xAA55

