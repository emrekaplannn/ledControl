PROCESSOR 18F8722

#include <xc.inc>

; CONFIGURATION (DO NOT EDIT)
; CONFIG1H
CONFIG OSC = HSPLL      ; Oscillator Selection bits (HS oscillator, PLL enabled (Clock Frequency = 4 x FOSC1))
CONFIG FCMEN = OFF      ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
CONFIG IESO = OFF       ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)
; CONFIG2L
CONFIG PWRT = OFF       ; Power-up Timer Enable bit (PWRT disabled)
CONFIG BOREN = OFF      ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
; CONFIG2H
CONFIG WDT = OFF        ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
; CONFIG3H
CONFIG LPT1OSC = OFF    ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
CONFIG MCLRE = ON       ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)
; CONFIG4L
CONFIG LVP = OFF        ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
CONFIG XINST = OFF      ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))
CONFIG DEBUG = OFF      ; Disable In-Circuit Debugger


GLOBAL var1
GLOBAL var2
GLOBAL var3
GLOBAL varb
GLOBAL varbdevam
GLOBAL re1_clicked
GLOBAL varc
GLOBAL varcdevam
GLOBAL re0_clicked
GLOBAL result
GLOBAL counter

; Define space for the variables in RAM
PSECT udata_acs
var1:
    DS 1 ; Allocate 1 byte for var1
var2:
    DS 1 
var3:
    DS 1 
varb:
    DS 1
varbdevam:
    DS 1
re1_clicked:
    DS 1
varc:
    DS 1
varcdevam:
    DS 1
re0_clicked:
    DS 1
counter:
    DS 1 
temp_result:
    DS 1   
result: 
    DS 1


PSECT resetVec,class=CODE,reloc=2
resetVec:
    goto       main

PSECT CODE
main:
    clrf var1	; var1 = 0		
    clrf result ; result = 0
    clrf varb
    clrf varc
    clrf varcdevam
    clrf re0_clicked
    clrf re1_clicked
    clrf varbdevam ; if this is 1, then it means you need to continue filling output port B
    movlw 128
    movwf counter
    
    ; PORTB
    ; LATB
    ; LATC
    ; TRISB determines whether the port is input/output
    ; set output ports
    clrf TRISB
    clrf TRISC
    clrf TRISD
    setf TRISE ; PORTE is input
    
    movlw 00001111B
    movwf TRISA
    
    setf PORTB
    setf PORTC ; light up all pins in PORTC
    setf LATD
    
    call busy_wait
    
    clrf LATB
    clrf PORTC ; light up all pins in PORTC
    clrf LATD
    
    
main_loop:
    ; Round robin
    ;bsf LATE, 1
    
    
    call blink_LED_0
    ;bcf LATE, 1
    call update_display
    call update_display_c
    
    call blink_LED_1
    call update_display    
    call update_display_c
    goto main_loop

    
blink_LED_0:
    ; Blink LED RD0
    bcf LATD, 0    ; Turn on RD0
    call busy_wait_500ms
    return
    
blink_LED_1:
    bsf LATD, 0    ; Turn off RD0
    call busy_wait_500ms
    return ; Repeat indefinitely

busy_wait_500ms:
    ; Wait for approximately 500 ms with checking button clicking
    movlw 252
    movwf var2 ; var2 = 251


    outer_loop_start_500:
	movlw 17
	movwf var1 ; var1 = 128
	loop_start_500:
	    setf var3
	    bsf PORTE, 1
	    loop2_500:
		call check_buttons
		call check_buttons_c
		decf var3
		
		bnz loop2_500
	    bcf PORTE, 1
	    decf var1
	    bnz loop_start_500
	incfsz var2
	bra outer_loop_start_500
    return

    
busy_wait:
    ; for (var2 = 0; var 
    ; for (var1 = 255; var1 != 0; --var1)
    movlw 250
    movwf var2 ; var2 = 128


    outer_loop_start:
	movlw 218
	movwf var1 ; var1 = 128
	loop_start:
	    setf var3
	    loop2:
		decf var3
		bnz loop2
	    decf var1
	    bnz loop_start
	incfsz var2
	bra outer_loop_start
    return

    
    
    

check_buttons:
    btfss varb, 1
    goto check_buttons2 ;check if LATE pressed
    goto check_buttonss ;nothing done here. just timing adjusment purpose
    return
    
check_buttons_c:
    btfss varc, 1
    goto check_buttons2_c ;check if LATE pressed
    goto check_buttonss_c ;nothing done here. just timing adjusment purpose
    return
    
check_buttonss:
    btfsc varb, 1
    goto varb_changerr
    goto varb_notchangerr
    varb_changerr:
	setf varb
	return
    varb_notchangerr:
	setf varb
	return
    return
    
check_buttonss_c:
    btfsc varc, 1
    goto varc_changerr
    goto varc_notchangerr
    varc_changerr:
	setf varc
	return
    varc_notchangerr:
	setf varc
	return
    return
    
check_buttons2:
    btfsc PORTE, 1
    goto varb_changer
    goto varb_notchanger
    varb_changer:
	setf varb
	return
    varb_notchanger:
	clrf varb
	return
    return
    
check_buttons2_c:
    btfsc PORTE, 0
    goto varc_changer
    goto varc_notchanger
    varc_changer:
	setf varc
	return
    varc_notchanger:
	clrf varc
	return
    return
    
    
    
    
update_display:
    btfsc varb, 0
    goto update_display2
    goto sifirlayici
    update_display2:
	btfss PORTE, 1
	goto re1_clicker
	return
    sifirlayici:
	clrf varb
	goto update_display3
	return
    return
re1_clicker:
    setf re1_clicked
    goto update_display3
    return
update_display3:
    btfsc re1_clicked, 1
    goto varbdevam_changer
    goto varbdevam_notchanger
    varbdevam_changer:
	clrf re1_clicked
	btfsc varbdevam, 1
	goto varbdevam_clearer
	goto varbdevam_setter
	varbdevam_clearer:
	    clrf varbdevam
	    clrf varb
	    clrf LATB
	    return
	varbdevam_setter:
	    setf varbdevam
	    btfsc varbdevam, 1
	    goto update_display4
	    return
	return
    return
    
varbdevam_notchanger: 
    clrf re1_clicked
    btfsc varbdevam, 1
    goto update_display4
    goto LATB_clearer
    LATB_clearer:
	clrf LATB
	return
    return
    
update_display4:
    incfsz counter
    clrf varb
    btfsc LATB, 7 ; LATB'nin 7. biti 1 mi?
    goto latb_zero ; 1 ise buraya
    goto latb_devam ; 0 ise buraya
    latb_zero:
	clrf LATB
	return
    latb_devam:
	rlcf LATB ; 1 basamak kaydir sola
	return
    return
	
    
    counter_overflowed: ;not used
	;comf PORTB
	movlw 128
	movwf counter
	return
    
	
	
update_display_c:
    btfsc varc, 0
    goto update_display2_c
    goto sifirlayici_c
    update_display2_c:
	btfss PORTE, 0
	goto re0_clicker
	return
    sifirlayici_c:
	clrf varc
	goto update_display3_c
	return
    return
re0_clicker:
    setf re0_clicked
    goto update_display3_c
    return
update_display3_c:
    btfsc re0_clicked, 1
    goto varcdevam_changer
    goto varcdevam_notchanger
    varcdevam_changer:
	clrf re0_clicked
	btfsc varcdevam, 1
	goto varcdevam_clearer
	goto varcdevam_setter
	varcdevam_clearer:
	    clrf varcdevam
	    clrf varc
	    clrf PORTC
	    return
	varcdevam_setter:
	    setf varcdevam
	    btfsc varcdevam, 1
	    goto update_display4_c
	    return
	return
    return
    
varcdevam_notchanger: 
    clrf re0_clicked
    btfsc varcdevam, 1
    goto update_display4_c
    goto LATC_clearer
    LATC_clearer:
	clrf PORTC
	return
    return
    
update_display4_c:
    clrf varc
    btfsc PORTC, 0 ; LATC'nin 7. biti 1 mi?
    goto latc_zero ; 1 ise buraya
    goto latc_devam ; 0 ise buraya
    latc_zero:
	clrf PORTC
	return
    latc_devam:
	;movlw 128
	;movwf counter
	;subwfb REGG, 1, 0 ; Clear the Carry Flag
	bsf STATUS, 0  ; Clear the Carry Flag
	rrcf PORTC ; 1 basamak kaydir sa?a
	return
    return
	
    
end resetVec