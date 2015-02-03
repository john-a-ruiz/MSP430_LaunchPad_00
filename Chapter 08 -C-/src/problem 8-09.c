/*
 * wait for button s1 to be pushed then
 * > only red led turn on for x
 * > both leds turn on for x
 * > only green led turn on for x
 * > both leds turn off
 * > repeat
 */
#include <msp430.h>

#define BUTTON_PUSHED ((P1IN & BIT3) == 0x00)
#define RED_ON	(P1OUT |= BIT0)
#define RED_OFF	(P1OUT &= ~BIT0)
#define GREEN_ON (P1OUT |= BIT6)
#define GREEN_OFF (P1OUT &= ~BIT6)

void second(void);

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	P1SEL = 0x00;
	P1DIR = 0xF7;
	P1OUT = 0x00;

	while (1)
	{
		if (BUTTON_PUSHED)
		{
			second();
			RED_ON;
			second();
			GREEN_ON;
			second();
			RED_OFF;
			second();
			GREEN_OFF;
		}
	}
}

void second(void)
{
	int i = 0;

	for (i = 200; i > 0; i--)		// .005 * 200 = 1s
		__delay_cycles(5000);		// 5ms delay
}
