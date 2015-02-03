;-------------------------------------------------------------------------------
; green led is on
; wait for button s2 to be pushed 4 times then
; > red led on and green led off
; wait for button s2 to be pushed 2 more times then
; > green led on and red led off
; repeat
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
			mov.b	#BIT6, P1OUT
			mov.b	#00h, P1SEL
			mov.b	#0F7h, P1DIR
			mov.b	#00h, P1REN

			mov.b	#BIT3, P1IES
			clr.b	P1IFG
			mov.b	#BIT3, P1IE

			bis.b	#GIE, SR
			mov		#0000, R4

			jmp		$

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
P1_ISR		inc		R4
			cmp		#0004h, R4
			jn		Return
			bic.b	#BIT6, P1OUT
			bis.b	#BIT0, P1OUT
			cmp		#0006h, R4
			jn		Return
			bic.b	#BIT0, P1OUT
			bis.b	#BIT6, P1OUT
			mov		#0000h, R4

Return:		bic.b	#BIT3, P1IFG
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
