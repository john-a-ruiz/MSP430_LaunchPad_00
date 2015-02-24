/*
 * toggling the red LED using the timer interrupt in compare mode in c
 */

#include <msp430.h>

#define LED BIT0

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	P1DIR = LED;
	P1OUT = LED;

	TACCR0 = 49999;			// upper limit of count for TAR

	TACCTL0 = CCIE + COM;	// enable interrupts on compare 0
	// CM_0		0 : capture mode - disabled
	// CCIS_0	0 : select TACCRx input signal - none
	// SCS		0 : sync input signal capture with timer - not synced
	// SCCI		0 : CCI input latched with EQUx and can be read here
	// COM		0 : capture/compare mode - compare
	// OUTMOD_0	0 : output mode - OUT bit value
	// CCIE		1 : capture/compare interrupt enable - enabled
	// CCI		0 : cap/comp input can be read here
	// OUT		0 : output - for mode 0 this bit controls state of output (0 or 1)
	// COV		0 : cap overflow - no cap overflow
	// CCIFG	0 : cap/comp interrupt flag - no interrupt

	TACTL = MC_1 + ID_3 + TASSEL_2 + TACLR;
	// TASSEL_2	1 : clock source select - SMCLK
	// ID_3		1 : input divider - /8
	// MC_1		1 : mode control - up to TACCRO
	// TACLR	1 : TimerA clear - resets TAR, clock divider, count direction
	// TAIE		0 : interrupt enable - disabled
	// TAIFG	0 : interrupt flag - no interrupt

	_enable_interrupts();

	LPM1;
	// CPU, MCLK are disabled
	// DCO and DC generator are diabled if the DCO is not used for SMCLK
	// SMCLK, ACLK are active

	while (1)
		;
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt void TA0_ISR(void)
{
	P1OUT ^= LED;
}
