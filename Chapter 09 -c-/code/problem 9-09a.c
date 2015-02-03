/*
 * green led is on
 * wait for button s2 to be pushed 4 times then
 * > red led on and green led off
 * wait for button s2 to be pushed 2 more times then
 * > green led on and red led off
 * repeat
 */

#include <msp430.h>

#define RED_ON (P1OUT |= BIT0)
#define RED_OFF (P1OUT &= ~BIT0)
#define GREEN_ON (P1OUT |= BIT6)
#define GREEN_OFF (P1OUT &= ~BIT6)

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	P1OUT = 0x40;
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
	static int pushes = 0;

	pushes++;

	if (pushes == 4)
	{
		RED_ON;
		GREEN_OFF;
	}

	if (pushes == 6)
	{
		GREEN_ON;
		RED_OFF;
		pushes = 0;
	}

	P1IFG &= ~BIT3;
}
