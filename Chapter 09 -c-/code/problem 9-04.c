/*
 * count the number of button pushes using an isr
 * a) green LED on at beginning
 * b) when button is pressed in multiples of 5 then LED will toggle
 */

#include <msp430.h>

int count = 0;

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	P1OUT = BIT6;
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
	count++;

	if (count == 5)
	{
		P1OUT ^= BIT6;
		count = 0;
	}

	P1IFG &= ~BIT3;
}
