;-------------------------------------------------------------------------------
; Turn on and off LEDs by the total number of interrupts caused by s2
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
			mov.b	#41h, P1DIR
			bic.b	#41h, P1OUT

			bis.b	#08h, P1IE				; 1.3 interrupt enable
			bis.b	#08h, P1IES				; 1.3 low triggers interrupt
			bic.b	#08h, P1IFG				; 1.3 interrupt flag is clear

			clr 	R5

			bis.w 	#GIE, SR 				; enable all interrupts

			jmp		$

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
P1_ISR		inc 	R5
			cmp.w 	#4, R5
			jeq		RedLED
			cmp.w	#6, R5
			jeq		GreenLED
			bic.b	#08h, P1IFG
			reti

RedLED:		bis.b	#01h, P1OUT
			bic.b	#40h, P1OUT
			bic.b	#08h, P1IFG
			reti

GreenLED:	bis.b	#BIT6, P1OUT
			bic.b	#BIT0, P1OUT
			clr		R5
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

            .sect	PORT1_VECTOR
            .short	P1_ISR
