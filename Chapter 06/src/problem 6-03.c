/*
 * what is the calculated value y
 */

#include <msp430.h>

void main(void)
{
	WDTCTL = WDTPW|WDTHOLD;

	int count;
	int y[5];
	int x[] = {1, 1, 0, 1, 1};
	int h[] = {1, -1, 0, 0, 0};

	for (count = 0; count < 5; count++)
		y[count] = x[count] * h[4-count];

	while (1);
}
