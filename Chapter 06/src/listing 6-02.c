/*
 * listing 6-02.c
 *
 *	the sample C program, with a function
 */

#include <msp430.h>

int sum(int d, int e);

void main(void)
{
	WDTCTL = WDTPW|WDTHOLD;

	int a = 1;
	int b = 2;
	int c;

	c = sum(a,b);

	while (1);
}

int sum(int s1, int s2)
{
	int s = s1 + s2;

	return s;
}
