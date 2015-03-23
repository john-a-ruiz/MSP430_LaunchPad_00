;-------------------------------------------------------------------------------
; Initially the green LED is on and the red LED is off. The CPU wakes up in periodic
; time intervals of 10s, 1 min, 1 hour, 1 day and as the CPU awakens the LEDs toggle.
; When not awake the CPU will go into a low-power mode.
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430g2553.h"       ; Include device header file

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
			call 	#BCM_init
			call 	#TIMER_A0_init

			bis.w	#LPM3 + GIE, SR

			jmp		$


GPIO_init:	; Port 1
			mov.b	#40h, P1OUT
			mov.b	#00h, P1SEL
			mov.b	#0FFh, P1DIR
			mov.b	#00h, P1REN

			mov.b	#00h, P1IES
			mov.b	#00h, P1IFG
			mov.b	#00h, P2IE

			; Port 2
			mov.b	#00h, P2OUT
			mov.b	#00h, P2SEL
			mov.b	#0FFh, P2DIR
			mov.b	#00h, P2REN

			mov.b	#00h, P2IES
			mov.b	#00h, P2IFG
			mov.b	#00h, P2IE
			ret

BCM_init:	bis.w	#SELM_0 + DIVM_0 + SELS_0 + DIVS_0, BCSCTL2
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

			bis.w 	#LFXT1S_2, BCSCTL3
			; XT2S_0	0 : freq range select for XT2 - 0.4 - 1MHz
			; LFXT1S_2	1 : low freq clock select - VLOCLK (~12 kHz)
			; XCAP_x	0 : oscillator cap select - ~1pf
			ret

TIMER_A0_init:
			mov		#CCIE + COM, TA0CCTL0
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

			mov		#TASSEL_1 + ID_3 + MC_1 + TACLR, TA0CTL
			; TASSEL_1	1 : clock source select - ACLK
			; ID_3		1 : input divider - /8
			; MC_1		1 : mode control - up mode: counts up to TACCR0
			; TACLR		1 : TimerA clear - resets TAR, clock divider, count direction
			; TAIE		0 : interrupt enable - disable
			; TAIFG		0 : interrupt flag - no interrupt

			mov		#187, TA0CCR0
			;mov		#14999, TA0CCR0
			ret

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
;_________
TIMER0_ISR
			xor.b	#BIT0, P1OUT
			xor.b	#BIT6, P1OUT
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
            .short	TIMER0_ISR

			.end
