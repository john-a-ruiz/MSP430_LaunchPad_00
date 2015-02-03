;-------------------------------------------------------------------------------
; a) mainloop: R4, R5 are checked in infinite loop. R4 > R5 goto Greater,
;	 R4 < R5 goto Less, R4 = R5 nothing done.
; b) Greater: fill 1-5 in hex to 5 succesive memory locations then R4 -= 1
; c) Less: fill 10-6 in hex to succesive memory locations then R5 -= 1
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
			mov.w	#000Ah, R4				; Set up the initial test
			mov.w	#0005h, R5

Mainloop:	cmp.w	R5, R4					; Is R4 > R5?
			jeq		Equal
			jge		Greater
			jl		Less

Equal:		jmp		$						; R4 = R5

Greater:	mov.w	#0001h, &0200h			; R4 > R5
			mov.w	#0002h, &0202h
			mov.w	#0003h, &0204h
			mov.w	#0004h, &0206h
			mov.w	#0005h, &0208h
			dec 	R4
			jmp		Mainloop

Less:		mov.w	#000Ah, &0210h			; R4 < R5
			mov.w	#0009h, &0212h
			mov.w	#0008h, &0214h
			mov.w	#0007h, &0216h
			mov.w	#0006h, &0218h
			dec		R5
			jmp		Mainloop

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
