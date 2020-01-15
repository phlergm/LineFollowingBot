 title "asmScratchLineFollowerBot.asm"
;
; Program to run a line following bot using 2 wheels & 2 QTI light sensors
; goto used in the place of call to prevent it looping back to SFR configurations, and subsequently causing carpal tunnel throughout MPLAB SIM debuggin
;
; Hardware Notes: 
;	Chip used: P16F684, LM293N Comparator Chip(CC), L293D Motor Driver(MD) 
;	2 wheels used (Gear ratio 143:1)
;	2 parallel LEDs indicate when sensors detect black on the respective side
;	
;	
;	 
;	
;
;	||RA4(P3)	||RA5(P2)	||
;
;	||OutA(CC)	||OutB(CC)	||
;
;
;
;	||RC0(P10)	||RC1(P9)	||RC2(P8)	||RC3(P7)	||
;
;	||3A(MD)	||4A(MD)	||1A(MD)	||2A(MD)	|| 	
;
;	Forward	= 10
;	Reverse = 01
;	Off		= 00
;
; Humza Anwar
; 5/18/2019
;--------------------------------------------------------------------------------
; Setup
	LIST R=DEC								
	INCLUDE "p16f684.inc"					 
	INCLUDE "asmDelay.inc"										
  __CONFIG _FCMEN_OFF & _IESO_OFF & _BOD_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTOSCIO ;put this all in ONE line

; variables
 CBLOCK 0x20
	delayVal
	
 ENDC
;--------------------------------------------------------------------------------
 PAGE
;Configuring SFRs

	org		0	

	movlw	7
	movwf	CMCON0

	bsf		STATUS,RP0
	clrf	ANSEL^0x080					

	clrf	TRISC^0X080					;all of PORTC OUTPUTS

	movlw	b'111000'					;RA3,4,5 inputs
	movwf	TRISA^0x080
	bcf		STATUS, RP0
;--------------------------------------------------------------------------------
 PAGE 
; Mainline Code
	
	

loop:

	movlw 5
	movwf delayVal	;represents 100ms, upto 25.5 seconds when fully set

	goto delay
	
	btfss PORTA, 5
		goto left
		
	btfss	PORTA, 4
		goto right
		
	goto forward

		

	clrf PORTA
	goto loop
;--------------------------------------------------------------------------------
;Subroutines

left:			;Left motor forward (PORTC __10), right motor reverse (PORTC 01__) [0110]
	btfss PORTA, 4
		goto stop			;verifies that only left is on black, stops otherwise

	movlw b'0110'
	movwf PORTC 
	

	goto loop

right:			;Right motor forward (PORTC 10__), left motor reverse (PORTC __01) [1001]
	btfss	PORTA, 5
		goto stop			;verifies that only left is on black, stops otherwise

	movlw	b'1001'
	movwf	PORTC

	
	goto loop

stop:			;Both motors stop when all on black line 
	clrf PORTC	
	goto loop

forward:				;Both motors forward when no black detected
	btfss PORTA, 4
		goto loop
						;Movement rechecked and halts forward if any black is detected
	btfss PORTA, 5
		goto loop

	movlw b'1010'
	movwf PORTC

	
	goto loop

delay: 


	Dlay 100000
	nop

	decfsz delayVal, f
	goto delay
	goto loop
	
end

