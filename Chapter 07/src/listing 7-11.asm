;-------------------------------------------------------------------------------
; Usage of arithmetic, logical and register control, data, and jump istructions.
;
;
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
			mov.w	#0009h,	R5				; Arithmetic Instructions
			mov.w	#0006h, R6
			add.w	R5,	R6
			mov.w	#0006h, R6
			dadd.w	R5,	R6
			mov.w	#0006h,	R6
			sub.w	R5,	R6

			mov.b	#00001111b, R5			; Logical and Register Control Instr.
			mov.b	#00000011b, R6
			and.b 	R5, R6
			mov.b	#00000011b, R6
			xor.b	R5, R6
			rra.b	R6
			swpb	R5

			mov.w	#0006h, R5				; Data Instructions
			mov.w	#0009h, R6
			cmp.w	R5, R6

			jmp		$						; Jumpt Instructions

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
