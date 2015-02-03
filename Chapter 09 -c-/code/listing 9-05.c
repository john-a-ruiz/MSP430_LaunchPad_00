/*
 * Turn on and off LEDs by the total number of interrupts caused by button s2
 */

#include <msp430.h>

#define REDLED BIT0
#define GREENLED BIT6
#define BUTTON BIT3

//int count = 0; can use global or static

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	P1DIR = REDLED | GREENLED;
	P1OUT = 0x00;

	P1IE = BUTTON;				// enable intrrupts from port 1
	P1IES = BUTTON;				// interrupt edge select from high to low
	P1IFG = 0x00;				// clear interrupt flag

	_enable_interrupts();		// enable all interrupts

	while(1);
}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR(void)
{
	static int count;

	count++;

	if (count == 4)
		P1OUT = REDLED;

	if (count == 6)
	{
		P1OUT = 0x00;
		P1OUT = GREENLED;
		count = 0;
	}

	P1IFG = 0x00;				// clear the interrupt flag
}
