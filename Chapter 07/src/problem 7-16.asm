;-------------------------------------------------------------------------------
; a) write subroutine which and's 1st and 2nd then or's result and 3rd.
; b) result into memory 020Dh
; c) can't change numbers in addresses
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
			mov.w	#007Dh, &0200h			; the first number
			mov.w	#00B5h, &0202h			; the second number
			mov.w	#00E8h, &0204h			; the third number

			call	#Subroutine

			jmp		$

Subroutine:
			mov.w	&0200h, R4				; section a
			mov.w	&0202h, R5
			mov.w	&0204h, R6
			and.w	R4, R5
			bis.w	R5, R6

			mov.w	R6, &020Dh				; section b

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
