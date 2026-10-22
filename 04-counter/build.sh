source ../env.sh

avr-gcc -mmcu=attiny1616 \
	-I"$AVR_LIBC/include" \
	-x assembler-with-cpp \
	-c counter.S -o counter.o

avr-gcc -mmcu=attiny1616 \
	-nostdlib -nostartfiles \
	-B"$AVR_LIBC/lib/avrxmega3/" \
	-L"$AVR_LIBC/lib/avrxmega3/" \
	-Wl,-Map=counter.map \
	counter.o -o counter.elf

