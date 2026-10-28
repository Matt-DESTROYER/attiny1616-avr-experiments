.global initialise_display
.global render_square
.global clear_display

; initialise GME12864-11 display (with SSD1306)
initialise_display:
	; from OFF state

	; Power up VDD
	; RES# as LOW state
	; handled by GME display module

	; Power stabilised
	; (Delay recommended)

	; Power up VDOB
	; (100ms delay recommended)
	ldi r17, 100
	rcall delay_ms

	; Set RES# as HIGH
	; (3us delay minimum)
	; handled by GME display module
	rcall delay_100_cycles

	; Initialised state
	; (Parameters as default)

	; initialise i2c transmission
	rcall i2c_start

	; specify display's I2C address
	ldi r17, DISPLAY_WRITE_ADDRESS
	rcall i2c_write_byte

	; control byte (command mode)
	ldi r17, 0x00
	rcall i2c_write_byte

	; Set display OFF
	ldi r17, 0xAE
	rcall i2c_write_byte

	; Initial settings configuration

	; set display clock divide ratio/oscilator frequency
	ldi r17, 0xD5
	rcall i2c_write_byte
	ldi r17, 0x80
	rcall i2c_write_byte

	; Set multiplex ratio
	ldi r17, 0xA8
	rcall i2c_write_byte
	ldi r17, 0x3F
	rcall i2c_write_byte

	; Set display offset
	ldi r17, 0xD3
	rcall i2c_write_byte
	ldi r17, 0x00
	rcall i2c_write_byte

	; Set display start line
	ldi r17, 0x40
	rcall i2c_write_byte

	; Set segment re-map
	ldi r17, 0xA1
	rcall i2c_write_byte

	; Set COM output scan direction
	ldi r17, 0xC8
	rcall i2c_write_byte

	; Set COM pins hardware configuration
	ldi r17, 0xDA
	rcall i2c_write_byte
	ldi r17, 0x12
	rcall i2c_write_byte

	; Set contrast control
	ldi r17, 0x81
	rcall i2c_write_byte
	ldi r17, 0x86
	rcall i2c_write_byte

	; Set pre-charge period
	ldi r17, 0xD9
	rcall i2c_write_byte
	ldi r17, 0xF1
	rcall i2c_write_byte

	; Set VCOMH deselect level
	ldi r17, 0xDB
	rcall i2c_write_byte
	ldi r17, 0x30
	rcall i2c_write_byte

	; Set disable entire display
	ldi r17, 0xA4
	rcall i2c_write_byte

	; Set normal/inverse display
	ldi r17, 0xA6
	rcall i2c_write_byte

	; Clear display
	rcall i2c_stop

	rcall clear_display

	rcall i2c_start
	ldi r17, DISPLAY_WRITE_ADDRESS
	rcall i2c_write_byte
	ldi r17, 0x00
	rcall i2c_write_byte

	; Set charge pump regulator
	ldi r17, 0x8D
	rcall i2c_write_byte
	ldi r17, 0x14
	rcall i2c_write_byte

	; Set display ON
	ldi r17, 0xAF
	rcall i2c_write_byte

	; end I2C transmission
	rcall i2c_stop

	; Power stabilised
	; (100ms delay recommended)
	ldi r17, 100
	rcall delay_ms

	ret

vertical_page_addressing_mode:
	rcall i2c_start

	ldi r17, DISPLAY_WRITE_ADDRESS
	rcall i2c_write_byte

	; control byte (command mode)
	ldi r17, 0x00
	rcall i2c_write_byte

	; memory addressing mode
	ldi r17, 0x20
	rcall i2c_write_byte

	; vertical addressing mode
	ldi r17, 0x01
	rcall i2c_write_byte

	rcall i2c_stop
	
	ret

; takes in r20, r21 as X (rx) and Y (ry) coords
; in the plane x = [0, 128), y = [0, 64)
; and r22 as size (rr)
render_square:
	; set memory addressing mode
	rcall vertical_page_addressing_mode

	ldi r23, 0
	ldi r24, 0

	lsr r22 ; divide by two (gives proper size when checking later) 

	; start I2C transmission
	rcall i2c_start
	ldi r17, DISPLAY_WRITE_ADDRESS
	rcall i2c_write_byte
	ldi r17, 0x40
	rcall i2c_write_byte
render_square_loop:
	ldi r17, 0 ; current byte sending
	ldi r25, 0b00000001 ; current bit mask
	ldi r26, 0 ; current bit index
	rjmp render_square_bit_loop
	; we need to check if each bit is inside the square
	; for each bit
	; we have to check
	; (x > rx - rr) && (x < rx + rr) && (y > ry - rr) && (y < ry + rr)
render_square_bit_loop:
	; current bit is at coords (r24, 8*r23+r26)
	mov r27, r23
	ldi r28, 8
	mul r27, r28 ; result is stored in r1:r0
	mov r27, r0 ; (at most this will be 56)
	add r27, r26

	; current bit is at (r24, r27)

	; (we ignore overflow issues for now, but the boundaries would
	; likely have weird results if the square is too close)

	; check x < rx - rr
	mov r28, r20 ; rx
	sub r28, r22 ; rx - rr
	; x < rx - rr
	cp r24, r28
	brlo render_square_bit_finish

	; check x > rx + rr
	mov r28, r20 ; rx
	add r28, r22 ; rx + rr
	; rx + rr < x
	cp r28, r24
	brlo render_square_bit_finish

	; check y < ry - rr
	mov r28, r21 ; ry
	sub r28, r22 ; ry - rr
	; y < ry - rr
	cp r27, r28
	brlo render_square_bit_finish

	; check y > ry + rr
	mov r28, r21 ; ry
	add r28, r22 ; ry + rr
	; ry + rr < x
	cp r28, r27
	brlo render_square_bit_finish

	; if we passed all checks:
	; set the current bit based on the mask
	or r17, r25
render_square_bit_finish:
	; check if this was the last bit
	cpi r25, 0b10000000
	breq render_square_finish_byte
	; handle increments and loop
	lsl r25
	inc r26
	rjmp render_square_bit_loop
render_square_finish_byte:
	rcall i2c_write_byte
	inc r23
	cpi r23, 8
	breq render_square_outer_loop
	rjmp render_square_loop
render_square_outer_loop:
	inc r24
	cpi r24, 128
	breq render_square_finish
	ldi r23, 0
	rjmp render_square_loop
render_square_finish:
	rcall i2c_stop
	lsl r22 ; undo halving (will be off by one for odd numbers, but that's acceptable for now)
	ret

clear_display:
	; set memory addressing mode
	rcall vertical_page_addressing_mode

	; (128x64)/8 = 1024 bytes (1 bit per pixel)
	;            = 32x32 (weird choice, but it works so idc)
	ldi r20, 0
	ldi r21, 0

	; start I2C transmission
	rcall i2c_start
	ldi r17, DISPLAY_WRITE_ADDRESS
	rcall i2c_write_byte
	; control byte (data mode)
	ldi r17, 0x40
	rcall i2c_write_byte

	; byte to write
	ldi r17, 0x00
clear_display_loop:
	rcall i2c_write_byte
	inc r20
	cpi r20, 32
	breq clear_display_outer_loop
	rjmp clear_display_loop
clear_display_outer_loop:
	inc r21
	cpi r21, 32
	breq clear_display_finish
	ldi r20, 0
	rjmp clear_display_loop
clear_display_finish:
	rcall i2c_stop
	ret

