/*
 * The dynamic array using a pointer
 */

#include <msp430.h>

int a = 0;
int *a_pointer;

void main(void)
{
	WDTCTL = WDTPW|WDTHOLD;

	int count;

	a_pointer = &a;

	for (count = 1; count < 10; count++)
	{
		a_pointer++;
		*a_pointer = count;
	}

	while (1);
}
