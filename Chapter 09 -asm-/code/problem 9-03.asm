;-------------------------------------------------------------------------------
; count the number of times s2 is pressed
; a) button pressing should be defined in isr
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
			mov.b	#00h, P1OUT
			mov.b	#00h, P1SEL
			mov.b	#0F7h, P1DIR
			mov.b	#00h, P1REN

			mov.b	#BIT3, P1IES
			clr.b	P1IFG
			mov.b	#BIT3, P1IE

			clr		R4

			bis.w	#GIE, SR

			jmp		$

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
P1_ISR		inc		R4

			bic.b	#BIT3, P1IFG
			reti

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

			.sect 	PORT1_VECTOR
			.short	P1_ISR
