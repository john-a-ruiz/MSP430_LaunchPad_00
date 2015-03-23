/*
 * Initially the green LED is on and the red LED is off. The CPU wakes up in periodic
 * time intervals of 10s, 1 min, 1 hour, 1 day and as the CPU awakens the LEDs toggle.
 * When not awake the CPU will go into a low-power mode.
 */

#include <msp430g2553.h>

#define RED BIT0
#define GREEN BIT6

void GPIO_init(void);
void BCM_init(void);
void TIMERA0_init(void);

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	GPIO_init();
	BCM_init();
	TIMERA0_init();

	_enable_interrupts();

	while (1)
		LPM3;
}

/*
 * Unused I/O pins: I/O function, output direction, unconnected on pc.
 */
void GPIO_init(void)
{
	// Port 1
	P1OUT = 0x40;
	P1SEL = 0x00;
	P1DIR = 0xFF;
	P1REN = 0x00;

	P1IES = 0x00;
	P1IFG = 0x00;
	P1IE = 0x00;

	// Port 2
	P2OUT = 0x00;
	P2SEL = 0x00;
	P2DIR = 0xFF;
	P2REN = 0x00;

	P2IES = 0x00;
	P2IFG = 0x00;
	P2IE = 0x00;
}

void BCM_init(void)
{
	// DCO set to 1 MHz

    BCSCTL1 |= XT2OFF | DIVA_0;
    // XT2OFF -- Disable XT2CLK
    // ~XTS -- Low Frequency
    // DIVA_0 -- Divide ACLK by 1

	BCSCTL3 |= LFXT1S_2;
	// XT2S_0	0 : freq range select for XT2 - 0.4 - 1MHz
	// LFXT1S_2	1 : low freq clock select - VLOCLK (~12 kHz)
	// XCAP_x	0 : oscillator cap select - ~1pf
}

void TIMERA0_init(void)
{
	TACCTL0 = CCIE + COM;
	// CM_0		0 : capture mode - disabled
	// CCIS_0	0 : select TACCRx input signal - none
	// SCS		0 : sync input signal capture with timer - not synced
	// SCCI		0 : CCI input latched with EQUx and can be read here
	// COM		1 : capture/compare mode - compare
	// OUTMOD_0	0 : output mode - OUT bit value
	// CCIE		1 : capture/compare interrupt enable - enabled
	// CCI		0 : cap/comp input can be read here
	// OUT		0 : output - for mode 0 this bit controls state of output (0 or 1)
	// COV		0 : cap overflow - no cap overflow
	// CCIFG	0 : cap/comp interrupt flag - no interrupt

	TACCR0 = 14999;			// 10s
//  TACCR0 = 29999;			// 20s
	TACTL = TASSEL_1 + ID_3 + MC_1 + TACLR;
	// TASSEL_1	1 : clock source select - ACLK
	// ID_3		1 : input divider - /8
	// MC_1		1 : mode control - timer counts up to TACCR0 [(TACRRO+1)/clk = 1s]
	// TACLR	1 : TimerA clear - resets TAR, clock divider, count direction
	// TAIE		0 : interrupt enable - disabled
	// TAIFG	0 : interrupt flag - no interrupt
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt void TIMER_ISR(void)
{
	P1OUT ^= RED;
	P1OUT ^= GREEN;
}
