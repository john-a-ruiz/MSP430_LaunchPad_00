/*
 * Array usage example
 */

#include <msp430.h>

int a[5] = {1, 2, 3, 4, 5};
int *a_pointer;

void main(void)
{
	WDTCTL = WDTPW|WDTHOLD;

	a_pointer = a;
	a_pointer += 3;
	*a_pointer = 0;

	while (1);
}
