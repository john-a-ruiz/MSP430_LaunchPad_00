/*
 * the output of PWM is is fed to the green LED and the duty cycle observed by the
 * brightness of the LED
 */

#include <msp430g2553.h>

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	int period = 0x0FFF;			// period of the PWM
	float D = .8;					// duty cycle, max value 1

	P1DIR |= BIT6;
	P1SEL |= BIT6;					// PWM output

	TACCR0 = period - 1;			// PWM period
	TACCR1 = period * D;			// CCR1 PWM duty cycle

	TACCTL1 = OUTMOD_7;				// CCR1 reset/set
	TACTL = TASSEL_2 + MC_1;		//SMCLK, up mode

	LPM1;
}

