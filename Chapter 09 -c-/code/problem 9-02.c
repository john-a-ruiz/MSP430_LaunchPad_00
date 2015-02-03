/*
 * count the number of s2 is pressed
 * a) button pressing should be defined in isr
 * b) observe count value from 'expressions' window
 */

#include <msp430.h>

int count = 0;

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	P1OUT = 0x00;
	P1SEL = 0x00;
	P1DIR = 0xF7;
	P1REN = 0x00;

	P1IES = BIT3;
	P1IFG = 0x00;
	P1IE = BIT3;

	_enable_interrupts();

	while (1);
}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR(void)
{
	count++;

	P1IFG = 0x00;
}
