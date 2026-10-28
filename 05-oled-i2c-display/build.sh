source ../env.sh

avr-gcc -mmcu=attiny1616 \
	-I"$AVR_LIBC/include" \
	-x assembler-with-cpp \
	-c display.S -o display.o

avr-gcc -mmcu=attiny1616 \
	-nostdlib -nostartfiles \
	-B"$AVR_LIBC/lib/avrxmega3/" \
	-L"$AVR_LIBC/lib/avrxmega3/" \
	-Wl,-Map=display.map \
	display.o -o display.elf

