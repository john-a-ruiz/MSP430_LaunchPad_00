;-------------------------------------------------------------------------------
; initialize two global integer arrays x[10] and y[10]
; when S2 us pushed an ISR will:
;  -calculate y[n] = 2*x[n] - x[n-1]
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
			mov.b	#00h, P1OUT
			mov.b	#00h, P1SEL
			mov.b	#0F7h, P1DIR
			mov.b	#00h, P1REN

			mov.b	#BIT3, P1IES
			clr.b	P1IFG
			mov.b	#BIT3, P1IE

			; initializing x[10]
			mov		#0005h, &0200h
			mov		#0002h, &0202h

			mov		#0008h, &0204h
			mov		#000Ah, &0206h

			mov		#0001h, &0208h
			mov		#0000h, &020Ah

			mov		#000Ch, &020Ch
			mov		#0003h, &020Eh

			mov		#0009h, &0210h
			mov		#0001h, &0212h

			; initializing y[10]
			clr		&0220h
			clr 	&0222h
			clr		&0224h
			clr		&0226h
			clr		&0228h
			clr		&022Ah
			clr		&022Ch
			clr		&022Eh
			clr		&0230h
			clr		&0232h

			mov		#0, &0240h			; the n in x[n] and y[n]

			mov.b	#GIE, SR

			jmp		$

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
P1_ISR		tst		&0240h
			jeq		First

Rest:		mov		&0240h, R4			; n
			mov		#0202h, R5			; x[n]
			mov		#0222h, R6			; y[n]

Math:		mov		0(R5), R7
			add		R7, R7				; 2*x[n]

			mov		R5, R8
			decd	R8					; x[n-1]

			sub		0(R8), R7			; 2*x[n] - x[n-1]
			mov 	R7, 0(R6)			; y[n] = 2*x[n] - x[n-1]

			inc		R4
			incd	R5
			incd	R6

			cmp		#10, R4
			jnz		Math

End:		bic.b	#BIT3, P1IFG
			reti

First:		mov		&0200h, R4
			add		&0200h, R4
			mov		R4, &0220h
			inc		&0240h
			jmp		Rest


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
			.short	P1_ISR
