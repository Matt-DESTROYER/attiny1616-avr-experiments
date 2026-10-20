source ../env.sh

avr-gcc -mmcu=attiny1616 \
	-I"$AVR_LIBC/include" \
	-x assembler-with-cpp \
	-c traffic-lights.S -o traffic-lights.o

avr-gcc -mmcu=attiny1616 \
	-nostdlib -nostartfiles \
	-B"$AVR_LIBC/lib/avrxmega3/" \
	-L"$AVR_LIBC/lib/avrxmega3/" \
	-Wl,-Map=traffic-lights.map \
	traffic-lights.o -o traffic-lights.elf

