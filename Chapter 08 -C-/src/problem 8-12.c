/*
 * green led is on
 * wait for button s2 to be pushed 4 times then
 * > red led on and green led off
 * wait for button s2 to be pushed 2 more times then
 * > green led on and red led off
 * repeat
 */

#include <msp430.h>

#define BUTTON_PRESS ((P1IN & BIT3) == 0x00)
#define RED_ON (P1OUT |= BIT0)
#define RED_OFF (P1OUT &= ~ BIT0)
#define GREEN_ON (P1OUT |= BIT6)
#define GREEN_OFF (P1OUT &= ~BIT6)

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	P1SEL = 0x00;
	P1DIR = 0xF7;
	P1OUT = 0x40;
	int pushes = 0, flag = 0;

	while (1)
	{
		if (BUTTON_PRESS)
		{
			__delay_cycles(250000);			// wait .25s before registering a push
			pushes++;
		}

		if (pushes == 4 && flag == 0)
		{
			RED_ON;
			GREEN_OFF;
			flag = 1;
		}

		if (pushes == 6)
		{
			RED_OFF;
			GREEN_ON;
			pushes = 0;
			flag = 0;
		}
	}
}
