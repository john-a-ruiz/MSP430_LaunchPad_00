;-------------------------------------------------------------------------------
; the output of PWM is is fed to the green LED and the duty cycle observed by the
; brightness of the LED
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
			bis.b	#40h, P1DIR
			bis.b	#40h, P1SEL

			mov.w	#0FFFh - 1, TACCR0		; PWM period
			mov.w	#OUTMOD_7, CCTL1

			mov.w	#00FFh, TACCR1			; PWM duty cycle
			mov.w	#TASSEL_2 + MC_1, TACTL

			bis.w	#LPM1, SR				; CPU off

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------



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
