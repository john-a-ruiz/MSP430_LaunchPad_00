;-------------------------------------------------------------------------------
; what will the values in memory locations 02F0h - 02F8h be
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
Mainloop:	mov.w	#0006h, &02F0h
			mov.w 	#0009h, &02F2h
			clr.w	&02F6h
			clr.w	&02F8h
			mov.w	&02F2h, &02F4h
			add.w	&02F0h,	&02F4h
			cmp.w	#000Ah,	&02F4h
			jhs		Greater
			jlo		Less

Greater:	mov.w	&02F0h, &02F8h
			jmp		Mainloop

Less:		mov.w	&02F2h, &02F6h
			jmp		Mainloop

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
