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
	BOTON
	BOTON_2
	CounterA
	CounterB
	CounterC
	FILAS
	COD_START
ENDC
CBLOCK	0x30
	C1
	C2
	C3
	C4
	C5
	C6
	C7
	C8
	PLYR_1
	PLYR_2
	VALOROBT
	SALVA_W
	SALVA_STAT
	FLAG_START
	PELOTA
	PELOTAX
	DIRECC
	VELOCIDAD
ENDC
	
DATA_PIN2   EQU	   5
LATCH_PIN2  EQU	   4
PULSE_PIN2  EQU	   3
DATA_PIN    EQU    2 
LATCH_PIN   EQU    1
PULSE_PIN   EQU    0

ORG 0x00
GOTO INICIO
	
ORG 0x04
GOTO SUBINT
;///////////////////-    INICIO DEL PROGRAMA   -//////////////////////////   
   
ORG 0x05
INICIO	
	    MOVLW   0x48
	    MOVWF   PELOTA
	    CALL    CONFIGURAR
LOOP_START  BTFSS   FLAG_START, 0
	    GOTO    LOOP_START
MAIN_LOOP   CALL    REFRESH
	    CALL    DELAY
	    MOVF    NCOL, F
	    BTFSS   STATUS, Z
	    GOTO    MAIN_LOOP
	    CALL    GET_BOTON
	    CALL    GET_BOTON2
	    CALL    CHECK_BOTON1
	    CALL    CHECK_BOTON2
	    INCF    VELOCIDAD, F
	    BTFSC   VELOCIDAD, 5
	    CALL    MOV_PELOTAX
	    GOTO    MAIN_LOOP
	    
;///////////////////-    LO MUESTRO EN LA MATRIZ   -//////////////////////////
	    
REFRESH	    
	    CLRF    C1
	    CLRF    C2
	    CLRF    C3
	    CLRF    C4
	    CLRF    C5
	    CLRF    C6
	    CLRF    C7
	    
	    SWAPF   PELOTA, W
	    ANDLW   0x0F
	    ADDLW   0x30
	    MOVWF   FSR
	    MOVF    PELOTA, W
	    ANDLW   0x0F
	    MOVWF   INDF
	    
	    MOVF    PLYR_1, W
	    MOVWF   C8
	    MOVF    PLYR_2, W
	    MOVWF   C1
	    MOVF    NCOL, W
	    ADDLW   0x30
	    MOVWF   FSR
	    MOVF    INDF, W
	    MOVWF   FILAS
	    ;COMF    FILAS, W
	    MOVWF   PORTB
	    MOVF    NCOL, W
	    CALL    TABLA_COL
	    MOVWF   PORTD
	    INCF    NCOL, F
	    MOVF    NCOL, W
	    SUBLW   0x07
	    BTFSS   STATUS, C
	    CLRF    NCOL
	    RETURN
	    
TABLA_COL
	    ADDWF   PCL, F
	    RETLW   0x7F
	    RETLW   0xBF
	    RETLW   0xDF
	    RETLW   0xEF
	    RETLW   0xF7
	    RETLW   0xFB
	    RETLW   0xFD
	    RETLW   0xFE
	    
	    
MOV_PELOTAX
	    CLRF    VELOCIDAD
	    SWAPF   PELOTA, W
	    ANDLW   0x0F
	    MOVWF   PELOTAX
	    MOVF    PELOTAX, W
	    XORLW   0x01
	    BTFSC   STATUS, Z
	    BSF	    DIRECC, 0
	    MOVF    PELOTAX, W
	    XORLW   0x06
	    BTFSC   STATUS, Z
	    BCF	    DIRECC, 0
	    BTFSC   DIRECC, 0
	    INCF    PELOTAX, F
	    BTFSS   DIRECC, 0
	    DECF    PELOTAX, F
	    MOVLW   0x0F
	    ANDWF   PELOTA, F
	    SWAPF   PELOTAX, W
	    IORWF   PELOTA, F
	    RETURN
	    
	        
;///////////////////-    CONTROL 1   -//////////////////////////	
	
