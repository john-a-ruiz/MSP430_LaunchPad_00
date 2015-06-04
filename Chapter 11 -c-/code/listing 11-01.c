/*
 * Usage of the Comparator_A+ module in C language
 */

#include <msp430g2553.h>

#define REDLED BIT0
#define GREENLED BIT6

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	P1DIR = BIT0 | BIT6;

	CACTL1 = CARSEL + CAREF_1 + CAON;
	// 0.25 Vcc = -comp, on

	CACTL2 = P2CA4;
	// P1.1/CA1 = +comp
	
	while (1)
	{
		if (CAOUT & CACTL2)
			P1OUT = GREENLED;
		else
			P1OUT = REDLED;
	}
}
