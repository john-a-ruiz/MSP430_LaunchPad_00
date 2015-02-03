/*
 * C program for data types
 */

#include <msp430.h>

char a = '@';
short b = -1;
int c = 2;
long d = 3;
float e = 12.3;
float f = -255.25;

void main(void)
{
	WDTCTL = WDTPW|WDTHOLD;

	a = '@';

	while (1);
}
