;-------------------------------------------------------------------------------
; a) when lsb of R4 and R5 have 1, R9 = 0FF0h
; b) when only register's lsb is 1 then the 1's comp of R9 -> R10
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
			mov.w 	#0000h, R4
			mov.w 	#0001h, R5

Again:		mov.w	R4, R6					; test the lsb's of R4 and R5
			mov.w	R5, R7
			and.w	#1, R6
			and.w 	#1, R7
			bit.w	R6, R7
			jnz		PartA					; if R4 = R5 = 1, R9 = 0FF0h
			xor.w	R6, R7
			jnz		PartB
			add.w 	#0001h, R4				; else incriment R4, R5. go again
			add.w	#0001h, R5
			jmp		Again

PartA:		mov.w	#0FF0h, R9
			jmp		End
PartB:		mov.w	R9, R10
			inv.w	R10

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
