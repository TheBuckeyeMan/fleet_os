# Markdown file to talk through how to program the Raspberry Pi Hardware and capture its data

# GPIO Pins:
**Please reference the GPIO Pin COnfiguration Image in this repo(GPIO_PINS_PDF) for BMC and BOARD Numbering **
GPIO Pins ar eprogramable pins offered on the raspberry pi. If you orient the pi so the pins are on the right side, you have pins 1 - 40 in the following configuration
1 2
3 4
5 6
7 8

## Programing GPIO 
GPIO progaming can be done in 2 ways, which you wil specify. You can specify either BOARD(Physical BOARD PIN NUMBER) or BMC(Best Practice for referencing pins)

### Simple GPIO Pin Setup
#### Import the Library 
1. Import RPi.GPIO as GPIO
#### Tell the Pi What Mode we are setting it to(BCM or BOARD)
2. GPIO.setmode(GPIO.BCM) # You can also set to BOARD Here if you want to reference the physical board, not the BCM Number
#### Configure you GPIO Pin
3. GPIO.setup(<BCM or BOARD Pin Number>, <GPIO Type>) #Example: GPIO.setup(17, GPIO.OUT)
#### Preform action on the pin
4. GPIO.output(<BCM or BOARD Pin Number>, <Value>) # Example GPIO.output(17, True) - Turns on the LED on Phtical pin 10
#### Cleanup the pin so it can be used in the future for other processes
5. GPIO.cleanup()
