/*
 * Count the number of button presses by interrupts in C
 */

#include <msp430.h>

#define BUTTON BIT3

int count = 0;

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	P1IE = BUTTON;				// Enable interrupt from port 1
	P1IES = BUTTON;				// Interrupt edge select from high to low
	P1IFG = 0x00;				// Clear the interrupt flag

	_enable_interrupts();		// enable all interrupts

	while(1);
}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR(void)
{
	count += 1;
	P1IFG = 0x00;				// clear the interrupt flag
}
