ORG 0x0
BITS 16

_start:
    jmp short start
    nop

times 33 db 0      ; Reserve 33 bytes for BIOS Parameter

start:
    jmp 0x7c0:step2    ; Jump to the 'step2' label at segment 0x7c0 (bootloader)

step2:
    cli                 ; Disable interrupts (clear interrupt flag)
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti                 ; Enable interrupts (set interrupt flag)

    mov ah, 2      ; Set BIOS disk interrupt function: read sectors (INT 13h, AH=2)
    mov al, 1      ; Number of sectors to read (1 sector)
    mov ch, 0      ; Cylinder (track) number (0)
    mov cl, 2      ; Sector number (2; sectors start at 1)
    mov dh, 0      ; Head number (0)
    mov bx, buffer    ; Set BX to the offset address of 'buffer' where disk data will be read into
    int 0x13
    jc error        ; Jump to 'error' if the carry flag is set (indicates disk read failure after INT 13h)

    mov si, buffer
    call print
    jmp $

error:
    mov si, error_message
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

error_message: db 'Failed to load sector', 0

times 510 - ($ - $$) db 0
dw 0xAA55

buffer: