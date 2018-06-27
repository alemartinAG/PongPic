; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR
    
#include <p16f887.inc>

; CONFIG1
; __config 0xEFF2
 __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

    cblock 0x20
    rec
    dato
    salvaw
    salvastatus
    valorobt
    aux
    endc
    
    	ORG 0x00
        goto inicio
	
	ORG 0x04
	goto subint
	
	ORG 0x05
inicio: call config1
loop:	nop
	movlw 0x61
	subwf valorobt,w
	btfsc STATUS,Z
	bsf PORTD,0					;2 LEDS EN ESTE PUERTO
	btfsc STATUS,Z
	bcf PORTD,1
	movlw 0x62
	subwf valorobt,w
	btfsc STATUS,Z
	bsf PORTD,1
	btfsc STATUS,Z
	bcf PORTD,0
	;btfsc PIR1,RCIF
	;call print
fin:	goto loop
	
print:	movf RCREG,w
	movwf PORTB
	return
	
config1: 
	banksel ANSEL
	clrf ANSEL
	clrf ANSELH
	bcf BAUDCTL,BRG16
	banksel TRISB
	bcf TRISD,0
	bcf TRISD,1
	bcf TRISC,6
	bsf TRISC,7
	clrf TRISB  --------
	clrf SPBRGH
	movlw d'25'
	movwf SPBRG
	bsf TXSTA,BRGH
	bcf TXSTA,4 ;bit SYNC
	clrf PIE1
	clrf PIE2
	bsf PIE1,RCIE
	banksel PORTB
	bsf RCSTA,SPEN
	bcf RCSTA,RX9
	bcf RCSTA,ADDEN
	clrf INTCON
	bsf INTCON, PEIE
	bsf INTCON, GIE
	bsf RCSTA,CREN
	clrf PORTD
	clrf aux
	return
	
errores: 
	btfss RCSTA,FERR
	goto next
	bcf RCSTA,SPEN
	nop
	nop
	bsf RCSTA,SPEN
next:	btfss RCSTA,OERR
	goto fin1
	bcf RCSTA,CREN
	nop
	nop
	bsf RCSTA,CREN
fin1:	return
	
subint:	
	movwf salvaw
	swapf STATUS,W
	movwf salvastatus ;salvo contexto
	
	;incf rec,f
	;incf aux,f
	;movf aux,w
	;movwf PORTD
	call errores
	movf RCREG,W
	movwf PORTB
		;movwf PORTD
	movwf valorobt
	
	swapf salvastatus, w;devuelvo contexto
	movwf STATUS
	swapf salvaw,f
	swapf salvaw,w
	retfie
	
	END