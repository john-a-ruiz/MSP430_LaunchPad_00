;-------------------------------------------------------------------------------
; Usage of the WDT+ in Watchdog Mode in assembly
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
			mov.b	#00h, P1OUT
			bis.b	#08h, P1IE
			bis.b	#08h, P1IES
			bic.b	#08h, P1IFG

			bis.w	#LPM4 + GIE, SR

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
P1_ISR		mov.b	#01h, P1OUT				; set P1.0 high
			mov.w	#LFXT1S_2, BCSCTL3		; 12kHz VLO as ACLK source
			mov.w	#WDT_ARST_1000, WDTCTL	; use WDT in watchdog mode

			; since ACLK is WDT clock source LPM4 not available because WDT prevents
			; ACLK from being disabled (slau144j 10.2.5)

			; baseline WDT_ARST_1000 = 1000ms RESET @ 32kHz
			; basleine clock/actual clock = interval
			; 32k/32k = 1s RESET
			; 32k/12k = 2.666s RESET

			bic.b	#08h, P1IFG
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
