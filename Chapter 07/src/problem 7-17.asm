;-------------------------------------------------------------------------------
; a) write subroutine: (first xor second) then not(result).
; b) result written to memory 023Ch
; c) can't change numbers in adresses
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
			mov.w	#2D97h, &0220h			; first number
			mov.w	#6239h, &0222h			; second number

			call	#Subroutine

			jmp		$

Subroutine:
			mov.w 	&0220h, R4
			mov.w 	&0222h, R5
			xor.w 	R4, R5
			inv		R5

			mov.w	R5, &023Ch

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
