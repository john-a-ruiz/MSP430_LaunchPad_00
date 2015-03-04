/*
 * The program counts how many times the button is pressed while the red and green
 * LEDs are on separately. the system disables all the interrupts and goes into LPM4
 * after a certain time.
 * SMCLK is sourced by 1MHz DCO
 */

#include <msp430.h>

#define RedLED BIT0
#define GreenLED BIT6
#define Button BIT3

int count = 0;
int redcount = 0;
int greencount = 0;
int state = 0;
int done = 0;

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	P1DIR = RedLED + GreenLED;
	P1OUT = RedLED;

	P1IE = Button;
	P1IES = Button;
	P1IFG = 0x00;

	TACCTL0 = CCIE + COM;
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

	TACCR0 = 0xFFFF;
	TACTL = TASSEL_2 + ID_3 + MC_3 + TACLR;
	// TASSEL_2	1 : clock source select - SMCLK
	// ID_3		1 : input divider - /8
	// MC_3		1 : mode control - up to TACCRO then down to 0000h ((2*TACCR0)/(CLK/8))
	// TACLR	1 : TimerA clear - resets TAR, clock divider, count direction
	// TAIE		0 : interrupt enable - disabled
	// TAIFG	0 : interrupt flag - no interrupt

	_enable_interrupts();

	while (1)
	{
		if (done > 5)
		{
			P1OUT = 0x00;
			_disable_interrupts();
			LPM4;
			// CPU, all clocks, crystal oscillator are disabled
			// DC generator is diabled
			// RAM is retained

		}
		else
			LPM1;
			// CPU, MCLK are disabled
			// DCO and DC generator are diabled if the DCO is not used for SMCLK
			// SMCLK, ACLK are active
	}
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt void TA0_ISR (void)
{
	LPM1_EXIT;				// upon exiting interrupt LPM1 is turned off.

	count++;
	if (count == 5)
	{
		P1OUT ^= RedLED + GreenLED;
		state = !state;
		count = 0;
		done++;
	}
//	LPM1_EXIT;
}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR(void)
{
	if (state == 0)
		redcount++;
	else
		greencount++;

	P1IFG = 0x00;
}
