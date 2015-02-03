/*
 * read the problem in the book, the description is long
 */

#include <msp430.h>

void main(void)
{
	float out = 10.3;
	float ref = 8.2;
	float err = 0;
	int  cont = 0;

	err = out - ref;

	if (err > 0)
		cont = -1;
	if (err < 0)
		cont = 1;
}
