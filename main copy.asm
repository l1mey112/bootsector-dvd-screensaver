[BITS 16]

; 640 x 480
; 1 bit per pixel

%define VGA_WIDTH  (640 / 8)
%define VGA_HEIGHT 480

mov bp, sp

mov ax, 0011h
int 0x10

mov ax, 0xA0000 / 16  ; x86 segment 
mov es, ax            ; to vram

mov di, 0
mov bx, 0
vloop:
	mov ax, 0
	mov di, bx
	imul di, VGA_WIDTH
hloop:
	mov byte es:[di], 11101011b

	inc di

	inc ax
	cmp ax, VGA_WIDTH
	jne hloop

	inc bx
	cmp bx, VGA_HEIGHT
	jne vloop

%if $-$$ > 512
	%error ----- exeeded 512 bytes ----- 
%endif