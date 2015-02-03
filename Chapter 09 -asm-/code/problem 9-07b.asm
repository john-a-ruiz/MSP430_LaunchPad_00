;-------------------------------------------------------------------------------
; ; wait for button s1 to be pushed then
; > only red led turn on for x
; > both leds turn on for x
; > only green led turn on for x
; > both leds turn off
; > repeat
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
			clr		P1IFG
			mov.b	#BIT3, P1IE

			bis.b	#GIE, SR

			jmp		$

;-------------------------------------------------------------------------------
;			Interrupt Servie Routines
;-------------------------------------------------------------------------------
P1_ISR		call	#Wait
			bis.b	#BIT0, P1OUT
			call	#Wait
			bis.b	#BIT6, P1OUT
			call 	#Wait
			bic.b	#BIT0, P1OUT
			call	#Wait
			bic.b	#BIT6, P1OUT
			bic.b	#BIT3, P1IFG
			reti

Wait:		mov.w	#0001h, R4
Loop2:		mov.w	#08FFFh, R5
Loop1:		dec		R5
			jne		Loop1
			dec 	R4
			jne		Loop2
			ret

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
