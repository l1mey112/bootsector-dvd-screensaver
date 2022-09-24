[BITS 16]

%define VGA_WIDTH  (640 / 8)
%define VGA_HEIGHT 480

%define BASEVELOCITY 1

struc rectdef
	.x:      resw 1
	.y:      resw 1
	.w:      resw 1
	.h:      resw 1
endstruc

mov bp, sp

mov ax, 0011h
int 0x10

mov ax, 0xA0000 / 16  ; x86 segment 
mov es, ax            ; to vram

mov word [velocity.x], BASEVELOCITY
mov word [velocity.y], BASEVELOCITY * 8

start:
	mov dx, 1
	call draw_rect
	call sleep

		mov ax, [rect + rectdef.x]
		add ax, [rect + rectdef.w]
		cmp ax, VGA_WIDTH
		jge right
		mov ax, [rect + rectdef.x]
		sub ax, [rect + rectdef.w]
		cmp ax, 0
		jle left
		jmp nextX
		right:
			mov word [velocity.x], -BASEVELOCITY
			jmp nextX
		left:
			mov word [velocity.x], BASEVELOCITY
		nextX:
			mov ax, [rect + rectdef.y]
			add ax, [rect + rectdef.h]
			cmp ax, VGA_HEIGHT
			jge up
			mov ax, [rect + rectdef.y]
			sub ax, [rect + rectdef.h]
			cmp ax, 0
			jle down
			jmp nextY
		up:
			mov word [velocity.y], (-BASEVELOCITY * 8)
			jmp nextY
		down:
			mov word [velocity.y], (BASEVELOCITY * 8)
		nextY:

	mov dx, 0
	call draw_rect
	
	call vblank_wait

	mov ax, word [velocity.x]
	add word [rect + rectdef.x], ax
	mov ax, word [velocity.y]
	add word [rect + rectdef.y], ax

jmp start

velocity.x: dw 0
velocity.y: dw 0

rect:
istruc rectdef
	at rectdef.x,      dw VGA_WIDTH / 2
	at rectdef.y,      dw VGA_HEIGHT / 2
	; image dimensions = (64, 28)
	at rectdef.w,      dw 4
	at rectdef.h,      dw 14
iend

; CX:DX microseconds
; 0xf4240 : one second
sleep:
	mov al, 0
	mov ah, 0x86
	mov dx, 0xAFFF
	mov cx, 0x0
	int 0x15
	ret

; AX: (*rect)
; DX: clear?
draw_rect:
	push bp
	mov bp, sp

	mov ax, [rect + rectdef.x]
	add ax, [rect + rectdef.w]
	push ax

	mov ax, [rect + rectdef.x]
	sub ax, [rect + rectdef.w]
	push ax

	mov ax, [rect + rectdef.y]
	add ax, [rect + rectdef.h]
	push ax

	mov ax, [rect + rectdef.y]
	sub ax, [rect + rectdef.h]
	push ax

	; bp - 2  | x + w
	; bp - 4  | x - w
	; bp - 6  | y + h
	; bp - 8  | y - h
	; bp - 10 | clear bit

	mov bx, dx

	mov ax, 0
	mov dx, [bp - 8]
	vloop:
		mov di, dx
		imul di, VGA_WIDTH
		add di, [bp - 4]

		imul si, ax, 8
		add si, image_dvd

	hloop:
		mov cx, 2

		test bl, bl
		je .zero
		
		rep movsd
		
		jmp .next
	.zero:
		push ax
		mov ax, 0
		rep stosd
		pop ax
	.next:

		inc ax
		inc dx
		cmp dx, [bp - 6]
		jne vloop

	leave
	ret

vblank_wait:
	mov dx, 0x03DA
.ret1:
	in al, dx
	test al, 8
	jz .ret1
.ret2:
	in al, dx
	test al, 8
	jnz .ret2
	ret

image_dvd: 
incbin "dvd/rawdvdbytes"
image_dvd_end:

%if $-$$ > 512
	%error ----- exeeded 512 bytes ----- 
%endif