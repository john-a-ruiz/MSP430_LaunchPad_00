;-------------------------------------------------------------------------------
; convert four single-precision floating-point numbers &0200h to fixed-point
; UQ16.16 numbers &0300h
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
			mov.w	#4000h, &0200h			; 255.25 in floating-point
			mov.w	#437Fh, &0202h			; FF.4 in hex

			mov.w 	#0A442h, &0204h			; 5236.532 in floating-point
			mov.w	#45A3h, &0206h			; 1474.8831 (decimal approx) in hex

			mov.w	#12D7h, &0208h	 		; 5.0023 in floating-point
			mov.w	#40A0h, &020Ah			; 5.0096 in hex

			mov.w	#4300h, &020Ch			; 64323 in floating-point
			mov.w 	#477Bh, &020Eh			; FB43 in hex

			mov.w	#0200h, R8				; where we get our floats
			mov.w	#0220h, R9				; where we put our fixed
			mov.w	#4, R10					; number of floats to process

Begin:		mov.w	2(R8), R4				; getting E
			mov.w	#7F80h, R5				; mask for exponent bits
			and.w	R5, R4					; C set cuz nonzero result

			mov.w	#0007h, R6				; E in middle of byte so shift
Shift_E:	clrc							; 7 to right to get E
			rrc.w	R4
			dec.w	R6
			jnz		Shift_E
			sub.w	#127, R4				; E - 127 = exponent value (e)

			mov.w	#15, R5					; if e > 15 too large for
			cmp.w	R4, R5					; UQ16.16
			jn		End

			mov.w	@R8+, R5				; F is straddled between 2 bytes
			mov.w	@R8+, R6				; so shift left to align
			mov.w	#8, R7					; shift 8 bits (over E)
Shift_F:	rla.w	R6						; begin shifting
			rla.w	R5
			adc.w	R6
			dec.w	R7
			jnz		Shift_F
			bis.w	#8000h, R6				; R6 R5 contain un-normalized number
											; add 1 to msb to account for e

			mov.w	#15, R7					; shift R6 R5 to right 15 - e bits
			sub.w	R4, R7					; to get fixed-point value
			jz		Store					; if number doesn't need to be shifted

Shift_FP:	clrc
			rrc.w	R6
			rrc.w	R5
			dec.w	R7
			jnz		Shift_FP

Store:		mov.w	R5, 0(R9)
			mov.w	R6,	2(R9)
			add.w	#4, R9
			dec		R10
			jnz		Begin

End:		jmp		$

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
