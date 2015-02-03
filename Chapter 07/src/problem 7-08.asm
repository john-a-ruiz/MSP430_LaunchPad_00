;-------------------------------------------------------------------------------
; calculate the first 10 numbers of the fibonacci series
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
			mov.w	#0000h,	&0200h			; setting up the series
			mov.w	#0001h, &0202h

			mov.w	#0200h, R4
			mov.w	#0202h, R5

			mov.w 	#0009h, R8
Fibonacci:
			mov.w	@R4+, R6
			mov.w	@R5+, R7
			add.w	R6, R7
			mov.w	R7, 0(R5)
			sub.w	#1, R8
			jge		Fibonacci

			jmp $
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
