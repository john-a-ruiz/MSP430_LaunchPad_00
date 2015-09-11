/*
 * using ADC and PWM to design a non-touch paper towel dispenser
 */

#include <msp430g2553.h>

#define MotorStart (P1SEL |= 0x04)
#define MotorStop (P1SEL &= ~0x04)

int Count = 0;
int Control = 0;

void PinConfig(void);
void TimerConfig(void);
void ADCConfig(void);

void main(void)
{
	PinConfig();
	TimerConfig();
	ADCConfig();
	_enable_interrupts();

	while (1)
	{
		ADC10CTL0 |= ADC10SC;
		// start sample and conversion

		while ((ADC10CTL1 & ADC10BUSY) == ADC10BUSY)
			;  // wait while ADC converts

		if (Control == 0)
		{
			if (ADC10MEM < 0x0280)
			{
				MotorStart;
				TACTL = MC_1 + ID_2 + TASSEL_2 + TACLR;
				// up mode, SMCLK/4, reset TAR

				P1OUT |= BIT3;
				Control = 1;
			}
		}
	}
}

void PinConfig(void)
{
	/*
	 * P1.0 : LDR input
	 * P1.2 : L293 Enable output
	 * P1.3 : LED output
	 * P1.4 : Motor Driver Output
	 * P1.5 : Motor Driver Output
	 */
	P1DIR = 0xFE;
	P1OUT = 0x10;
}

void TimerConfig(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	TACCTL0 = CCIE;
	// compare mode, interrupt enabled, OUT bit value

	TACCTL1 = OUTMOD_7;
	// compare mode, reset @ TACCR1 - set @ TACCR0

	TACTL = MC_0;
	// Timer Halted

	TACCR0 = 49;
	TACCR1 = 40;
}

void ADCConfig(void)
{
	ADC10CTL0 = SREF_0 + ADC10SHT_3 + ADC10ON;
	// Vcc & Vss reference, 64 cycle sample, ADC on

	ADC10CTL1 = INCH_0 + SHS_0 + ADC10DIV_0 + ADC10SSEL_0 + CONSEQ_0;
	// input channel A0, ADC10SC sample & hold source, clk/1,
	// clk = ADC osc, single channel single conversion

	ADC10AE0 = BIT0;
	// analog input enable A0

	ADC10CTL0 |= ENC;
	// ADC10 enable conversion
}



#pragma vector = TIMER0_A0_VECTOR
__interrupt void isr_name(void)
{
	Count++;

	if (Count == 15000)			// motor spins in opposite direction
	{
		P1OUT &= ~BIT4;
		__delay_cycles(10000);
		P1OUT |= BIT5;
	}
	if (Count == 20000)
	{
		MotorStop;
		TACTL = MC_0;			// timer halted
		Control = 0;
		Count = 0;
		P1OUT &= ~BIT3;

		// reset motor to initial directions
		P1OUT &= ~BIT5;
		P1OUT |= BIT4;
	}
}
