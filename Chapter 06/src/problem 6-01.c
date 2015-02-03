/*
 * a function that calulates the third power of integers 1-10 and
 * results be saved in an array (take into account overflow)
 *
 *          int 16bit -32768 32767
 * unsigned int 16bit      0 65535
 * so 31^3 is the highest without overvlowing int
 */

#include <msp430.h>

#define NUMBER 10

int third_power(int number);

void main(void)
{
	int input[NUMBER] = {0};
	int *p_number = &input[0];
	int i = 0;

	for (i = 1; i < 11; i++, p_number++)
		*p_number = third_power(i);
}

int third_power(int number)
{
	return (number * number * number);
}
