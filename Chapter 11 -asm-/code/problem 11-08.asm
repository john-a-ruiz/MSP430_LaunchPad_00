;-------------------------------------------------------------------------------
;    A battery charge controller
; 1) battery will be connected between P1.1 and GND
; 2) use ADC10
; 3) the control operation will only happen when S2 is pushed
; 4) system will be in low-power mode during idle times
; 5) battery above threshold (i.e. .32 * Vcc) green LED
; 6) battery below threshold (i.e. .32 * Vcc) red LED
; 7) the DTC module to take 16 samples and calculate the average

********** NOT USING FLOAT, JUST REGULAR INTEGER *********************
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
			call	#ADC_init

			; int voltage[16] = {0} :: &0200h
			mov		#0200h, R4
voltage:	mov		#0, 0(R4)
			incd	R4
			cmp		#0220h, R4
			jne		voltage

			; int average :: &0222h
			mov		#0, &0220h

			mov		#LPM3 + GIE, SR

WHILE:		mov		&ADC10CTL1, R4			; wait for ADC to be ready
			and		#01h, R4
			cmp		#01h, R4				; 1 = busy, 0 = ready
			jeq		WHILE

			mov		#0200h, ADC10SA
			bis		#ADC10ON + ENC + ADC10SC, ADC10CTL0

			; for (i = 0, i < 16; i--)
			;     average += voltage[i]
			mov		#0, R4
			mov		#0200h, R5	; voltage
sum:		mov		&0220h, R6  ; average
			mov		0(R5), R7	; copy voltage
			add		R6, R7		; average + voltage = R7
			mov		R7, &0220h 	; R7 -> average
			incd	R5
			cmp		#0220h, R5
			jne		sum

			; average /= 16
			rra		R7			; average / 2
			rra		R7			; average / 4
			rra		R7			; average / 8
			rra		R7			; average / 16
			mov		R7, &0220h

			cmp		#005Ch, R7
			jlo		else
			bis.b	#BIT6, P1OUT
			call	#DELAY
			bic.b	#BIT6, P1OUT
			jmp		out
else:		bis.b	#BIT0, P1OUT
			call	#DELAY
			bic.b	#BIT0, P1OUT

out:		bic		#ADC10ON + ENC, ADC10CTL0
			mov		#0000, &0220h
			bis		#LPM3, SR
			jmp		WHILE


DELAY:		mov		#002Fh, R4
loop1:		mov		#0FFFFh, R5
loop0:		dec		R5
			jnz		loop0
			dec		R4
			jnz		loop1
			ret



GPIO_init:	; Port 1
	 		; P1.0 : red LED
	 		; P1.1 : ADC input A1
	 		; P1.3 : push-button S2
	 		; P1.6 : green LED
	 		mov.b	#00h, P1OUT
	 		mov.b	#00h, P1SEL
	 		mov.b	#0F7h, P1DIR
	 		mov.b	#00h, P1REN
	 		mov.b	#08h, P1IES
	 		mov.b	#00h, P1IFG
	 		mov.b	#08h, P1IE

	 		; Port 2
	 		mov.b	#00h, P2OUT
	 		mov.b	#00h, P2SEL
	 		mov.b	#0FFh, P2DIR
	 		mov.b	#00h, P2REN
	 		mov.b	#00h, P2IES
	 		mov.b	#00h, P2IE
	 		ret

BCS_init:	mov		#CALBC1_1MHZ, R4		; if no calibration then trap
			cmp		#0FFh, 0(R4)
			jeq		trap

			mov		#00h, DCOCTL			; set DCO to 1 MHz calibration
			mov		#CALBC1_1MHZ, BCSCTL1
			mov		#CALDCO_1MHZ, DCOCTL

			; MCLK = DCO, SMCLK = VLO, ACLK = VLO
			bis		#XT2OFF + DIVA_0, BCSCTL1
			mov		#SELM_1 + DIVM_0 + SELS_1 + DIVS_0, BCSCTL2
			mov		#XT2S_0 + LFXT1S_2, BCSCTL3
			ret

trap:		jmp		$

ADC_init:	mov		#SREF_0 + ADC10SHT_2 + MSC, ADC10CTL0
			mov		#INCH_1 + SHS_0 + ADC10SSEL_0 + CONSEQ_2, ADC10CTL1
			mov		#BIT1, ADC10AE0
			mov		#16, ADC10DTC1
			ret

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
PORT1_ISR
			bic		#ADC10ON, ADC10CTL0
			bic		#LPM3, 0(SP)
			bic		#BIT3, P1IFG
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

            .sect	PORT1_VECTOR
            .short	PORT1_ISR

            .end
