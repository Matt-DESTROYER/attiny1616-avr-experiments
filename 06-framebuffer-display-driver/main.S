#include <avr/io.h>

.section .vectors, "ax", @progbits
.global __vectors
__vectors:
	jmp reset

.extern sda_low
.extern sda_high
.extern scl_low
.extern scl_high

.extern initialise_display
.extern render_square
.extern clear_display

.section .text, "ax", @progbits
.global reset

; Ports:
;  > PC0 = red breakout board LED
;  > PB1 = SDA
;  > PB0 = SCL
;
; Special registers:
;  > r16 = used in delay/
;          scratch otherwise
;  > r17 = function input 1
;  > r18, r19 = used in delay/
;               scratch otherwise
;  > r20, r21, r22, r23, r24, r25, r26
;        = display rendering function inputs/
;          used in display rendering/
;          scratch otherwise
;  > r31 = function output 1

.global SDA_bm
.global SCL_bm

.equ SDA_bm, 0b00000010
.equ SCL_bm, 0b00000001

.global DISPLAY_WRITE_ADDRESS
.global DISPLAY_READ_ADDRESS

.equ DISPLAY_WRITE_ADDRESS, 0b01111000
.equ DISPLAY_READ_ADDRESS, 0b01111001

reset:
	; set PC0 to output mode and turn off
	ldi r16, 0b00000001
	sts PORTC_DIRSET, r16
	sts PORTC_OUTSET, r16

	; set pull up resistor to pull HIGH when not LOW for SDA
	ldi r16, PORT_PULLUPEN_bm
	sts PORTB_PIN1CTRL, r16
	sts PORTB_PIN0CTRL, r16

	; initialise output to always be LOW
	; (never needs to be changed as it will only be active in output mode)
	ldi r16, 0b00000000
	sts PORTB_OUT, r16

	; initialise lines to HIGH
	rcall sda_high
	rcall scl_high

start:
	rcall initialise_display

loop:
	ldi r20, 74 ; RX = 74
	ldi r21, 16 ; RY = 16
	ldi r22, 6  ; RR = 6
	rcall render_square

	; delay 
	ldi r17, 255
	rcall delay_ms

	rcall clear_display

	ldi r17, 255
	rcall delay_ms

	rjmp loop

; show RED LED to indicate an error
error:
	ldi r16, 0b00000001
	sts PORTC_OUTCLR, r16

	ret

