/*
 *  MSP430 LCD interface
 *
 *             |      LCD       |
 * LCD Pin #   |    Function    |   MSP Pin #
 *--------------------------------------------
 * PIN 5       |      RW        |    GND
 * PIN 4       |      RS        |    P1.0
 * PIN 6       |      EN        |    P1.1
 * PIN 14      |      DB7       |    P1.7
 * PIN 13      |      DB6       |    P1.6
 * PIN 12      |      DB5       |    P1.5
 * PIN 11      |      DB4       |    P1.4
 */

#include <msp430.h>

#define     LCD_DIR               P1DIR
#define     LCD_OUT               P1OUT

#define     LCD_PIN_RS            BIT0          // P1.0
#define     LCD_PIN_EN            BIT1          // P1.1
#define     LCD_PIN_D7            BIT7          // P1.7
#define     LCD_PIN_D6            BIT6          // P1.6
#define     LCD_PIN_D5            BIT5          // P1.5
#define     LCD_PIN_D4            BIT4          // P1.4

#define     LCD_PIN_MASK  ((LCD_PIN_RS | LCD_PIN_EN | LCD_PIN_D7 | LCD_PIN_D6 | LCD_PIN_D5 | LCD_PIN_D4))

#define     FALSE                 0
#define     TRUE                  1

void PulseLCD(void);
void SendByte(char ByteToSend, int IsData);
void PrintStr(char *Text);

void main(void)
{
    WDTCTL = WDTPW + WDTHOLD;             // Stop watchdog timer

//  Initialize LCD
    LCD_DIR |= LCD_PIN_MASK;
    LCD_OUT &= ~(LCD_PIN_MASK);

    __delay_cycles(100000);				// LCD warm up time

    LCD_OUT &= ~LCD_PIN_RS;				// set 4-bit out
    LCD_OUT &= ~LCD_PIN_EN;
    LCD_OUT = 0x20;
    PulseLCD();

    SendByte(0x28, FALSE);				// set 4-bit input ??
    SendByte(0x0E, FALSE);				// displayl, cursor, blink
    SendByte(0x06, FALSE);				// cursor, auto increment

//    ClearLCDScreen();
    SendByte(0x01, FALSE);
    SendByte(0x02, FALSE);

    PrintStr("Praise Allah!!");

    while (1)
    {
        __delay_cycles(1000);
    }

}

/*
 * IsData = TRUE if charactar data, FALSE if command
 */
void SendByte(char ByteToSend, int IsData)
{
    LCD_OUT &= (~LCD_PIN_MASK);			// clear output

    LCD_OUT |= (ByteToSend & 0xF0);		// set high nibble
    if (IsData == TRUE)
    {
        LCD_OUT |= LCD_PIN_RS;
    }
    else
    {
        LCD_OUT &= ~LCD_PIN_RS;
    }
    PulseLCD();

//    LCD_OUT &= (~LCD_PIN_MASK);			// set low nibble
    LCD_OUT = (LCD_OUT & ~0xF0) | (ByteToSend << 4);
//    LCD_OUT |= ((ByteToSend & 0x0F) << 4);
    if (IsData == TRUE)
    {
        LCD_OUT |= LCD_PIN_RS;
    }
    else
    {
        LCD_OUT &= ~LCD_PIN_RS;
    }
    PulseLCD();
}

void PulseLCD(void)
{
    LCD_OUT &= ~LCD_PIN_EN;				// EN = 0
    __delay_cycles(200);

    LCD_OUT |= LCD_PIN_EN;				// EN = 1
    __delay_cycles(200);

    LCD_OUT &= (~LCD_PIN_EN);			// EN = 0
    __delay_cycles(200);
}

void PrintStr(char *Text)
{
    char *c;

    c = Text;

    while ((c != 0) && (*c != 0))
    {
        SendByte(*c, TRUE);
        c++;
    }
}
