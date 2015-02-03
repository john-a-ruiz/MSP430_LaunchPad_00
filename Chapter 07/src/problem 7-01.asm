;-------------------------------------------------------------------------------
; assume R4 = 4001h, memory 02F0h = 0F18h
;	a) two numbers are added
;	b) 1's compliment of sum is saved in R6
;	c) lsbyte and msbyte of sum are swapped and output to R12
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
			mov.w	#4001h, R4				; set up assumptions
			mov.w	#0F18h, &02F0h
			mov.w 	&02F0h,	R5				; section a
			add.w	R4, R5

			mov.w	R5, R6					; section b
			xor		#0FFFFh, R6

			mov.w	R6, R12					; section c
			swpb	R12

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
