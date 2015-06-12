;-------------------------------------------------------------------------------
; The data transfer control (DTC) module and the temperature sensor  are used.
; The temperature is measured 16 times and if the avg temp > 27C then the
; red LED is turned on else the green LED remains on
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
			mov.w 	#CONSEQ_2 + INCH_10 + ADC10DIV_7, ADC10CTL1
			; repeat single channel conversion, temp sensor input, clk/8

			mov.w	#SREF_1 + MSC + ADC10SHT_3 + REFON, ADC10CTL0
			; Vref and GND, multiple sample & conversion, sample for 64 cycles
			; refernce generator on,  reference buffer  up to ~200ksps,
			; reference buffer on continuosly, 1.5V ref

			bis.w	#ADC10ON + ADC10IE, ADC10CTL0
			; adc10 is on, adc10 interrupt enabled

			mov.b	#10h, ADC10DTC1
			; 16 transfers per block

			bis.b	#41h, P1DIR				; red and green LED activated
			bic.b	#41h, P1OUT				; LED bits cleared

Mainloop:	bic.w	#ENC, ADC10CTL0
			; enable conversion

			mov.w	#0200h, ADC10SA
			; start address register for data transfer

			bis.w	#ENC + ADC10SC, ADC10CTL0
			; enable and start conversion

			bis.w	#LPM0 + GIE, SR
			; LPM0, ADC10_ISR will force exit

			call #Average

			cmp.w	#02E2h, R6				; is Temp > 27C
			jlo		Less
			bis.b	#01h, P1OUT
			jmp 	Mainloop

Less:		bis.b	#40h, P1OUT
			jmp 	Mainloop

Average:	mov.w	#0200h, R5				; set as pointer
			mov.w	#0000h, R6				; set as sum

Total:		add.w	@R5, R6
			incd.w	R5
			cmp.w	#0220h, R5
			jlo		Total
			rra.w	R6						; each time you rra you divide by 2!!!!
			rra.w	R6
			rra.w	R6
			rra.w	R6
			ret

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
ADC10_ISR
			bic.b	#41h, P1OUT
			bic.w	#LPM0, 0(SP)
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
