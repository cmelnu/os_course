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
        jmp CODE_SEG:load32

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
    mov eax, 1             ; Set EAX to 1: LBA address of the first sector to read from disk
    mov ecx, 100           ; Set ECX to 100: number of sectors to read
    mov edi, 0x0100000     ; Set EDI to 0x0100000: destination address in memory (where data will be loaded)
    call ata_lba_read      ; Call the ata_lba_read routine to perform the disk read using LBA
    jmp CODE_SEG:0x0100000 ; Jump to the loaded code segment at 0x0100000

ata_lba_read:
    mov ebx, eax  ; Backup the LBA
    ; Send the highest 8 bits of the LBA to hard disk controller
    shr eax, 24
    or eax, 0xE0      ; Set the drive number (0xE0 for primary master)
    mov dx, 0x1F6     ; Set DX to 0x1F6: Select the drive/head register port for ATA (IDE) controller
    out dx, al        ; Finished sending the highest 8 bits of data

    ; Send the total sectors to read
    mov eax, ecx      ; Copy the number of sectors to read (from ECX) into EAX
    mov dx, 0x1F2     ; Set DX to 0x1F2: sector count register port for ATA (IDE) controller
    out dx, al        ; Send the sector count (number of sectors to read) to
    ; Finished sending the total sectors to read

    ; Send more bits of the LBA.
    mov eax, ebx       ; Restore the backup LBA
    mov dx, 0x1F3      ; Set DX to 0x1F3: port for sending the lowest 8 bits of the LBA address to the ATA (IDE) controller
    out dx, al         ; Send the lowest 8 bits of the LBA
    ; Finished sending more bits of the LBA

    ; Send more bits of the LBA
    mov dx, 0x1F4    ; Set DX register to 0x1F4 (I/O port for primary ATA/IDE data register)
    mov eax, ebx  ; Restore the backup LBA
    shr eax, 8
    out dx, al
    ; Finished sending more bits of the LBA

    ; Send the upper 16 bits of the LBA
    mov dx, 0x1F5    ; Set DX register to 0x1F5 (I/O port for primary ATA/IDE sector count register)
    mov eax, ebx     ; Restore the backup LBA
    shr eax, 16
    out dx, al

    mov dx, 0x1F7
    mov al, 20
    out dx, al

    ; Read all sectors into memory

.next_sector:
    push ecx

;Checking if we need to read
.try_again:
    mov dx, 0x1F7      ; Set DX to 0x1F7: status register port for ATA (IDE) controller
    in al, dx          ; Read status register from ATA (IDE) controller
    test al, 8
    jz .try_again

; We need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0       ; Set DX to 0x1F0: data register port for ATA (IDE) controller
    rep insw            ; INSW: input word from I/O port specified in DX into memory location specified in ES:EDI
    pop ecx             ; Restore ecx value 100 which is the amount of sectors to read
    loop .next_sector
    ; End of reading sectors into memory
    ret

times 510 - ($ - $$) db 0
dw 0xAA55

