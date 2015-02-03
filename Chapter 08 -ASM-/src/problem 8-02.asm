;-------------------------------------------------------------------------------
; caclucate number of zeros and ones in an array.
; if 0's > 1's then red LED. if 1's > 0's then green LED
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
			mov.b 	#00h, P1SEL				; set up P1
			mov.b	#0FFh, P1DIR
			mov.b	#00h, P1OUT

			mov.b	#00h, P2SEL				; set up P2
			mov.b	#0FFh, P2DIR
			mov.b	#00h, P2OUT

			mov.w 	#0200h, R4;				; initialize 10 element array in memory
			mov.w	#0, 0(R4);
			mov.w 	#0, 2(R4);
			mov.w	#0, 4(R4);
			mov.w	#0, 6(R4);
			mov.w	#0, 8(R4);
			mov.w	#0, 10(R4);
			mov.w	#1, 12(R4);
			mov.w	#1, 14(R4);
			mov.w	#1, 16(R4);
			mov.w	#1, 18(R4);

			clr		R6						; zeros
			clr		R7						; ones
			mov.w	#10, R5;				; for loop to count # of 0's & 1's
Test:		tst.w	0(R4)
			jz		Zero
			jnz		Ones
Cont:		dec		R5
			incd	R4
			tst.w	R5
			jnz		Test

			cmp.w	R6, R7					; test if ones > zeros
			jge		O_win
			jl		Z_win

End:		jmp 	$

Zero:		inc		R6
			jmp		Cont
Ones:		inc		R7
			jmp		Cont

O_win:		bis.b	#BIT0, P1OUT
			jmp		End
Z_win:		bis.b	#BIT6, P1OUT
			jmp 	End

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
