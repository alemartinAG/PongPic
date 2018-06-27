#include "p16f887.inc"

; CONFIG1
; __config 0xEFF2
 __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF


CBLOCK	0x20
	AUX_TMR		    
	RND
	CANT
	
ENDC

ORG 0x00
GOTO INICIO
	
ORG 0x04
;///////////////////-    INICIO DEL PROGRAMA   -//////////////////////////   
   
ORG 0x05
INICIO		
	    CALL    CONFIGURAR
	    
MAIN_LOOP   CALL    RANDOM_NUMBER
	    GOTO    MAIN_LOOP
	    
	    
;///////////////////-    SUBRUTINA RANDOM NUMB   -////////////////////////// 
	    
RANDOM_NUMBER
	    CLRF    RND
	    MOVF    TMR0, W
	    MOVWF   AUX_TMR
RAN_LOOP    BCF	    STATUS, C
	    RRF	    AUX_TMR, F
	    BTFSC   STATUS, C
	    INCF    RND, F
	    INCF    CANT, F
	    MOVLW   b'0001000'
	    XORWF   CANT, W
	    BTFSS   STATUS, Z
	    GOTO    RAN_LOOP
	    CLRF    CANT
	    RETURN

;///////////////////-    CONFIGURACION INICIAL   -//////////////////////////
	    
CONFIGURAR
	    BSF		STATUS, RP0			;Banco 11
	    BSF		STATUS, RP1
	    CLRF	ANSELH
	    CLRF	ANSEL
	    
	    BCF		STATUS, RP1			;Banco 01
	    CLRF	INTCON
	    MOVLW	b'10000000'
	    MOVWF	OPTION_REG
	    
	    BCF		STATUS, RP0			;Banco 00
	    MOVLW	0x34
	    MOVWF	TMR0
	    RETURN
		
		
;///////////////////-    FIN DE PROGRAMA   -//////////////////////////
		NOP
		END