GET_BOTON
	    CLRF   AUX
	    BSF	   PORTA, LATCH_PIN
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    BCF	    PORTA, LATCH_PIN
LOOP_CHECK  BTFSS   PORTA, DATA_PIN
	    INCF    BOTON, F	;si data = 0 se presiono un boton
	    BCF	    PORTA, PULSE_PIN
	    BCF	    STATUS, C
	    RLF	    BOTON, F	;lo muevo hacia la izq para distingui botones
	    NOP			;el boton A se pierde
	    NOP
	    NOP
	    NOP
	    BSF	    PORTA, PULSE_PIN
	    INCF    AUX, F
	    MOVLW   0x08	;chequeo que si lo hice 8 veces
	    SUBWF   AUX, W
	    BTFSS   STATUS, C
	    GOTO    LOOP_CHECK
	    CLRF    AUX
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    BCF	    PORTA, PULSE_PIN
	    RETURN
	    
CHECK_BOTON1
	    MOVF	BOTON, F
	    BTFSC	STATUS, Z
	    RETURN
	    BTFSC	BOTON, 3    ;chequeo el boton de arriba
	    GOTO	UP_PRESSED  
	    BTFSC	BOTON, 2    ;chequeo el boton de abajo
	    GOTO	DW_PRESSED
	    ;CLRF	PORTB
FIN_CB1	    CLRF	BOTON
	    RETURN
UP_PRESSED  BTFSC	PLYR_1, 7
	    GOTO	FIN_CB1
	    BCF		STATUS, C
	    RLF		PLYR_1, F
	    GOTO	FIN_CB1
DW_PRESSED  BTFSC	PLYR_1, 0
	    GOTO	FIN_CB1
	    BCF		STATUS, C
	    RRF		PLYR_1, F
	    GOTO	FIN_CB1
	  
;///////////////////-    CONTROL 2   -//////////////////////////
	    
GET_BOTON2
	    CLRF    AUX
	    BSF	   PORTA, LATCH_PIN2
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    BCF	    PORTA, LATCH_PIN2
LOOP_CHECK2 BTFSS   PORTA, DATA_PIN2
	    INCF    BOTON_2, F	;si data = 0 se presiono un boton
	    BCF	    PORTA, PULSE_PIN2
	    BCF	    STATUS, C
	    RLF	    BOTON_2, F	;lo muevo hacia la izq para distingui botones
	    NOP			;el boton A se pierde
	    NOP
	    NOP
	    NOP
	    BSF	    PORTA, PULSE_PIN2
	    INCF    AUX, F
	    MOVLW   0x08	;chequeo que si lo hice 8 veces
	    SUBWF   AUX, W
	    BTFSS   STATUS, C
	    GOTO    LOOP_CHECK2
	    CLRF    AUX
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    BCF	    PORTA, PULSE_PIN2
	    RETURN

CHECK_BOTON2
	    MOVF	BOTON_2, F
	    BTFSC	STATUS, Z
	    RETURN
	    BTFSC	BOTON_2, 4    ;chequeo el boton de arriba
	    GOTO	UP_PRESSED2  
	    BTFSC	BOTON_2, 3    ;chequeo el boton de abajo
	    GOTO	DW_PRESSED2
	    ;CLRF	PORTB
FIN_CB2	    CLRF	BOTON_2
	    RETURN
UP_PRESSED2  BTFSC	PLYR_2, 7
	    GOTO	FIN_CB2
	    BCF		STATUS, C
	    RLF		PLYR_2, F
	    GOTO	FIN_CB2
DW_PRESSED2  BTFSC	PLYR_2, 0
	    GOTO	FIN_CB1
	    BCF		STATUS, C
	    RRF		PLYR_2, F
	    GOTO	FIN_CB2 
	  
;///////////////////-    REINCIO EL JUEGO   -//////////////////////////	   
	    
RESTART
	    MOVLW	0x18
	    MOVWF	PLYR_1
	    MOVLW	0x18
	    MOVWF	PLYR_2
	    MOVF	PLYR_1, W
	    MOVWF	C8
	    MOVF	PLYR_2, W
	    MOVWF	C1
	    RETURN

;///////////////////-    CONFIGURACION INICIAL   -//////////////////////////
	    
