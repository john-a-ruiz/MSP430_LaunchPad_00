/*
 * The C code block for adjusting clocks
 */

#include <msp430.h>

void main(void) {
    WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer
	
	BCSCTL3 |= LFXT1S_2; 	// ACLK from VLO
	BCSCTL1 |= DIVA_2; 		// Divide ACLK frequency by four

	BCSCTL3 |= LFXT1S_0 | XCAP_3;	// ACLK from crystal oscillator,
									// with 10pf internal capacitors
}
