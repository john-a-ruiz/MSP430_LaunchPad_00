;-------------------------------------------------------------------------------
; a) two binary number saved to separate memory locations
; b) an overflow will occur during addition
; c) an overflow will not occur
;    *check overflow using the SR (status register)
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
			mov.w 	#0010b, &0200h			; section a
			mov.w	#0001b,	&0202h

			mov.w	#7FFFh, &0204h			; section b
			mov.w	#0001h, &0206h
			add.w	&0204h, &0206h

			mov.w	#00F3h, &0208h			; sectoin c
			mov.w	#01F7h,	&020Ah
			add.w	&0208h, &020Ah

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
