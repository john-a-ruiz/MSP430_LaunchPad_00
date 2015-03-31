;-------------------------------------------------------------------------------
; Initially the green LED is on and the red LED is off. The CPU wakes up in periodic
; time intervals of 10s, 1 min, 1 hour, 1 day and as the CPU awakens the LEDs toggle.
; When not awake the CPU will go into a low-power mode. Button S2 will cause the LEDs
; to go to their initial state and the timer to reset.
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
			call 	#GPIO_init
			call	#BCS_init
			call	#TIMER_A0_init

			bis.w	#LPM3 + GIE, SR

			jmp		$

GPIO_init:
			mov.b	#40h, P1OUT				; Port 1
			mov.b	#00h, P1SEL
			mov.b	#0F7h, P1DIR
			mov.b	#00h, P1REN
			mov.b	#08h, P1IES
			mov.b	#00h, P1IFG
			mov.b	#08h, P1IE

			mov.b	#00h, P2OUT				; Port 2
			mov.b	#00h, P2SEL
			mov.b	#0FFh, P2DIR
			mov.b	#00h,P2REN
			mov.b	#00h, P2IES
			mov.b	#00h, P2IFG
			mov.b	#00h, P2IE
			ret

BCS_init:
			bis.w	#SELM_0 + DIVM_0 + SELS_0 + DIVS_0, BCSCTL2
			; SELM_0 	1 : DCOCLK
            ; DIVM_0 	1 : Divide DCOCLK by 1
            ; SELS_0 	1 : SMCLK
            ; DIVS_0 	1 : Divide SMCLK by 1
            ; DCOR_0 	0 : DCO uses internal resistor

			bis.w	#XT2OFF + DIVA_3, BCSCTL1
		    ; XT2OFF 	1 : Disable XT2CLK
		    ; XTS_0 	0 : Low Frequency Mode (only choice)
		    ; DIVA_3 	0 : Divide ACLK by 8
			; RSELx		x : Range Select

			bis.w	#XT2S_0 + LFXT1S_2, BCSCTL3
			; XT2S_0	0 : freq range select for XT2 - 0.4 - 1MHz
			; LFXT1S_2	1 : low freq clock select - VLOCLK (~12 kHz)
			; XCAP_x	0 : oscillator cap select - ~1pf
			ret

TIMER_A0_init:
			mov		#TASSEL_1 + ID_3 + MC_1 + TACLR + TAID, TA0CTL
			; TASSEL_1	1 : clock source select - ACLK
			; ID_3		1 : input divider - /8
			; MC_1		1 : mode control - up mode: counts up to TACCR0
			; TACLR		1 : TimerA clear - resets TAR, clock divider, count direction
			; TAID		1 : interrupt enable - disable
			; TAIFG		0 : interrupt flag - no interrupt
			mov   	#187, TA0CCR0

			mov		#CM_0 + SCA + COM + CCIE, TA0CCTL0
			; CM_0		1 : capture mode - no capture
			; CCIS_0	0 : select TACCRx input signal - CCI0A
			; SCA		1 : sync input signal capture with timer - asynchronous
			; SCCI		0 : CCI input latched with EQUx and can be read here
			; COM		1 : capture/compare mode - compare
			; OUTMOD_0	0 : output mode - OUT bit value
			; CCIE		1 : capture/compare interrupt enable - enabled
			; CCI		0 : cap/comp input can be read here
			; OUT		0 : output - for mode 0 this bit controls state of output (0 or 1)
			; COV		0 : cap overflow - no cap overflow
			; CCIFG		0 : cap/comp interrupt flag - no interrupt
			ret
;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
;________
PORT1_ISR
			mov.b	#40h, P1OUT
			mov		#00h, TAR
			bic.b	#BIT3, P1IFG
			reti

;_________
TIMER0_ISR
			xor.b	#BIT0 + BIT6, P1OUT
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
			.short	PORT1_ISR

			.sect	TIMER0_A0_VECTOR
			.short	TIMER0_ISR

			.end
