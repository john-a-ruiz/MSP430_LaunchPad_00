;-------------------------------------------------------------------------------
; a) two binary number saved to separate memory locations
; b) an overflow will not occur during addition
;    *check overflow using the SR (status register)
; c) if result is greater/less than 0 jump to label greater/less
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
			mov.w 	#0010h, R5				; section a
			mov.w	#8010h,	R6

			mov.w	#-35, R7				; sectoin b
			mov.w	#81, R8
Greater:	sub		#1,	 R8
			add.w	R7, R8
			jge		Greater
			jl		Less

			mov.w	#0,  R8
Less:		add.w	#15, R8

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
