/*
 * When button S2 is pressed
 * - red LED will turn on and wait
 * - both red and green LED will turn on and wait
 * - red will turn off green will be on and wait
 * - both LEDs will turn off
 */

#include <msp430.h>

#define RED_ON (P1OUT |= BIT0)
#define RED_OFF (P1OUT &= ~BIT0)
#define GREEN_ON (P1OUT |= BIT6)
#define GREEN_OFF (P1OUT &= ~BIT6)
#define WAIT (__delay_cycles(62500))

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	P1OUT = 0x00;
	P1SEL = 0x00;
	P1DIR = 0xF7;
	P1REN = 0x00;

	P1IES = BIT3;
	P1IFG = 0x00;
	P1IE = BIT3;

	_enable_interrupts();

	while(1);
}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR(void)
{
	WAIT;
	RED_ON;
	WAIT;
	GREEN_ON;
	WAIT;
	RED_OFF;
	WAIT;
	GREEN_OFF;

	P1IFG &= ~BIT3;
}
