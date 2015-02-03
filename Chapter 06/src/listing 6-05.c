/*
 * logic operations
 */

#include <msp430.h>

void main(void)
{
	WDTCTL = WDTPW|WDTHOLD;

	unsigned char a = 0x02;
	unsigned char b = 0xFF;
	unsigned char c, d, e, f;

	c = a | b;
	d = a & b;
	e = a ^ b;
	f = ~a;

	while (1);
}
