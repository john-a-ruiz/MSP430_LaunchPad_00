/*
 * Using TA0 and TA1 together in c
 * SMCLK is sourced by 1MHz DCO
 */

#include <msp430.h>

#define RedLED BIT0
#define GreenLED BIT6

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	BCSCTL3 |= LFXT1S_2;
	// XT2S_0	0 : freq range select for XT2 - 0.4 - 1MHz
	// LFXT1S_2	1 : low freq clock select - VLOCLK (~12 kHz)
	// XCAP_x	0 : oscillator cap select - ~1pf

	P1DIR = RedLED + GreenLED;
	P1OUT = RedLED + GreenLED;

	TA0CCR0 = 62500;			// since MC_2 vs MC-1 this is superfuous
	TA1CCR0 =  6000;

	TA0CCTL0 = CCIE + COM;
	TA1CCTL0 = CCIE + COM;
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

	TA0CTL = MC_2 + ID_3 + TASSEL_2 + TACLR;
	TA1CTL = MC_3 + ID_3 + TASSEL_1 + TACLR;
	// TASSEL_2	1 : clock source select - SMCLK
	// TASSEL_1   : clock source select - ACLK
	// ID_3		1 : input divider - /8
	// MC_2		1 : mode control - continous, up to FFFFh (65535/(SMCLK/8)) = .5s
	// MC_3		  : mode control - up to TA1CCRO then down to 0000h ((2*TA1CCR0)/(ACLK/8)) = 8s
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
__interrupt void TA0_ISR(void)
{
	P1OUT ^= RedLED;
}

#pragma vector = TIMER1_A0_VECTOR
__interrupt void TA1_ISR(void)
{
	P1OUT ^= GreenLED;
}
