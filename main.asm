[bits 16]
[org 0x7c00]

jmp start
nop

; File system headers I don't feel like decoding
db 0x00, 0x02, 0x01, 0x03, 0x00, 0x02, 0x09, 0x00, 0x0a, 0x00, 0x1e,0x25, 0x01, 0xdd, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, `dexxplay OSDEXXFS00`, 0x00, 0x12, 0x00, 0x02, 0x00

start:
jmp 0:setcstozero
setcstozero:
xor ax, ax
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00
mov byte [0x7c2b], dl
pushaw
mov eax, cr0
and ax, 0xfffb
or ax, 2
mov cr0, eax
mov eax, cr4
or ax, 0x600
mov cr4, eax
popaw
mov ax, 3
int 0x10
mov ah, 2
mov al, 4
mov ch, 0
mov dh, 0
mov cl, 2
mov bx, 0x7e00
int 0x13
in al, 0x92
or al, 2
out 0x92, al
jmp 0x7e5e
cli
hlt
jmp 0x7c78
mov si, 0x7d26
call 0x7d20
jmp 0x7c78
mov si, 0x7d3c
call 0x7d20
jmp 0x7c78
mov si, 0x7d51
call 0x7d20
jmp 0x7c78
mov si, 0x7d77
call 0x7d20
jmp 0x7c78
mov si, 0x7d92
call 0x7d20
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
push si
push ax
push bx
push dx
call 0x7ce5
mov cx, ax
mov ah, 0x13
mov al, 1
mov bh, 0
xor dx, dx
mov bp, si
int 0x10
pop dx
pop bx
pop ax
pop si
ret
mov bl, 0xa
call 0x7cfa
ret
mov bl, 0xc
call 0x7cfa
ret
mov bl, 0xb
call 0x7cfa
ret

db "RAM size cant be read", 0
db "Error loading dexxOS", 0
db "Graphic mode information cant be read", 0
db "Error setting graphic mode", 0
db "Memory at 0x100000 is not free", 0

times 510-($-$$) db 0x00
dw 0xAA55

;;; TODO ;;;
; Decode dexxOS.img 0x200 to 0x5FF (2 sectors)
; Figure out what the code does
; Figure out what jumps and calls go where