CONFIGURAR
	    MOVLW	0x42
	    MOVWF	COD_START
	    CLRF	FLAG_START
	    CLRF	C1
	    CLRF	C2
	    CLRF	C3
	    CLRF	C4
	    CLRF	C5
	    CLRF	C6
	    CLRF	C7
	    CLRF	C8
	    CALL	RESTART
	    BSF		STATUS, RP0
	    BSF		STATUS, RP1
	    CLRF	ANSELH
	    CLRF	ANSEL
	    BCF		BAUDCTL, BRG16	;Baud Rate Control Register, elijo el generador de 8 bits
	    BCF		STATUS, RP1
	    CLRF	TRISB
	    CLRF	TRISD
	    CLRF	TRISA
	    BSF		TRISA, DATA_PIN
	    BSF		TRISA, DATA_PIN2
	    CLRF	TRISD
	    BCF		TRISC, 6	;Configuro el TX como salida
	    BSF		TRISC, 7	;Configuro el RX como entrada
	    CLRF	SPBRGH		;Limpio el registro alto
	    MOVLW	d'25'				;Carga para el generador de Baudios
	    MOVWF	SPBRG				
	    BSF		TXSTA, BRGH			;Selecciona alta velocidad
	    BCF		TXSTA, 4			;Modo asíncrono seleccionado (SYNC)
	    CLRF	PIE1
	    CLRF	PIE2
	    BSF		PIE1, RCIE			;Habilita la interrupcion por recepción
	    CLRF	INTCON
	    BSF		INTCON, GIE			;Interrupciones globales habilitadas
	    BSF		INTCON, PEIE

	    BCF		STATUS, RP0			;Banco 00
	    BSF		RCSTA, SPEN			;Registro de recepcion, habilito el puerto serie
	    BCF		RCSTA, RX9			;Recepcion de 8 bits
	    BCF		RCSTA, ADDEN			;Deshabilita la deteccion de direccion
	    BSF		RCSTA, CREN			;Habilita el receptor
	    ;MOVLW	b'10000011'
	    ;MOVWF	OPTION_REG
	    ;BSF	INTCON, T0IE
	    ;BSF	INTCON, GIE
	    ;BCF		STATUS, RP0
	    ;CALL	INIT_TIMER
;	    MOVLW	0x00
;	    MOVWF	PORTD
	    MOVLW	0x08
	    ;MOVWF	PELOTAX
	    RETURN
	
;///////////////////-    DELAY   -//////////////////////////
	    
DELAY
	MOVLW	D'1'		
	MOVWF	CounterC
LOOP2	MOVLW	D'5'
	MOVWF	CounterB
LOOP1	MOVLW	D'189'
	MOVWF	CounterA
LOOP    DECFSZ	CounterA,1
	GOTO	LOOP
	DECFSZ	CounterB,1
	GOTO	LOOP1
	DECFSZ	CounterC,1
	GOTO	LOOP2
	;MOVLW	0xFF
	;MOVWF	PORTB
	RETURN
	
;///////////////////-    ERRORES   -//////////////////////////	    
	
ERRORES
		BTFSS	RCSTA, FERR
		GOTO 	NEXT
		BCF 	RCSTA, SPEN
		NOP
		NOP
		BSF	RCSTA, SPEN
NEXT		BTFSS	RCSTA, OERR
		GOTO	FINL
		BCF	RCSTA,CREN
		NOP
		NOP
		BSF	RCSTA, CREN
FINL		RETURN
		
;///////////////////-    INTERRUPCIONES   -//////////////////////////

SUBINT
		MOVWF	SALVA_W
		SWAPF	STATUS, W
		MOVWF	SALVA_STAT		;Salvo contexto
		
		CALL 	ERRORES
		CALL	CHECK_START
		
		SWAPF	SALVA_STAT, W		;Devuelvo contexto
		MOVWF	STATUS
		SWAPF	SALVA_W, F
		SWAPF	SALVA_W, W
		
		RETFIE
		
CHECK_START
		MOVF	RCREG, W
		MOVWF	VALOROBT
		XORWF	COD_START, W
		BTFSC	STATUS, Z
		INCF	FLAG_START, F
		RETURN
		
		
		
;///////////////////-    FIN DE PROGRAMA   -//////////////////////////
		NOP
		END