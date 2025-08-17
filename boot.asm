ORG 0x7c00
BITS 16

start:
    mov si, message
    call print
    jmp $

print:
    mov bx, 0
.loop:
    lodsb              ; Load the character SI is pointing to
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