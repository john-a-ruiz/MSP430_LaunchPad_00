;-------------------------------------------------------------------------------
; Usage of the Comparator_A+ module in assembly language
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
;         	Main Loop
;-------------------------------------------------------------------------------
			bis.b	#41h, P1DIR

			mov.b	#CARSEL + CAREF_1 + CAON, CACTL1
			mov.b	#P2CA4, CACTL2

Mainloop:	bit.b	#CAOUT, CACTL2
			jz		REDLED

GREENLED:	bis.b	#40h, P1OUT
			bic.b	#01h, P1OUT
			jmp		Mainloop

REDLED:		bis.b	#01h, P1OUT
			bic.b	#40h, P1OUT
			jmp		Mainloop
;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------



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

			.end
