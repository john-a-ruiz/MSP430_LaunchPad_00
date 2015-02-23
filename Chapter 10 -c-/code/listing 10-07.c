/*
 * Usage of capture mode in c
 * The capture mode is used to measure the time difference between
 * successive button presses up to 40s
 * --must connect P1.1 to P1.3---
 */

#include <msp430.h>

int count = 0;
int result = 0;
float sec = 0.0;

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	BCSCTL3 |= LFXT1S_2;
	// XT2S_0	0 : freq range select for XT2 - 0.4 - 1MHz
	// LFXT1S_2	1 : low freq clock select - VLOCLK (~12 kHz)
	// XCAP_x	0 : oscillator cap select - ~1pf

	P1SEL = 0x02;
	// P1.1 function : Timer0_A: capture - CCI0A input

	// change CM_2 to CM_3 to get 'capture on rising and falling edge'
	// so we can measure the time for the button press and release
	TACCTL0 = CAP + CM_2 + SCS + CCIE + CCIS_0;
	// CM_2		1 : capture mode - capture on falling edge
	// CCIS_0	1 : select TACCRx input signal - CCI0A
	// SCS		1 : sync input signal capture with timer - sync
	// SCCI		0 : CCI input latched with EQUx and can be read here
	// CAP		1 : capture/compare mode - capture
	// OUTMOD_0	0 : output mode - OUT bit value
	// CCIE		1 : capture/compare interrupt enable - enabled
	// CCI		0 : cap/comp input can be read here
	// OUT		0 : output - for mode 0 this bit controls state of output (0 or 1)
	// COV		0 : cap overflow - no cap overflow
	// CCIFG	0 : cap/comp interrupt flag - no interrupt

	TACTL = TASSEL_1 + ID_3 + MC_2 + TACLR;
	// TASSEL_1	1 : clock source select - ACLK
	// ID_3		1 : input divider - /8
	// MC_2		1 : mode control - continuous mode
	// TACLR	1 : TimerA clear - resets TAR, clock divider, count direction
	// TAIE		0 : interrupt enable - dissabled
	// TAIFG	0 : interrupt flag - no interrupt

	_enable_interrupts();

	LPM1;
	//	CPU, MCLK are disabled
	//	DCO and DC generator are diabled if the DCO is not used for SMCLK
	//	SMCLK, ACLK are active
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer_A(void)
{
	count++;

	if (count == 1)				// clear TimerA (start timer) on first press
		TACTL |= TACLR;

	if (count == 2)
	{
		result = TACCR0;
		sec = (float)result / 1500;
		count = 0;
	}
}
