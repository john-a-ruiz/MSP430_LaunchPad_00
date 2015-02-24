;-------------------------------------------------------------------------------
; usage of the TAIV in assembly.
; The red LED toggles when an overflow occurs (~1s).
; The capture/compare block is not used
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
			mov.b	#01h, P1DIR
			mov.b	#01h, P1OUT

			mov.w	#TASSEL_2 + ID_3 + MC_3 + TAIE, TACTL
			; TASSEL_2	1 : clock source select - SMCLK
			; ID_3		1 : input divider - /8
			; MC_3		1 : mode control - up/down mode
			; TACLR		0 : TimerA clear - resets TAR, clock divider, count direction
			; TAIE		1 : interrupt enable - enabled
			; TAIFG		0 : interrupt flag - no interrupt

			mov.w 	#62500d, TACCR0

			bis.w 	#GIE + LPM1, SR;
			; CPU, MCLK are disabled
			; DCO and DC generator are diabled if the DCO is not used for SMCLK
			; SMCLK, ACLK are active

			jmp		$

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
T0_A1_ISR	add.w	&TAIV, PC				; 144j 12.2.6.3 (add offset to jump)

			reti							; vector 0: no interrupt
			jmp		CCIFG_1_HND				; vector 2: TACCR1
			jmp		CCIFG_2_HND				; vector 4: TACCR2
			reti							; vector 6: reserved
			reti							; vector 8: reserved

TAIFG_HND:									; vector A: TAIFG
			xor.b 	#01h, P1OUT				; toggle LED

CCIFG_1_HND:
			reti

CCIFG_2_HND:
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

			.sect 	TIMER0_A1_VECTOR
			.short	T0_A1_ISR
