/*
 * arithmetic operatiions
 */

#include <msp430.h>

void main(void)
{
	WDTCTL = WDTPW|WDTHOLD;

	int a = 32767;
	int b;
	unsigned int c = 0xFFFF;
	unsigned char d = 0x00;
	int e = 10;
	float f = 10.1;
	int g = 0;
	float h = 0.0;

	a += 1;
	b = 17 / 2;
	c += 0x0001;
	d -= 0x01;
	e /= 0;
	f /= 0;
	g /= g;
	h /= h;
}

