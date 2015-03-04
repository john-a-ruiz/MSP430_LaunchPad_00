;-------------------------------------------------------------------------------
; The program counts how many times the button is pressed while the red and green
; LEDs are on separately. the system disables all the interrupts and goes into LPM4
; after a certain time.
; SMCLK is sourced by 1MHz DCO
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
			mov.w	#0d, R5					; used as count
			mov.w	#0d, R6					; used as done
			mov.w	#0h, R7					; used as state
			mov.w	#0d, R8					; used as redcount
			mov.w	#0d, R9					; used as greencount

			mov.b	#41h, P1DIR
			;mov.b	#08h, P1REN				; LaunchPad rev 1.4 doesn't need it
			mov.b	#09h, P1OUT

			bis.b	#08h, P1IE
			bis.b	#08h, P1IES
			bis.b	#08h, P1IFG

			mov.w	#0FFFFh, TACCR0
			mov.w	#TASSEL_2 + MC_3 + ID_3 + TACLR, TACTL
			mov.w	#CCIE + COM, TACCTL0

			bis.w	#GIE, SR

Loop:		cmp 	#06d, R6
			jl 		Subloop
			clr.b	P1OUT
			bic.w	#GIE, SR
			bis.w	#LPM4, SR

Subloop:	bis.w	#LPM1, SR
			jmp		Loop

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
P1_ISR		tst.w	R7						; check the button
			jeq		Red
			inc		R9
			jmp		Ei

Red:		inc		R8

Ei:			bic.b	#08h, P1IFG
			reti

TA0_ISR		bic.w	#LPM1, 0(SP)			; toggle P1
			inc		R5
			cmp.w	#04d, R5
			jl		EndISR
			xor.b	#41h, P1OUT
			inc		R6,
			mov		#0d, R5
			xor		#01d, R7

EndISR:		reti

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

            .sect	TIMER0_A0_VECTOR
			.short	TA0_ISR

			.end

