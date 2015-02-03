/*
 * Turning on the red LED when the push button is pressed, rev 1.4
 */

#include <msp430.h>

#define LED BIT0
#define BUTTON BIT3

void main(void)
{
    WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer
	
    P1DIR = LED;
    P1OUT = 0x00;

    while (1)
    {
    	if ((P1IN & BUTTON) == 0x00)	// active low input
    		P1OUT = 0x01;
    	else
    		P1OUT = 0x00;
    }
}
