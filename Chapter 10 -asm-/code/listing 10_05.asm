;-------------------------------------------------------------------------------
; Usage of the WDT+ in timer mode in assembly
; The red and green LEDs toggle every 256ms by using the SMCLK/8
; The DCO is set to 1MHz:
; 	> WDT_MDLY_32 assumes 1MHz clock = 32ms interval
; 	> SMCLK = 1MHz/8, since WDT hits less frequenty interval = ~(32*8) > 256ms
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
			mov.w	#DIVS_3, BCSCTL2		; SMCLK/8
			; SELM = 00 : MCLK is DCO
			; DIVM = 00 : MCLK / 1
			; SELS = 0  : SMCLK is DCO
			; DIVS = 11 : SMCLK / 8

			mov.w	#WDT_MDLY_32, WDTCTL	; WDT as 32ms x 8 = 256ms interval
			; WDTPW	  	1 : password
			; WDTHOLD	0 : WDT = not stopped
			; WDTNMIES  0 : edge select = NMI on rising edge
			; WDTNMI    0 : RST/NMI pin = RESET
			; WDTTMSEL  1 : timer mode = interval timer
			; WDTCNTCL  1 : count clear
			; WDTSSEL	0 : WDT source = SMCLK
			; WDTIS1	0 : *see below
			; WDTIS0    0 : interval select bits = 00 (clock source / 32768)

			bis.b	#WDTIE, IE1				; enable WDT interrupt
			; NMIIE	0 : NMI not enabled
			; WDTIE	1 : WDTIFG enabled for interval timer mode

			mov.b 	#41h, P1DIR
			mov.b 	#01h, P1OUT

			bis.w	#LPM1 + GIE, SR			; enable interrupts and LPM1
			; CPU, MCLK are disabled
			; DCO and DC generator are diabled if the DCO is not used for SMCLK
			; SMCLK, ACLK are active

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
WDT_ISR		xor.b	#41h, P1OUT				; toggle P1.0 and P1.6
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

            .sect	WDT_VECTOR
            .short	WDT_ISR


