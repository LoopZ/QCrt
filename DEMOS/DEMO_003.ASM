; Copyright ¸ 2015 Jerome Shidel
; All rights reserved.

use16

org 100h

%idefine SaveAllRegs	
%idefine TargetCPU 286
%idefine TargetOS DOS

%include "QCRT.ASM"

mov	[DirectVideo], byte FALSE

; Verbose way of setting AX, AX, BX, DX window to dimensions
; and CX to ( height - 1 ) / 2
mov			ax, 1
xor			dx, dx
mov			cx, dx
mov 		bx, [WindMax]
xchg		dl, bh
mov			cl, dl
inc			bx
inc			dx
shr			cl, 1
inc			cl

LoopColors:
	
	push		ax
	and			ax, 0x07
	pushcall	TextBackground, ax
	pop			ax
	pushcall 	Window, ax, ax, bx, dx
	pushcall 	ClrScr
	push 		ax
	push		dx
	mov			dx, 500
	shl			ax, 5
	sub			dx, ax
	shr			ax, 1
	add			ax, 50
	pushcall	Sound, dx
	pushcall	Delay, ax
	pop			dx
	pop			ax
	inc			ax
	dec			bx
	dec			dx
	loop		LoopColors

pushcall	NoSound

; A window that may be shifty 
mov	 ax, 4
xor	 cx, cx
xor	 bx, bx
mov	 bx, [ScreenMax]
xchg cl, bh
sub	bx, 2
sub cx, 2
pushcall Window, ax, ax, bx, cx

; We are feeling a bit shifty
mov	ax, [WindMin]
mov	cx, [WindMax]
sub	ch, ah
mov	cl, ch
mov	ch, 0
inc	cl

mov		[TextAttr], byte 0x4F
ShiftyLoop:
		pushcall	ScrollUp, 1
		pushcall	ScrollLeft, 2
		pushcall	Delay, 50
	loop		ShiftyLoop
	
; Minimal restoring of some stuff like TextMode and Cursor
; then exit to OS with no error code
Terminate 0
