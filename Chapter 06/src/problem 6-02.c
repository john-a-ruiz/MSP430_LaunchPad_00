/*
 * calculate the first 10 numbers in fibonacci series and save them in an array
 */

#include <msp430.h>

#define NUMBER 10

void main(void)
{
	int fibonacci[NUMBER] = {0};
	int *p_number = &fibonacci[2];
	int i = 0;

	//cheat
	fibonacci[1] = 1;

	for (i = 0; i < 8; i++, p_number++)
		*p_number = *(p_number-1) + *(p_number-2);
}
