;-------------------------------------------------------------------------------
; a) write subroutine that R6 and 0001h -> R6
; b) repeat a over 5 successive memory locations using correct addressing mode
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
			and.w	#0001h, R6				; section a

			mov.w 	#0001h, R7				; section b
			mov.w	#0200h, R8
			and.w	R7, 0(R8)
			and.w 	R7,	2(R8)
			and.w 	R7,	4(R8)
			and.w 	R7,	6(R8)
			and.w 	R7,	8(R8)

			jmp		$
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
