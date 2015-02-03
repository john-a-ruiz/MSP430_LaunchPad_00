/*
 * Pointer usage example
 */

#include <msp430.h>

int a = 3;
int *a_pointer;

void main(void)
{
	WDTCTL = WDTPW|WDTHOLD;

	a_pointer = &a;
	*a_pointer = 5;

	while (1);
}
