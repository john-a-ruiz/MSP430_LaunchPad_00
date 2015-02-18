/*
 * Usage of the WDT+ in watchdog mode in c
 */

#include <msp430.h>

#define RedLED BIT0
#define Button BIT3

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	P1DIR = RedLED;
	P1OUT = 0x00;
	P1IE = Button;
	P1IES = Button;
	P1IFG = 0x00;

	_enable_interrupt();

	LPM4;
}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR(void)
{
	P1OUT = RedLED;
	BCSCTL3 |= LFXT1S_2;			// setting VLO @ 12kHz as ACLK source

	WDTCTL = WDT_ARST_1000;
	// since ACLK is WDT clock source LPM4 not available because WDT prevents
	// ACLK from being disabled (slau144j 10.2.5)

	// baseline WDT_ARST_1000 = 1000ms @ 32kHz
	// basleine clock/actual clock = interval
	// 32k/32k = 1s
	// 32k/12k = 2.666s

	P1IFG = 0x00;
}
