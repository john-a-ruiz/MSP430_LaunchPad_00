;-------------------------------------------------------------------------------
;    A battery charge controller
; 1) battery will be connected between P1.1 and GND
; 2) use Comparator_A+
; 3) the control operation will only happen when S2 is pushed
; 4) system will be in low-power mode during idle times
; 5) battery above threshold (i.e. .25 * Vcc) green LED
; 6) battery below threshold (i.e. .25 * Vcc) red LED
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
			call 	#BCS_init
			call	#COMPAR_init

			bis		#GIE + LPM3, SR

While:		mov		CACTL2, R5				; get CAOUT bit
			and     #0001, R5
			tst		R5
			jne		else
;if:
			bis		#BIT0, P1OUT			; V is too low
			call	#DELAY
			bic		#BIT0, P1OUT
			jmp		CONTINUE

else:		bis		#BIT6, P1OUT			; V is good
			call	#DELAY
			bic		#BIT6, P1OUT

CONTINUE:	bic		#CAON, CACTL1
			bis		#LPM3, SR
			jmp		While

DELAY:		mov		#000Fh, R4
COUNT1:		mov		#0FFFFh, R5
COUNT:		dec		R5
			jne		COUNT
			dec		R4
			jne		COUNT1
			ret




GPIO_init:	; Port 1
			; P1.0 : red LED
			; P1.1 : copmarator input CA1
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
			mov.b	#00h, P2IFG
			mov.b	#00h, P2IE
			ret



BCS_init:	; if no 1 MHz calibration then trap
			cmp		#0FFh, CALBC1_1MHZ
			jeq		TRAP

			; set DCO to 1 MHz calibration
			mov		#00h, DCOCTL
			mov		#CALBC1_1MHZ, BCSCTL1
			mov		#CALDCO_1MHZ, DCOCTL

			; MCLK = DCO, SMCLK = VLO, ACLK = VLO
			bis		#XT2OFF + DIVA_0, BCSCTL1
			mov		#SELM_1 + DIVM_0 + SELS_1 + DIVS_0, BCSCTL2
			mov		#XT2S_0 + LFXT1S_2, BCSCTL3
			ret

TRAP:		jmp		$



COMPAR_init:
			mov		#CARSEL + CAREF_1, CACTL1	; Vref = 890mV (- terminal)
			mov		#P2CA4, CACTL2
			ret


;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
PORT1_ISR
			bis		#CAON, CACTL1
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
