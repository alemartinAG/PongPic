#include "p16f887.inc"

; CONFIG1
; __config 0xEFF2
 __CONFIG _CONFIG1, _FOSC_HS & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

CBLOCK	0x20
		SALVAW
		SALVASTATUS
		VALOROBT
		AUX
ENDC

ORG 0x00
    GOTO 	INICIO
ORG 0x04
    GOTO 	SUBINT
ORG 0x05

;-----------------------------------

INICIO:	
    CALL 	CONFIG1
LOOP:
    NOP		
    GOTO	LOOP
	
;-----------------------------------		

CONFIG1:
    BSF		STATUS, RP0			;Banco 11-----------------------
    BSF		STATUS, RP1
    CLRF	ANSELH
    CLRF	ANSEL
    BCF		BAUDCTL, BRG16			;Baud Rate Control Register, elijo el generador de 8 bits
		
    BCF		STATUS, RP1			;Banco 01-----------------------
    CLRF	TRISB				;Puerto para las filas lo configuro como salida
    CLRF	TRISD				;Puerto para las columnas lo configuro como salida
    BCF		TRISC, 6			;Configuro el TX como salida
    BSF		TRISC, 7			;Configuro el RX como entrada
    CLRF	SPBRGH				;Limpio el registro alto
    MOVLW	d'25'				;Carga para el generador de Baudios
    MOVWF	SPBRG				
    BSF		TXSTA, BRGH			;Selecciona alta velocidad
    BCF		TXSTA, 4			;Modo asíncrono seleccionado (SYNC)
    CLRF	PIE1
    CLRF	PIE2
    BSF		PIE1, RCIE			;Habilita la interrupcion por recepción
;    BSF	PIE1, TXIE			;Habilita la interrupcion por transmision
    BCF		TXSTA, TX9			;Transmision de 8 bits
    CLRF	INTCON
    BSF		INTCON, GIE			;Interrupciones globales habilitadas
    BSF		INTCON, PEIE			;Interrupciones perifericos habilitadas
		
    BCF		STATUS, RP0			;Banco 00-----------------------
    BSF		RCSTA, SPEN			;Habilito el puerto serie
    BCF		RCSTA, RX9			;Recepcion de 8 bits
    BCF		RCSTA, ADDEN			;Deshabilita la deteccion de direccion
    BSF		RCSTA, CREN			;Habilita el receptor
;    MOVLW	b'00000000'
;    MOVWF	PORTD				;Columnas habilitadas (ninguna)
    MOVLW	b'00000001'			
    MOVWF	PORTB				;Filas habilitadas (solo la primera)
    CLRF	AUX
	
    RETURN
		
;-----------------------------------

ERRORES:
    BTFSS	RCSTA, FERR
    GOTO 	NEXT
    BCF 	RCSTA, SPEN
    NOP
    NOP
    BSF		RCSTA, SPEN
NEXT:	
    BTFSS	RCSTA, OERR
    GOTO	FINL
    BCF		RCSTA,CREN
    NOP
    NOP
    BSF		RCSTA, CREN
FINL:
    RETURN
		
;-----------------------------------

SUBINT:	
    CALL	SALVAR
		
    CALL 	ERRORES
    MOVF	RCREG, W
    MOVWF 	PORTD				;Lo que llega va a 8 LEDs en binario para ver que funciona
    MOVWF	VALOROBT
    CALL	TRANSMITIR
		
    CALL	DEVOLVER
    RETFIE
		
;-------------------------------------------------------
		
SALVAR:
    MOVWF	SALVAW				;Salvo contexto
    SWAPF	STATUS, W
    MOVWF	SALVASTATUS		
    RETURN
		
;-------------------------------------------------------
		
DEVOLVER:
    SWAPF	SALVASTATUS, W			;Devuelvo contexto
    MOVWF	STATUS
    SWAPF	SALVAW, F
    SWAPF	SALVAW, W
    RETURN
		
;-------------------------------------------------------
    
TRANSMITIR:
    BANKSEL	TXSTA				;Banco 01-----------------------
    BSF		TXSTA, TXEN			;Habilito el transmisor
    
    BANKSEL	PORTA				;Banco 00-----------------------
    DECF	VALOROBT, F			;Al valor recibido lo decremento 
    MOVF	VALOROBT, W			;en uno y lo transmito de nuevo
    MOVWF	TXREG
    
    BSF		STATUS, RP0			;Banco 01-----------------------
WAIT1:		
    BTFSS	TXSTA, TRMT			;Espero a que termine la 
    GOTO	WAIT1				;transmision
    BCF		TXSTA, TXEN			;Deshabilito el transmisor
    BCF		STATUS, RP0			;Banco 00-----------------------
    RETURN
    
;-------------------------------------------------------
NOP
END