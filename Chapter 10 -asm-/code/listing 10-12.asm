;-------------------------------------------------------------------------------
; Toggling the red LED using the timer interrupt in compare mode in assembly
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
			mov.w	#LFXT1S_2, &BCSCTL3		; 12kHz VLO as ACLK
			; XT2S_0	0 : freq range select for XT2 - 0.4 - 1MHz
			; LFXT1S_2	1 : low freq clock select - VLOCLK (~12 kHz)
			; XCAP_x	0 : oscillator cap select - ~1pf

			mov.b	#41h, P1DIR
			mov.b	#01h, P1OUT

			mov.w	#999d, TACCR0			; TACCR0 counts to 1000;
			mov.w	#CCIE + COM, TACCTL0	; TACCR0 interrupt enabled
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

			mov.w	#TASSEL_1 + MC_1, TACTL	; ACLK, upmode
			; TASSEL_1	1 : clock source select - ACLK
			; ID_0		0 : input divider - /1
			; MC_1		1 : mode control - up mode
			; TACLR		0 : TimerA clear - resets TAR, clock divider, count direction
			; TAIE		0 : interrupt enable - disable
			; TAIFG		0 : interrupt flag - no interrupt

			bis.w	#LPM1 + GIE, SR
			; CPU, MCLK are disabled
			; DCO and DC generator are diabled if the DCO is not used for SMCLK
			; SMCLK, ACLK are active

			jmp		$

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
TA0_ISR		xor.b	#41h, P1OUT
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

			.sect	TIMER0_A0_VECTOR
			.short	TA0_ISR

			.end
