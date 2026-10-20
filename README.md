# attiny1616-avr-experiments

## Components

- Adafruit ATtiny1616 breakout
- Adafruit Simple UPDI Friend
- Coloured LEDs
- Resistors
- I²C screen

## Adafruit ATtiny1616 breakout

Useful details and notes about the breakout board.

### Breakout-to-MCU pin mapping

The **breakout GPIO number**, **MCU port/pin**, and **physical MCU package pad number** are different identifiers. The register bit mask corresponds to the bit number in the port register.

| Breakout GPIO | MCU port | Physical MCU pad | Register | Bit mask |
|---:|---|---:|---|---|
| 0 | PA4 | 5 | `PORTA` | `0b00010000` |
| 1 | PA5 | 6 | `PORTA` | `0b00100000` |
| 2 | PA6 | 7 | `PORTA` | `0b01000000` |
| 3 | PA7 | 8 | `PORTA` | `0b10000000` |
| 4 | PB5 | 9 | `PORTB` | `0b00100000` |
| 5 | PB4 | 10 | `PORTB` | `0b00010000` |
| 6 | PB3 | 11 | `PORTB` | `0b00001000` |
| 7 | PB2 | 12 | `PORTB` | `0b00000100` |
| 8 | PB1 | 13 | `PORTB` | `0b00000010` |
| 9 | PB0 | 14 | `PORTB` | `0b00000001` |
| 10 | PC0 | 15 | `PORTC` | `0b00000001` |
| 11 | PC1 | 16 | `PORTC` | `0b00000010` |
| 12 | PC2 | 17 | `PORTC` | `0b00000100` |
| 13 | PC3 | 18 | `PORTC` | `0b00001000` |
| 14 | PA1 | 20 | `PORTA` | `0b00000010` |
| 15 | PA2 | 1 | `PORTA` | `0b00000100` |
| 16 | PA3 | 2 | `PORTA` | `0b00001000` |

### Special pins

| Function | MCU port/pin | Physical MCU pad |
|---|---|---:|
| UPDI programming interface | PA0 | 19 |
| I²C clock (SCL) | PB0 | 14 |
| I²C data (SDA) | PB1 | 13 |
| UART transmit (TX) | PB2 | 12 |
| UART receive (RX) | PB3 | 11 |
| Supply voltage (VDD) | — | 4 |
| Ground (GND) | — | 3 and exposed pad |

**Note:** These are the MCU's pin assignments and peripheral functions. Using a pin for a peripheral such as I²C or UART may require configuring the appropriate peripheral and pin settings.

### GPIO registers

The ATtiny1616 has separate port registers for each GPIO port (`PORTA`, `PORTB`, and `PORTC`).

| Register | Purpose |
|---|---|
| `PORTX_DIR` | Configure individual pins as inputs or outputs by writing `0` or `1` to each bit. |
| `PORTX_DIRSET` | Configure selected pins as outputs by setting their direction bits to `1`. Other bits are unaffected. |
| `PORTX_DIRCLR` | Configure selected pins as inputs by clearing their direction bits to `0`. Other bits are unaffected. |
| `PORTX_DIRTGL` | Toggle the direction bits of selected pins. |
| `PORTX_OUT` | Read or write the output latch for the port. |
| `PORTX_OUTSET` | Set selected output latch bits to `1` (high). Other bits are unaffected. |
| `PORTX_OUTCLR` | Clear selected output latch bits to `0` (low). Other bits are unaffected. |
| `PORTX_OUTTGL` | Toggle selected output latch bits. Other bits are unaffected. |
| `PORTX_IN` | Read the current logic levels at the port's pins. |
| `PORTX_INTFLAGS` | Read or clear port interrupt flags. |

Here, `X` represents the port letter (`A`, `B`, or `C`). For example, `PORTA_DIRSET` configures selected Port A pins as outputs.

**Important:** `DIRSET`, `DIRCLR`, `OUTSET`, `OUTCLR`, and `OUTTGL` are bit-selective registers. Writing a `1` to a bit selects that pin; writing a `0` leaves that pin unchanged.

For example, to configure breakout GPIO 0 (PA4) as an output:

```asm
#include <avr/io.h>

ldi r16, 0b00010000
sts PORTA_DIRSET, r16
```

To set that output high:

```asm
ldi r16, 0b00010000
sts PORTA_OUTSET, r16
```

### Onboard LED

- The onboard red LED is connected to PC0 (breakout GPIO 10, physical MCU pad 15).
- The LED is **active-low**: setting PC0 low turns it on, and setting PC0 high turns it off.

### External LEDs

For a basic external LED circuit:

1. Connect a GPIO pin to a current-limiting resistor.
2. Connect the resistor to the LED's anode (long leg).
3. Connect the LED's cathode (short leg) to GND.

With this arrangement, setting the GPIO high turns the LED on, and setting it low turns it off. Use a suitable resistor, such as 330 Ω, and ensure the current remains within the microcontroller's electrical limits.