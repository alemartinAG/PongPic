	ULEFT	EQU	0x00
	DLEFT	EQU	0x01
	URIGHT	EQU	0x02
	DRIGHT	EQU	0x03
	
	CBLOCK	0x20
		NFILA0
		NFILA1
		NFILA2
		NFILA3
		NFILA4
		NFILA5
		NFILA6
		NFILA7
		DIREC
		PELOTA
	ENDC

MOVIMIENTO
		MOVF	PELOTA, W
		ANDLW	0xF0
		ADDWF	NFILA0, W
		MOVWF	FSR				;Pongo el puntero en la fila de LED
		MOVLW	0x81
		ANDWF	INDF, F			;Borro la pelota del display
		MOVF	DIREC, W
		CALL	TABLA_DIREC
		ADDWF	PCL, F			;Salto dependiendo a dondE debe moverse la pelota
		MOVLW	0x11			;0d
		SUBWF	PELOTA, F		
		GOTO	SALTO			
		MOVLW	0x10			;3d
		ADDWF	PELOTA, F		
		MOVLW	0x01			
		SUBWF	PELOTA, F		
		GOTO	SALTO			
		MOVLW	0x10			;8d
		SUBWF	PELOTA, F		
		MOVLW	0x01			
		ADDWF	PELOTA, F		
		GOTO	SALTO			
		MOVLW	0x11			;13d
		ADDWF	PELOTA, F
SALTO	MOVF	PELOTA, W		;Pongo el puntero en la fila de LED
		ANDLW	0xF0
		ADDWF	NFILA0, W
		MOVWF	FSR
		MOVF	PELOTA, W		;Busco la columna donde esta la pelota
		ANDLW	0x0F
		CALL	TABLA_COLUMNA
		ADDWF	INDF, F			;Le sumo la posicion de la pelota a la fila de LED
		
		
TABLA_DIREC
		ADDWF 	PCL, F
		RETLW	0x00
		RETLW	0x03
		RETLW	0x08
		RETLW	0x0D
		
TABLA_COLUMNA
		ADDWF	PCL, F
		RETLW	0x80	;NO DEBERIA LLEGAR
		RETLW	0x40
		RETLW	0x20
		RETLW	0x10
		RETLW	0x08
		RETLW	0x04
		RETLW	0x02
		RETLW	0x01
		RETLW	0x00	;NO DEBERIA LLEGAR

	