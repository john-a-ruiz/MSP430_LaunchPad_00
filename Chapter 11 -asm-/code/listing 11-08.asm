;-------------------------------------------------------------------------------
; if the input voltage is greater than .5*Vcc the red LED turns on
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
			mov.w	#ADC10SHT_2 + ADC10ON + ADC10IE, ADC10CTL0
			; sample for 16 cycles, enable interrupt, ADC on

			mov.w	#INCH_1, ADC10CTL1
			; A1 is input

			bis.b	#02h, ADC10AE0
			; A1 is enabled

			bis.b	#01h, P1DIR
			; LED1 is output

Mainloop:	bis.w	#ENC + ADC10SC, ADC10CTL0
			; start sampling/conversion

			bis.w	#LPM0 + GIE, SR
			; LPM0, ADC10_ISR will force exit

			bic.b 	#01h, P1OUT
			cmp.w	#01FFh, ADC10MEM
			; ADC10MEM = A1 > 0.5*Vcc?

			jlo		Mainloop		; again
			bis.b	#01h, P1OUT
			jmp		Mainloop


;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
ADC10_ISR
			bic.w	#LPM0, 0(SP)	; exit LPM0 on reti
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

            .sect	ADC10_VECTOR
            .short	ADC10_ISR

            .end
