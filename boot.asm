[bits 16]
[org 0x7c00]

jmp start
nop

; File system headers I don't feel like decoding
db 0x00, 0x02, 0x01, 0x03, 0x00, 0x02, 0x09, 0x00, 0x0a, 0x00, 0x1e, 0x25, 0x01, 0xdd, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, "dexxplay OSDEXXFS00", 0x00, 0x12, 0x00, 0x02, 0x00

;; Setup system
; Set CS to 0
start:
jmp 0:setcstozero
setcstozero:
; Set AX to 0 to make DS, ES, and SS 0
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
; Set the stack pointer to RAM right below this bootloader code
mov sp, 0x7c00
; Move dl to some location to save the drive type
mov byte [0x7c2b], dl

;; Configure the system to get ready to move to 32 bit mode
pushaw
; https://wiki.osdev.org/CPU_Registers_x86-64#CR0 for more info
mov eax, cr0
; Turn off bit 2 of CR0 to disable 8086 emulation completely
and ax, 0xfffb
; Turn on bit 1 of CR0 to enable monitor co-processing, a type of parallel processing
; https://www.computer.org/csdl/journal/ca/2018/01/08219379/13rRUxbCbnq for more info
or ax, 2
mov cr0, eax
; https://wiki.osdev.org/CPU_Registers_x86-64#CR4 for more info
mov eax, cr4
; Turn on bits 9 and 10 to enable support for fxsave and fxstor instructions
; and to enable support for unmasked simd floating point exceptions
or ax, 0x600
mov cr4, eax
popaw

;; Change the video mode for writing text later
; https://en.wikipedia.org/wiki/INT_10H for more info
; AH = 00h (Set video mode) and AL = 03h for INT 10h
; https://mendelson.org/wpdos/videomodes.txt for more info
; Sets video mode to mode=TEXT text-resolution=80x25 pixel-box=9x16
; pixel-resolution=720x400 colors=16 display-pages=8 screen-addr=0xB800 system=VGA
mov ax, 0x0003
int 0x10

;; Read from the disk to get the remaining (for now) code data for now
; https://en.wikipedia.org/wiki/INT_13H for more info
mov ah, 2 ; Mode 02h, read sectors from drive
mov al, 4 ; Read 4 sectors (2 KiB)
mov ch, 0 ; From cylinder 0 (I don't really understand this drive specific stuff, if someone could add descriptive comments that would be nice)
mov dh, 0 ; From head 0
mov cl, 2 ; Start at sector 2
mov bx, 0x7e00 ; Because ES = 0 the data will be loaded at 0x07e00 (right after this bootloader code)
int 0x13 ; Call the disk interrupt with the above configurations

;; Enable the A20 line
; https://wiki.osdev.org/A20_Line#Fast_A20_Gate for more info
in al, 0x92
; Set bit 1 of the Fast A20 gate to enable the A20 line to get access to the whole 16MB of RAM allowed by the Intel 286
or al, 2
out 0x92, al

;; This is all magic to me right now!
jmp 0x7e5e
halt:
cli
hlt
jmp halt

ram_error:
mov si, $ram_error_str
call print_red
jmp halt

load_error:
mov si, $load_error_str
call print_red
jmp halt

gfx_read_error:
mov si, $gfx_read_error_str
call print_red
jmp halt

gfx_error:
mov si, $gfx_error_str
call print_red
jmp halt

memory_error:
mov si, $memory_error_str
call print_red

push si
push ax
push bx
mov ah, 0xe
mov bh, 0
lodsb
or al, al
je 0x7cb2
int 0x10
jmp 0x7ca9
pop bx
pop ax
pop si
ret
pushaw
mov bl, al
and bl, 0xf
add bl, 0x30
cmp bl, 0x3a
jl 0x7cc7
add bl, 7
mov bh, al
shr bh, 4
add bh, 0x30
cmp bh, 0x3a
jl 0x7cd7
add bh, 7
mov ah, 0xe
mov al, bh
int 0x10
mov al, bl
int 0x10
popaw
ret
add byte [bx + si], al
push si
push dx
push bx
xor dx, dx
lodsb
or al, al
je 0x7cf4
add dx, 1
jmp 0x7cea
mov ax, dx
pop bx
pop dx
pop si
ret

print_str:
;print a string
push si
push ax
push bx
push dx
call 0x7ce5
mov cx, ax ;cx must hold the lenght of thr str
mov ah, 0x13
mov al, 1
mov bh, 0
xor dx, dx
mov bp, si ;bp must point to the start of the str
int 0x10
pop dx
pop bx
pop ax
pop si
ret

print_green:
mov bl, 0xa ;light green color
call print_str
ret

print_red:
mov bl, 0xc ;light red color
call print_str
ret

print_cyan:
mov bl, 0xb ;light cyan color
call print_str
ret

ram_error_str:      db "RAM size cant be read", 0
load_error_str:     db "Error loading dexxOS", 0
gfx_read_error_str: db "Graphic mode information cant be read", 0
gfx_error_str:      db "Error setting graphic mode", 0
memory_error_str:   db "Memory at 0x100000 is not free", 0

times 510-($-$$) db 0x00
dw 0xAA55

;;; TODO ;;;
; Decode dexxOS.img 0x200 to 0x5FF (2 sectors)
; Figure out what the code does
; Figure out what jumps and calls go where
