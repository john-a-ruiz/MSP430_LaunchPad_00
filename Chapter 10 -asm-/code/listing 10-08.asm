;-------------------------------------------------------------------------------
; * Usage of capture mode in assembly
; * The capture mode is used to measure the time difference between
; * successive button presses up to 40s
; * --must connect P1.1 to P1.3---
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
			mov.w	#LFXT1S_2, BCSCTL3
			; XT2S_0	0 : freq range select for XT2 - 0.4 - 1MHz
			; LFXT1S_2	1 : low freq clock select - VLOCLK (~12 kHz)
			; XCAP_x	0 : oscillator cap select - ~1pf

			mov.b	#02h, P1SEL
			; P1.1 function : Timer0_A: capture - CCI0A input

			; change CM_1 to CM_3 to get 'capture on rising and falling edge'
			; so we can measure the time for the button press and release
			mov.w	#CAP + CM_1 + SCS + CCIE + CCIS_0, TACCTL0
			; CM_1		1 : capture mode - capture on rising edge
			; CCIS_0	1 : select TACCRx input signal - CCI0A
			; SCS		1 : sync input signal capture with timer - sync
			; SCCI		0 : CCI input latched with EQUx and can be read here
			; CAP		1 : capture/compare mode - capture
			; OUTMOD_0	0 : output mode - OUT bit value
			; CCIE		1 : capture/compare interrupt enable - enabled
			; CCI		0 : cap/comp input can be read here
			; OUT		0 : output - for mode 0 this bit controls state of output (0 or 1)
			; COV		0 : cap overflow - no cap overflow
			; CCIFG		0 : cap/comp interrupt flag - no interrupt

			mov.w	#TASSEL_1 + ID_3 + MC_2 + TACLR, TACTL
			; TASSEL_1	1 : clock source select - ACLK
			; ID_3		1 : input divider - /8
			; MC_2		1 : mode control - continuous mode
			; TACLR		1 : TimerA clear - resets TAR, clock divider, count direction
			; TAIE		0 : interrupt enable - dissabled
			; TAIFG		0 : interrupt flag - no interrup

			clr.w 	R6
			clr.w	R7
			bis.w	#GIE + LPM1, SR
			; CPU, MCLK are disabled
			; DCO and DC generator are diabled if the DCO is not used for SMCLK
			; SMCLK, ACLK are active

			jmp 	$
;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
TA0_ISR		inc.w	R6
			cmp.w	#1d, R6
			jne		Loop1
			bis.w	#TACLR, TACTL			; on first press reset TimerA

Loop1:		cmp.w	#2d, R6
			jne		Loop2
			mov.w	&TACCR0, R7				; place value of TimerA into R7
			clr.w	R6

Loop2:		reti


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
