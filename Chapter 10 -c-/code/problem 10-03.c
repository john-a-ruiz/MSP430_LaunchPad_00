/*
 * Initially the green LED is on and the red LED is off. The CPU wakes up in periodic
 * time intervals of 10s, 1 min, 1 hour, 1 day and as the CPU awakens the LEDs toggle.
 * When not awake the CPU will go into a low-power mode. Use button S2 to reset the timer
 * and bring LEDs back to their initial states
 */

#include <msp430g2553.h>

#define RED_LED	BIT0
#define GREEN_LED BIT6

void GPIO_init(void);
void BCS_init(void);
void TIMER_A0_init(void);

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	GPIO_init();
	BCS_init();
	TIMER_A0_init();
	_enable_interrupts();
	LPM3;

	while (1)
		;
}

void GPIO_init(void)
{
	// Port 1
	P1OUT = 0x40;
	P1SEL = 0x00;
	P1DIR = 0xF7;
	P1REN = 0x00;

	P1IES = 0x00;
	P1IFG = 0x00;
	P1IE = 0x08;

	// Port 2
	P2OUT = 0x00;
	P2SEL = 0x00;
	P2DIR = 0xFF;
	P2REN = 0x00;

	P2IES = 0x00;
	P2IFG = 0x00;
	P2IE = 0x00;
}

void BCS_init(void)
{
	BCSCTL2 = SELM_0 + DIVM_0 + SELS_0 + DIVS_0;
	// SELM_0 	1 : DCOCLK
    // DIVM_0 	1 : Divide DCOCLK by 1
    // SELS_0 	1 : SMCLK
    // DIVS_0 	1 : Divide SMCLK by 1
    // DCOR_0 	0 : DCO uses internal resistor

	BCSCTL1 = XT2OFF + XTS_0 + DIVA_3;
    // XT2OFF 	1 : Disable XT2CLK (g2553 doesn't have XT2)
    // XTS_0 	1 : Low Frequency Mode (only choice)
    // DIVA_3 	1 : Divide ACLK by 8
	// RSELx	x : Range Select

	BCSCTL3 = XT2S_0 + LFXT1S_2;
	// XT2S_0	1 : freq range select for XT2 - 0.4 - 1MHz
	// LFXT1S_2	1 : low freq clock select - VLOCLK (~12 kHz)
	// XCAP_x	0 : oscillator cap select - ~1pf
}

void TIMER_A0_init(void)
{
	TA0CTL = TASSEL_1 + ID_3 + MC_1 + TACLR + TAID;
	// TASSEL_1	1 : clock source select - ACLK
	// ID_3		1 : input divider - /8
	// MC_1		1 : mode control - timer counts up to TACCR0
	// TACLR	1 : TimerA clear - resets TAR, clock divider, count direction
	// TAID		1 : interrupt enable - disabled
	// TAIFG	0 : interrupt flag - no interrupt

	TA0CCR0 = 187;

	TA0CCTL0 = CM_0 + SCA + COM + CCIE;
	// CM_0		1 : capture mode - disabled
	// CCIS_0	0 : select TACCRx input signal - none
	// SCA		1 : sync input signal capture with timer - asynchronus
	// SCCI		0 : CCI input latched with EQUx and can be read here
	// COM		1 : capture/compare mode - compare
	// OUTMOD_0	0 : output mode - OUT bit value
	// CCIE		1 : capture/compare interrupt enable - enabled
	// CCI		0 : cap/comp input can be read here
	// OUT		0 : output - for mode 0 this bit controls state of output (0 or 1)
	// COV		0 : cap overflow - no cap overflow
	// CCIFG	0 : cap/comp interrupt flag - no interrupt
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt void TIMER_A0_ISR(void)
{
	P1OUT ^= RED_LED + GREEN_LED;
}

#pragma vector = PORT1_VECTOR
__interrupt void PORT1_ISR(void)
{
	P1OUT = 0x40;
	TAR = 0;

	P1IFG &= ~BIT3;
}
