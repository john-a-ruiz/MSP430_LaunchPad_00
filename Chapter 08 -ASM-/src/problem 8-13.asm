;-------------------------------------------------------------------------------
; green led is on
; wait for button s2 to be pushed 4 times then
; > red led on and green led off
; wait for button s2 to be pushed 2 more times then
; > green led on and red led off
; repeat
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
                                            ; Main loop here
;-------------------------------------------------------------------------------
			mov.b 	#00h, P1SEL
			mov.b	#0F7h, P1DIR
			mov.b	#40h, P1OUT

Mainloop	clr.w	R4						; how many times s2 pushed
Button4:	bit.b	#BIT3, P1IN				; testing if s2 pushed
			jnz		Button4
			call	#Time					; so button only registers once
			inc.w	R4
			mov		#4, R5
			cmp		R4, R5
			jnz		Button4

			bis.b	#BIT0, P1OUT			; red LED on
			bic.b	#BIT6, P1OUT			; green LED off

Button2:	bit.b	#BIT3, P1IN				; testing if s2 pushed
			jnz		Button2
			call	#Time
			inc		R4
			mov		#6, R5
			cmp		R4, R5
			jnz		Button2

			bis.b	#BIT6, P1OUT			; green LED on
			bic.b	#BIT0, P1OUT			; red LED off

			jmp		Mainloop



Time:		mov.w	#0001h, R6				; a loop to kill time so button doesn't
			mov		#0FFFFh, R7				; register > 1 push and to be able to
Loop1:		dec.w	R7						; see lights
			tst		R7
			jnz		Loop1
			mov		#0FFFFh, R7
			dec		R6
			jnz		Loop1
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
