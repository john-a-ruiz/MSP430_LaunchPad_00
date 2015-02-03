;-------------------------------------------------------------------------------
; Digital I/O in assembly
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
			bis.b	#01000001b, P1DIR		; setting bit0 bit6 to output

Mainloop:	bit.b	#00001000b, P1IN		; masking bit3 to find state of button
			jc		Off						; if button != 0 (carry set) then goto off

On:			bic.b	#00000001b, P1OUT		; clears bit0 - rLED off
			bis.b	#01000000b,	P1OUT		; sets bit6 - gLED on
			jmp		Mainloop

Off:		bis.b	#00000001b, P1OUT		; sets bit0 - rLED on
			bic.b 	#01000000b,	P1OUT		; clears bit6 - gLED off
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
