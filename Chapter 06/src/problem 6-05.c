/*
 * find first four values of varialble y
 */

#include <msp430.h>

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;

	int a = 4;
	int mask = 0x0003;
	int y = 0xFFFF;

	while (a)
	{
		a -= 1;
		y = (y ^ mask) & a;
	}

	while (1);
}
