;-------------------------------------------------------------------------------
; Toggle red and green LEDs when the button is pressed.
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
			mov.b	#41h, P1DIR				; p1.0 and p1.6 output, rest input
			mov.b	#01h, P1OUT				; 1.0 set

			bis.b 	#08h, P1IE				; 1.3 interrupt enabled
			bis.b	#08h, P1IES				; 1.3 high to low edge
			bic.b	#08h, P1IFG				; 1.3 interrupt flag cleared

			bis.w	#GIE, SR				; enable all interrupts

			jmp		$

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
P1_ISR		xor.b	#41h, P1OUT				; 1.0 and 1.6 toggle
			bic.b	#08h, P1IFG				; 1.3 interrupt flag cleared
			reti							; return from interrupt

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

            .sect	PORT1_VECTOR
            .short	P1_ISR
