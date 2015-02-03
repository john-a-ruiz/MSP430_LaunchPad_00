/*
 * using an intrinsic function change the status register
 */

#include <msp430.h>

void main(void)
{
	unsigned short test = 1;
	_enable_interrupts();
	_disable_interrupts();

	while (test);
}
