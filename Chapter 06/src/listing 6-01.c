/*
 * The sample C program
 */

#include <msp430.h>

int a = 1;

int main(void) {
    WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer
	
    int b = 2;
    int c;

    c = a + b;

	while (1);
}
