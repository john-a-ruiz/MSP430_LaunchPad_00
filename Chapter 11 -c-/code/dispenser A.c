/*
 * using ADC and PWM to design a non-touch paper towel dispenser
 */

#include <msp430g2553.h>

#define LedOn (P1OUT |= 0x08)
#define LedOff (P1OUT &= ~0x08)

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

		while ((ADC10CTL1 & ADC10BUSY) == ADC10BUSY)
			;

		if (Control == 0)
		{
			if (ADC10MEM < 0x0300)
			{
				LedOn;
				TACTL = MC_1 + ID_3 + TASSEL_1 + TACLR;	 	// look at TACLR
				Control = 1;
			}
		}
	}
}

void PinConfig(void)
{
	P1DIR = 0xFE;
	P1OUT = 0x00;
}

void TimerConfig(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	BCSCTL3 |= LFXT1S_2;

	TACCTL0 = CCIE;
	TACTL = MC_0;
	TACCR0 = 1499;
}

void ADCConfig(void)
{
	ADC10CTL0 = SREF_0 + ADC10SHT_3 + ADC10ON;
	ADC10CTL1 = INCH_0 + SHS_0 + ADC10DIV_0 + ADC10SSEL_0 + CONSEQ_0;
	ADC10AE0 = BIT0;
	ADC10CTL0 |= ENC;
}



#pragma vector = TIMER0_A0_VECTOR
__interrupt void isr_name(void)
{
	Count++;
	if (Count == 4)
	{
		LedOff;
		TACTL = MC_0;
		Control = 0;
		Count = 0;
	}
}
