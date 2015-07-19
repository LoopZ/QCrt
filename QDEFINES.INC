; Copyright 2015 Jerome Shidel
; All rights reserved

; QCrt 9.0 Nasm Defines, Constants and Macros File

; User Configuration Defines

; %idefine Target8086 			; Uncomment to target original PC XT.
; %idefine BiosVideoOnly		; Uncomment to remove Direct Video Support
; %idefine DirectVideoOnly		; Uncomment to remove BIOS Video Support
; %idefine SaveAllRegs			; Uncomment to preserve all but return 
								; registers	in procedure calls
; %idefine TurboPascal55		; Only for TP 5.5 Objs, not for TP 7.0 or
								; anything else!!

; %idefine DoubleFonts			; Not yet implemented



; Now for all the self configuring stuff.

%idefine QDefines

%ifndef TargetOS
	%idefine TargetOS DOS
%endif

%ifndef TargetCPU
	%idefine TargetCPU 286
%endif

%ifdef TP55
	%idefine TurboPascal55
%endif

%ifdef TP70
	%idefine TurboPascal70
%endif

%ifdef TurboPascal70
	%undef TurboPascal55
%endif

; Configuring One's Self A Little Bit
%ifidni __OUTPUT_FORMAT__, obj
	%idefine FarCalls
%else
	%undef TurboPascal55
	%warning "Binary COM file creation mode."
	%ifdef SaveAllRegs
		%warning "All none return value registers are preserved."
	%else
		%warning "Only the DS, SS, SP and BP registers are preserved!"
	%endif
	; This really should not be in the defines file. But, oh well
	; we will just stick it in here anyway.
	%idefine	ASMTools
	jmp SkipOverQCrt
%endif

%ifidn TargetCPU, 8086
	cpu 8086
	%warning Attempting to generate 8086 compatible code.
%endif

%ifdef FarCalls
	%idefine XCALL  CALL FAR
	%idefine STACKBP  BP + 6
%else
	%idefine XCALL  CALL
	%idefine STACKBP  BP + 4
%endif

%idefine DVSupport
%idefine BVSupport

%ifdef DirectVideoOnly
	%undef BVSupport
%endif

%ifdef BiosVideoOnly
	%undef DVSupport
%endif

%ifdef TurboPascal55
	%warning Forcing Turbo Pascal version 5.5 compatibility.	
	%define Section_DATA DATA
	%define Section_SHARED BSS
	%define Section_CODE CODE
%else
	%define Section_DATA _DATA
	%define Section_SHARED _BSS
	%define Section_CODE _TEXT
%endif

%ifdef ASMTools
		%idefine	CRLF 0x0d,0x0a
%endif

; Constants

%idefine FALSE	00h
%idefine TRUE 	01h

; Macros

%imacro MemByte 2
	push 	es
	push 	bx
	mov		bx, %1
	mov		es, bx
	mov		bx, %2
	mov		al, [ES:BX]
	pop		bx
	pop		es 
%endmacro

%imacro MemWord 2
	push 	es
	push 	bx
	mov		bx, %1
	mov		es, bx
	mov		bx, %2
	mov		ax, [ES:BX]
	pop		bx
	pop		es 
%endmacro

%imacro pushy 1-* 
  %rep  %0 
        push    %1 
  %rotate 1 
  %endrep 
%endmacro

%imacro poppy 1-* 
  %rep  %0 
        pop    %1 
  %rotate 1 
  %endrep 
%endmacro

%imacro pushcall 1-* 
	%if %0 > 1 
		%rep %0 - 1
			%rotate 1
			push 	word %1
		%endrep
		%rotate 1
	%endif
	xcall %1 
%endmacro

%imacro ReturnsNothing 0 
	%ifdef SaveAllRegs
		%define 	export_arg none
		pushf
		pushy	ax, dx, bx, cx, si, di, es
	%endif
%endmacro

%imacro ReturnsAX 0 
	%ifdef SaveAllRegs
		%define 	export_arg word
		pushy	dx, bx, cx, si, di, es
	%endif
%endmacro

%imacro ReturnsDXAX 0 
	%ifdef SaveAllRegs
		%define 	export_arg dword
		pushy	bx, cx, si, di, es
	%endif
%endmacro

%imacro RestoreRegisters 0
	%ifdef SaveAllRegs
		poppy es, di, si, cx, bx
		%ifidn export_arg, dword
			; nothing to do here, move along
		%elifidn export_arg, word
			pop	dx
		%elifidn export_arg none
			poppy	dx, ax
			popf
		%endif 
	%endif
%endmacro

%imacro xfunction 2-*
	global %1
	%1:
		%define export_name %1
		%if %0 = 3
			%define ret_pop %3
		%else
			%define ret_pop 0
		%endif
		; %stacksize large	; not using %arg
		push bp
		mov	 bp, sp
		; %ifdef FARCALLS	; This would be needed if %arg worked 
		;	 add bp, 2 		; inside macros, but it does not so
		; %endif			; we don't need it.
		%ifidni %2, word
			ReturnsAX
		%elifidni %2, byte
			ReturnsAX
		%elifidni %2, boolean
			ReturnsAX
		%elifidni %2, char
			ReturnsAX
		%elifidni %2, integer
			ReturnsAX
		%elifidni %2, dword
			ReturnsDXAX
		%elifidni %2, long
			ReturnsDXAX
		%elifidni %2, longint
			ReturnsDXAX
		%elifidni %2, pointer
			ReturnsDXAX
		%else
			ReturnsNothing
		%endif
%endmacro

%imacro xprocedure 1-* 0
	global %1
	%1:
		%define export_name %1
		%if %0 = 2
			%define ret_pop %2
		%else
			%define ret_pop 0
		%endif
		; %stacksize large	; not using %arg
		push bp
		mov	 bp, sp
		; %ifdef FARCALLS	; This would be needed if %arg worked 
		;	 add bp, 2 		; inside macros, but it does not so
		; %endif			; we don't need it.
		ReturnsNothing
%endmacro

%imacro xret 0-1
	%ifdef FarCalls
		%idefine xret_type   RETF
	%else
		%idefine xret_type   RET
	%endif
	RestoreRegisters
	pop	bp
	%if %0 = 1 
		%warning OVERRIDE export_name: ret %1
		xret_type %1
	%elif ret_pop = 0
		xret_type
	%else
		xret_type ret_pop
	%endif
	%undef xret_type
	%undef ret_pop
	%undef export_name
	%undef export_arg
%endmacro

%imacro Terminate 0-1 0
		xcall DoneCrt
        MOV  AH, 4Ch  
        MOV  AL, %1
        INT  21h
%endmacro
