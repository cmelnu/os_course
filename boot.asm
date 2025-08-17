ORG 0x0
BITS 16

_start:
    jmp short start
    nop

times 33 db 0      ; Reserve 33 bytes for BIOS Parameter

start:
    jmp 0x7c0:step2    ; Jump to the 'step2' label at segment 0x7c0 (bootloader)

handle_zero:
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret

handle_one:
    mov ah, 0eh
    mov al, 'V'
    mov bx, 0x00
    int 0x10
    iret

step2:
    cli                 ; Disable interrupts (clear interrupt flag)
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti                 ; Enable interrupts (set interrupt flag)

    mov word[ss:0x00], handle_zero   ; Store the address of handle_zero at offset 0x00 in the stack segment
    mov word[ss:0x02], 0x7c0

    mov word[ss:0x04], handle_one    ; Store the address of handle_one at offset 0x00 in the stack segment
    mov word[ss:0x06], 0x7c0

    int 1    ; Software interrupt 1 (calls interrupt vector 1, typically the divide-by-zero handler). This will jump to ss:0x04

    mov si, message
    call print
    jmp $

print:
    mov bx, 0
.loop:
    lodsb               ; Load the byte at [SI] into AL, then increment SI
                        ; lodsb copies the value pointed to by SI into AL, then increases SI by 1.
                        ; So: source pointer is SI, destination register is AL.
    cmp al, 0
    je .done           ; If the character is null, we are done
    call print_char    ; Print the character
    jmp .loop
.done: 
    ret

print_char:
    mov ah, 0eh
    int 0x10        ; Call BIOS teletype output (INT 10h, AH=0Eh) to print character
    ret

message: db 'Hello, world!', 0

times 510 - ($ - $$) db 0
dw 0xAA55