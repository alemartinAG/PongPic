#include "p16f887.inc"

; CONFIG1
; __config 0xEFF2
 __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF


CBLOCK	0x20
	NCOL
	NFIL
	AUX
	CounterA
	CounterB
	CounterC
ENDC

ORG 0x00
GOTO INICIO
	
ORG 0x04
GOTO ISR

ORG 0x05
INICIO		
		BSF	STATUS, RP0
		BSF	STATUS, RP1
		CLRF	ANSELH
		CLRF	ANSEL
		BCF	STATUS, RP1
		CLRF	TRISB
		CLRF	TRISD
		MOVLW	b'10000011'			;Prescaler en 011 = 1/16
		MOVWF	OPTION_REG
		BSF	INTCON, T0IE
		BSF	INTCON, GIE
		BCF	STATUS, RP0
		CALL	INIT_TIMER
		MOVLW	0x00
		MOVWF	PORTD				;Columnas en PuertoD
		MOVLW	0xFF
		MOVWF	PORTB				;Filas en PuertoB
		CLRF	NCOL				;Limpio variables
		CLRF	NFIL
		
MAIN_LOOP	NOP 
		GOTO	MAIN_LOOP


TABLA_COL						;En 0 prende la columna
		ADDWF	PCL, F				;correspondiente
		RETLW	b'11111110'
		RETLW	b'11111101'
		RETLW	b'11111011'
		RETLW	b'11110111'
		RETLW	b'11101111'
		RETLW	b'11011111'
		RETLW	b'10111111'
		RETLW	b'01111111'
		
TABLA_FIL						;En 1 prende la fila
		ADDWF	PCL, F				;correspondiente
		RETLW	0x01
		RETLW	0x02
		RETLW	0x04
		RETLW	0x08
		RETLW	0x10
		RETLW	0x20
		RETLW	0x40
		RETLW	0x80		
			
		
INIT_TIMER						;Timer0 aprox en 1 uSeg
		MOVLW	d'255'
		MOVWF	TMR0
		RETURN
		
ISR
		BTFSC	INTCON, T0IF
		CALL	INTER_TMR
		RETFIE

INTER_TMR	
		BCF	INTCON, T0IF
		MOVLW	d'15'				;Genera un loop de 
		MOVWF	CounterC			;999.999 uSeg
    LOOP2	MOVLW	d'104'
		MOVWF	CounterB
    LOOP1	MOVLW	d'138'
		MOVWF	CounterA
    LOOP        DECFSZ	CounterA,F
	        GOTO	LOOP
		DECFSZ	CounterB,F
		GOTO	LOOP1
		DECFSZ	CounterC,F
		GOTO	LOOP2
		MOVF	NCOL, W
		CALL	TABLA_COL		
		MOVWF	PORTD			;Si cambio el puerto los leds prenden al reves
		MOVF	NFIL, W
		CALL	TABLA_FIL
		MOVWF	PORTB			;Si cambio el puerto los leds prenden al reves
		INCF	NCOL, F
		MOVLW	0x08
		SUBWF	NCOL, W
		BTFSC	STATUS, C
		CLRF	NCOL
		INCF	NFIL, F
		MOVLW	0x08
		SUBWF	NFIL, W
		BTFSC	STATUS, C
		CLRF	NFIL
TERMINA		CALL	INIT_TIMER
		RETURN
		

		
		NOP
		END