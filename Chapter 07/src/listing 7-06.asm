;-------------------------------------------------------------------------------
; Usage of 'indexed' addressing mode.
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
			mov.w	#0000h, &0200h			; Word level operations
			mov.w	#0003h, &0202h
			mov.w 	#0005h, &0204h
			mov.w	#0007h, &0206h

			mov.w	#0200h, R5
			mov.w	0(R5),	R6
			mov.w	2(R5),	R6
			mov.w	4(R5), 	R6
			mov.w	6(R5),	R6

			mov.b	#00h,	&0200h			; Byte level operations
			mov.b	#03h,	&0201h
			mov.b	#04h,	&0202h
			mov.b	#05h,	&0203h

			mov.w	#0200h,	R5
			mov.b	0(R5),	R6
			mov.b	1(R5),	R6
			mov.b	2(R5),	R6
			mov.b	3(R5),	R6

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
