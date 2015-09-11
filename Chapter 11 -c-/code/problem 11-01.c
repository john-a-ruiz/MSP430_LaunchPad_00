/*
 * calculate the 10 bit SAR conversion of he analog voltage levels Vin
 */

#include <msp430g2553.h>

#define bitsize 10

float Vref = 3.6;
//float Vin = 1.2;
//float Vin = 2.85;
float Vin = 3.243;
float thresh;
float quantized = 0;
int count;
int bitval;
int bits[bitsize];

void main(void)
{
	WDTCTL = WDTPW + WDTHOLD;

	Vref /= 2;
	thresh = Vref;

	for (count = 0; count < bitsize; count++)
	{
		Vref /= 2;

		if (Vin >= thresh)
		{
			bitval = 1;
			thresh += Vref;
		}
		else
		{
			bitval = 0;
			thresh -= Vref;
		}

		bits[count] = bitval;
		quantized += 2*Vref*bitval;
	}

	while (1)
		;
}
