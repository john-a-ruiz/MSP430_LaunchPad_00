;-------------------------------------------------------------------------------
; using TA0 and TA1 together in assembly
; the SMCLK is sourced by 1MHz DCO
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
			bis.w 	#LFXT1S_2, BCSCTL3
			; XT2S_0	0 : freq range select for XT2 - 0.4 - 1MHz
			; LFXT1S_2	1 : low freq clock select - VLOCLK (~12 kHz)
			; XCAP_x	0 : oscillator cap select - ~1pf

			mov.b	#41h, P1DIR
			mov.b	#41h, P1OUT

			mov.w 	#CCIE + COM, TA0CCTL0	; TA0CCR0 interrupt enabled
			mov.w 	#CCIE + COM, TA1CCTL0	; TA1CCR0 interrupt enabled
			; CM_1		0 : capture mode - disabled
			; CCIS_0	0 : select TACCRx input signal - CCI0A
			; SCS		0 : sync input signal capture with timer - unsync
			; SCCI		0 : CCI input latched with EQUx and can be read here
			; COM		1 : capture/compare mode - compare
			; OUTMOD_0	0 : output mode - OUT bit value
			; CCIE		1 : capture/compare interrupt enable - enabled
			; CCI		0 : cap/comp input can be read here
			; OUT		0 : output - for mode 0 this bit controls state of output (0 or 1)
			; COV		0 : cap overflow - no cap overflow
			; CCIFG		0 : cap/comp interrupt flag - no interrupt

			mov.w	#62500d, TA0CCR0		; TA0CCR0 counts to 62500
			mov.w	#6000d , TA1CCR0		; TA1CCR0 counts to 6000

			mov.w	#TASSEL_2 + MC_2 + ID_3 + TACLR, TA0CTL
			mov.w	#TASSEL_1 + MC_3 + ID_3 + TACLR, TA1CTL
			; TASSEL_2	1 : clock source select - SMCLK
			; TASSEL_1	  : clock source select - ACLK
			; ID_3		0 : input divider - /8
			; MC_2		1 : mode control - continuous, up to FFFFh (65535/(SMCLK/8)) = .5s
			; MC_3		  : mode control - up/down, up to TA1CCRO then down to 0000h ((2*TA1CCR0)/(ACLK/8)) = 8s
			; TACLR		1 : TimerA clear - resets TAR, clock divider, count direction
			; TAIE		0 : interrupt enable - disable
			; TAIFG		0 : interrupt flag - no interrupt

			bis.w 	#LPM1 + GIE, SR

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
TA0_ISR		xor.b	#01h, P1OUT
			reti

TA1_ISR		xor.b	#40h, P1OUT
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

			.sect 	TIMER0_A0_VECTOR
			.short	TA0_ISR

			.sect	TIMER1_A0_VECTOR
			.short	TA1_ISR

			.end
