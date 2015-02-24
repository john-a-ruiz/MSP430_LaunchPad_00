/*
 * usage of the TAIV in c
 * The red LED toggles when an overflow occurs (~1s).
 * The capture/compare block is not used.
 */

#include <msp430.h>

#define RedLED BIT0
#define RedLEDToggle (P1OUT ^= RedLED)

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	P1DIR = RedLED;
	P1OUT = RedLED;

	TACTL = TASSEL_2 + ID_3 + MC_3 + TAIE;
	// TASSEL_2	1 : clock source select - SMCLK
	// ID_3		1 : input divider - /8
	// MC_2		1 : mode control - up/down (up to TACCRO then down to 0000h)
	// TACLR	0 : TimerA clear - resets TAR, clock divider, count direction
	// TAIE		1 : interrupt enable - enabled
	// TAIFG	0 : interrupt flag - no interrupt

	TACCR0 = 62500;

	_enable_interrupts();

	LPM1;
	// CPU, MCLK are disabled
	// DCO and DC generator are diabled if the DCO is not used for SMCLK
	// SMCLK, ACLK are active
}

#pragma vector = TIMER0_A1_VECTOR
__interrupt void Timer_A(void)
{
	switch (TAIV)
	{
		case 0x02: break;		// TACCR1 CCIFG
		case 0x04: break;		// TACCR2 CCIFG
		case 0x0A:				// TAIFG
			RedLEDToggle;
			break;
	}
}
