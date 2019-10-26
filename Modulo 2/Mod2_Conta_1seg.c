#include <msp430.h> 

// AULA 01/10/2019
// conta de 0 a 0xFFFF (65535) em 1 segundo

// MSP430 F5529

void config() {

    P1DIR |= BIT0;               // P1.0 -> saida
    P1OUT &= ~BIT0;

    P4DIR |=  BIT7;              // P6.6 -> saida
    P4OUT &= ~BIT7;

    // SSEL = SMCLK
    // D = 16
    // InputDivider = 4
    // IDEXtended = 4
    // MC = continuous

    TA0CTL = (TASSEL__SMCLK | ID__4 | MC__CONTINUOUS | TACLR);

    TA0EX0 = TAIDEX_3;
}

int main()
{
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    config();

    while(1){

        // enquanto 1s
        while( !(TA0CTL & TAIFG) );

        TA0CTL &= ~TAIFG;

        // Realiza uma acao a cada 1 segundo
        P4OUT ^= BIT7;
        P1OUT ^= BIT0;

    }


    return 0;
}

