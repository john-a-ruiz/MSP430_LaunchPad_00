/*
 * Toggling the red and green LEDs with various options in c
 * SMCLK sourced by 1MHz DCO
 */

#include <msp430.h>

#define RedLED BIT0
#define GreenLED BIT6

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	P1DIR = RedLED + GreenLED;
	P1OUT = RedLED;

	TACCTL0 = CCIE + COM;	// Enable interrupts on compare 0
	// CM_0		0 : capture mode - disabled
	// CCIS_0	0 : select TACCRx input signal - none
	// SCS		0 : sync input signal capture with timer - not synced
	// SCCI		0 : CCI input latched with EQUx and can be read here
	// COM		1 : capture/compare mode - compare
	// OUTMOD_0	0 : output mode - OUT bit value
	// CCIE		1 : capture/compare interrupt enable - enabled
	// CCI		0 : cap/comp input can be read here
	// OUT		0 : output - for mode 0 this bit controls state of output (0 or 1)
	// COV		0 : cap overflow - no cap overflow
	// CCIFG	0 : cap/comp interrupt flag - no interrupt

//	TACTL = TASSEL_2 + ID_3 + MC_2 + TACLR;
//  use clock from SMCLK, divide SMCLK/8, continuous mode (65535/fCLK), clear timerA

// 	TACTL = TASSEL_2 + ID_0 + MC_2 + TACLR;
//	the effect of the freq divider
//  use clock from SMCLK, divide SMCLK/1, continuous mode (65535/fCLK), clear timerA

// 	TACCR0 = 19999;			// Upper limit for count
//	TACTL = TASSEL_2 + ID_3 + MC_1 + TACLR;
//  use clock from SMCLK, divide SMCLK/8, up mode ((TACCRO+1)/fCLK), clear timerA

	TACCR0 = 0xFFFF; 		// upper limit for count
	TACTL = TASSEL_2 + ID_3 + MC_3 + TACLR;
	// TASSEL_2	1 : clock source select - SMCLK
	// ID_3		1 : input divider - /8
	// MC_3		1 : mode control - up to TACCRO then down to 0000h ((2*TACCRO)/fCLK)
	// TACLR	1 : TimerA clear - resets TAR, clock divider, count direction
	// TAIE		0 : interrupt enable - disabled
	// TAIFG	0 : interrupt flag - no interrup

	_enable_interrupts();

	LPM1;
	// CPU, MCLK are disabled
	// DCO and DC generator are diabled if the DCO is not used for SMCLK
	// SMCLK, ACLK are active
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt	void TA0_ISR(void)
{
	P1OUT ^= RedLED + GreenLED;
}
