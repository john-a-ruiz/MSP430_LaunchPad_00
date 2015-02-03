;-------------------------------------------------------------------------------
; Control structures in assembly language.
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
			mov.w	#0005h,	R4				; if then
			cmp.w	#0004h, R4
			jge		Greater
			dec		R4
			jmp		done1

Greater:	inc		R4
done1:

			mov.w	#000Ah, R4				; if then
			mov.w	#0009h, R5
			sub.w	R4, R5
			jn		Less
			dec		R5
			jmp		done2

Less:		inc		R4
done2:

			mov.w	#000Ah, R4				; for
Loop1:		dec		R4
			jne		Loop1

			mov.w	#0006h,	R4				; while
			mov.w	#0002h, R5
Loop2:		dec		R4
			cmp.w	R5, R4
			jge		Loop2

			jmp		$
;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
