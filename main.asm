[BITS 16]

%define VGA_WIDTH  320
%define VGA_HEIGHT 200

%define BASEVELOCITY 2

struc rectdef
	.x:      resw 1
	.y:      resw 1
	.w:      resw 1
	.h:      resw 1
	.colour: resb 1
endstruc


mov bp, sp

mov ax, 0013h
int 0x10

mov ax, 0xA0000 / 16  ; x86 segment 
mov es, ax            ; to vram

mov word [velocity.x], BASEVELOCITY
mov word [velocity.y], BASEVELOCITY

start:
	mov byte [rect + rectdef.colour], 13
	mov ax, rect
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
			mov word [velocity.y], -BASEVELOCITY
			jmp nextY
		down:
			mov word [velocity.y], BASEVELOCITY
		nextY:

	mov byte [rect + rectdef.colour], 0
	mov ax, rect
	call draw_rect
	
	call vblank_wait

	mov ax, word [velocity.x]
	add word [rect + rectdef.x], ax
	mov ax, word [velocity.y]
	add word [rect + rectdef.y], ax


jmp start

jmp $

velocity.x: dw 0
velocity.y: dw 0

rect:
istruc rectdef
	at rectdef.x,      dw VGA_WIDTH / 2
	at rectdef.y,      dw VGA_HEIGHT / 2
	at rectdef.w,      dw 30
	at rectdef.h,      dw 20
	at rectdef.colour, db 13
iend

; CX:DX microseconds
; 0xf4240 : one second
sleep:
	pusha
	mov al, 0
	mov ah, 0x86
	mov dx, 0xAFFF
	mov cx, 0x0
	int 0x15
	clc
	popa
	ret

; AX: (*rect)
draw_rect:
	push bp
	mov bp, sp

	mov bx, ax
	
	mov ax, [bx + rectdef.x]
	add ax, [bx + rectdef.w]
	push ax

	mov ax, [bx + rectdef.x]
	sub ax, [bx + rectdef.w]
	push ax

	mov ax, [bx + rectdef.y]
	add ax, [bx + rectdef.h]
	push ax

	mov ax, [bx + rectdef.y]
	sub ax, [bx + rectdef.h]
	push ax


	; bp - 2 | x + w
	; bp - 4 | x - w
	; bp - 6 | y + h
	; bp - 8 | y - h

	; AX: Horizontal
	; BX: Vertical
	; DI: Address relative to VRAM
	;     DI is always offset from ES in x86
	; DX: colour

	mov dx, [bx + rectdef.colour]
	mov bx, [bp - 8]
	vloop:
		mov ax, [bp - 4]

		mov di, bx
		imul di, 320
		add di, [bp - 4]

	hloop:
		mov byte es:[di], dl
		inc di

		inc ax
		cmp ax, [bp - 2]
		jne hloop

		inc bx
		cmp bx, [bp - 6]
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