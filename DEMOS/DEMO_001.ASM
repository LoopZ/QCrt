; Copyright ¸ 2015 Jerome Shidel
; All rights reserved.

use16

org 100h

; Uncomment the following %idefine for automatic register preservation.
; By default, only DS, SS, SP and BP are preserved. Other registers
; can and usually are destroyed. 

; %idefine SaveAllRegs	

; Uncomment the following %idefine to generate code that only requires
; an 8086 to run. (Hopefully, I have no way to test it) Otherwise,
; at present, a 286+ CPU is required.

; %define TargetCPU 8086

%include "QCRT.ASM"

mov	[DirectVideo], byte FALSE

pushcall 	WriteStr, DS, HelloWorld
pushcall 	WriteStr, DS, PressAKey
WaitForKey:
	pushcall	KeyPressed
	jz			WaitForKey
pushcall	ReadKey

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
	
	pushy 		ax, bx, dx, cx
	and			ax, 0x07
	pushcall	TextBackground, ax
	poppy		cx, dx, bx, ax
	pushy 		ax, bx, dx, cx
	pushcall 	Window, ax, ax, bx, dx
	pushcall 	ClrScr
	pop			cx
	push 		cx
	mov			dx, 500
	shl			cx, 1
	shl			cx, 1
	shl			cx, 1
	shl			cx, 1
	shl			cx, 1
	sub			dx, cx
	push		dx
	pushcall	Sound, dx
	pop			dx
	pushcall	Delay, dx
	poppy		cx, dx, bx, ax
	inc			ax
	dec			bx
	dec			dx
	loop		LoopColors

pushcall	NoSound

; A window that may be shifty 
mov	 ax, 4
push ax
push ax
xor	 cx, cx
mov	 ax, [ScreenMax]
xchg cl, ah
sub	ax, 2
sub cx, 2
push ax
push cx
pushcall Window

; We are feeling a bit shifty
mov	ax, [WindMin]
mov	cx, [WindMax]
sub	ch, ah
mov	cl, ch
mov	ch, 0
inc	cl

mov		al, 0x4F
mov		[TextAttr], al
ShiftyLoop:
	push		cx
	%ifidni		TargetCPU, 8086
		mov			ax, 1
		pushcall	ScrollDown, ax
		mov			ax, 2
		pushcall	ScrollRight, ax
		mov			ax, 100
		pushcall	Delay, ax
	%else
		pushcall	ScrollDown, 1
		pushcall	ScrollRight, 2
		pushcall	Delay, 100
	%endif	
	pop			cx
	loop		ShiftyLoop
	
; Minimal restoring of some stuff like TextMode and Cursor
; then exit to OS with no error code
Terminate 0

HelloWorld: 	DB "Hello,",9,"World!",CRLF,0
PressAKey: 		DB "Press a key to continue.",CRLF,0