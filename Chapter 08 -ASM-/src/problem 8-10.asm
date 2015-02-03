;-------------------------------------------------------------------------------
; wait for button s1 to be pushed then
; > only red led turn on for x
; > both leds turn on for x
; > only green led turn on for x
; > both leds turn off
; > repeat
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
			mov.b	#00h, P1SEL
			mov.b	#0F7h, P1DIR
			mov.b	#00h, P1OUT

Mainloop:  	bit.b	#BIT3, P1IN
			jz		Lights
			jmp		Mainloop

Lights:		call 	#Second
			bis.b	#BIT0, P1OUT
			call	#Second
			bis.b	#BIT6, P1OUT
			call	#Second
			bic.b	#BIT0, P1OUT
			call	#Second
			bic.b	#BIT6, P1OUT
			jmp		Mainloop


Second:		mov.w	#0001h, R6				; a loop to kill time so LEDs visible
			mov		#0FFFFh, R7
Loop1:		dec.w	R7
			tst		R7
			jnz		Loop1
			mov		#0FFFFh, R7
			dec		R6
			jnz		Loop1
			ret

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
