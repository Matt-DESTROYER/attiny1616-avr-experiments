#include <avr/io.h>

.global sda_low
.global sda_high
.global scl_low
.global scl_high

.global i2c_start
.global i2c_stop
.global i2c_write_byte

; pull SDA LOW
sda_low:
	ldi r16, SDA_bm
	sts PORTB_DIRSET, r16

	ret

; release SDA and let pull up resistor pull HIGH
sda_high:
	ldi r16, SDA_bm
	sts PORTB_DIRCLR, r16

	ret

; Standard-mode timinim minimums
; SCL LOW 4.7us
; SCL HIGH 4.0us
; SDA set before SCL rises 250ns/0.25us
; START setup time 4.7us
; STOP setup time 4.0 us

; pull SCL LOW
scl_low:
	ldi r16, SCL_bm
	sts PORTB_DIRSET, r16

	ret

; release SCL and let pull up resistor pull HIGH
scl_high:
	ldi r16, SCL_bm
	sts PORTB_DIRCLR, r16

	ret

scl_pulse:
	rcall scl_high
	rcall delay_100_cycles

	rcall scl_low
	rcall delay_100_cycles

	ret

i2c_start:
	; reset BUS to idle state (both lines HIGH)
	rcall sda_high
	rcall scl_high
	rcall delay_100_cycles

	; drive SDA LOW while SCL is HIGH
	rcall sda_low
	rcall delay_100_cycles

	ret

i2c_stop:
	; ensure SCL LOW
	rcall scl_low
	rcall delay_100_cycles

	; ensure SDA is LOW while SCL is LOW
	rcall sda_low
	rcall delay_100_cycles

	; release SCL HIGH
	rcall scl_high
	rcall delay_100_cycles

	; release SDA HIGH while SCL is HIGH (STOP condition)
	rcall sda_high
	rcall delay_100_cycles

	ret

i2c_write_0:
	rcall scl_low
	rcall delay_100_cycles

	rcall sda_low
	rcall delay_100_cycles

	rcall scl_pulse

	ret

i2c_write_1:
	rcall scl_low
	rcall delay_100_cycles

	rcall sda_high
	rcall delay_100_cycles

	rcall scl_pulse
	ret

i2c_ack:
	; release SDA
	rcall sda_high
	rcall delay_100_cycles

	; start ninth clock pulse
	rcall scl_low
	rcall delay_100_cycles

	rcall scl_high
	rcall delay_100_cycles

	; check ACK
	; SDA LOW = ACK = 0
	; SDA HIGH = NACK = 1
	lds r31, PORTB_IN
	andi r31, SDA_bm
	lsr r31 ; forces r31 to 0 or 1 (rather than 2 or 0)

	; end ninth clock pulse
	rcall scl_low
	rcall delay_100_cycles

	ret

; writes the input (r17) byte out via I2C using SDA and SCL
; returns the ACK/NACK response (r31)
i2c_write_byte:
	ldi r18, 0b10000000
i2c_write_byte_loop:
	mov r19, r17 ; copy byte
	and r19, r18 ; apply bit mask
	cpi r19, 0
	breq i2c_write_byte_0
i2c_write_byte_1:
	rcall i2c_write_1
	rjmp i2c_write_byte_continue
i2c_write_byte_0:
	rcall i2c_write_0
	rjmp i2c_write_byte_continue
i2c_write_byte_continue:
	cpi r18, 0b00000001
	breq i2c_write_byte_finish
	lsr r18
	rjmp i2c_write_byte_loop
i2c_write_byte_finish:
	rcall i2c_ack
	ret

