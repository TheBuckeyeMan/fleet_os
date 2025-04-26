# Markdown file to talk through how to program the Raspberry Pi Hardware and capture its data

# GPIO Pins:
GPIO = General Purpose Input Output
Each Pin on the Raspberry pi can either read a signal(Input or output a signal(Output))
**Please reference the GPIO Pin COnfiguration Image in this repo(GPIO_PINS_PDF) for BMC and BOARD Numbering **
GPIO Pins ar eprogramable pins offered on the raspberry pi. If you orient the pi so the pins are on the right side, you have pins 1 - 40 in the following configuration
1 2
3 4
5 6
7 8

## Programing GPIO 
GPIO progaming can be done in 2 ways, which you wil specify. You can specify either BOARD(Physical BOARD PIN NUMBER) or BMC(Best Practice for referencing pins)

## Simple GPIO Pin Setup - Turn on an LED
### Simple LED
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

### GPIO Inputs
GPIO.IN = Get Data
GPIO Input type(GPIO.IN) Tells the Program that we want to READ THE VALUE from the specified PIN
In Lamens terms: Hey Raspberry pi, Listen for this signal



#### Use Cases
1. A button
2. A Sensor
3. Anything that sends a signal to the pi
Every time we need to get data from a device, we will need an input to read and interporate

##### Example Female to Female GPIO Board pin 40 to 3.3 Volt Pin 1
import RPi.GPIO as GPIO
GPIO.setmode(GPIO.BCM)
inPin = 21
GPIO.setup(inPin, GPIO.IN) #Setup Board pin 40 and set it to input type IN
readVal = GPIO.input(inPin) #Read value from Board pin 40 and captured in this variable
print(readVal) # Print the value
GPIO.cleanup() # clean up the pin

##### Example using a Loop
import RPi.GPIO as GPIO
from time import sleep
GPIO.setmode(GPIO.BCM)
inPin = 21
GPIO.setup(inPin, GPIO.IN) #Setup Board pin 40 and set it to input type IN
try: 
    while True:
        sleep(1) 
        readVal=GPIO.input(inPin)
        print(readVal)
except KeyboardInterrupt: #We tell program to loop untill controll C
GPIO.cleanup() # clean up the pin

### GPIO Outputs
GPIO.OUT = DO SOMETHING
GPIO Output type(GPIO.OUT) Tells the Program that we want to SEND SIGNAL TO THE PIN or DO SOMETHING
In lamens term: Hay RAspberry Pi do X thing

#### Use Cases
1. An LED Light
2. A Buzzer
3. A Relay(To Controll Moters, Lights, etc)


#### GPIO Example of Flashing Light
import RPi.GPIO as GPIO
from time import sleep

GPIO.setmode(GPIO.BCM)
outPin = 17
GPIO.setup(outpin, GPIO.OUT)
try:
    while True:
        sleep(1)
        print("The Light is On")
        GPIO.output(outPin, True)
        sleep(1)
        print("The Light is Off")
        GPIO.output(outPin, False)
except KeyboardInterruption:
    GPIO.cleanup()


### GPIO Pull Up vs Pull Down
SETS GPIO INPUT VALUE TO A DEFAULT VALUE
When we set GPIO.IN(So getting or waiting for data) it just floats there(Not automatically high or low) and could pick up random electrical noise and believe something happened when it didnt
As a result, we want to set a pin defuat state when nothing is connected
Allows for a button or 

Pull Up: Defaults the pin to HIGH(3.3V) THIS SETS THE DEFAULT VALUE TO 1 OR TRUE
Example: GPIO.setup(inPin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
Pull Down: Defaults the pin to LOW(0V) THIS SETS THE DEFAULT VALUE TO 0 OR FALSE
Example: GPIO.setup(inPin, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)


### Making A Button work as we want it to
import RPi.GPIO as GPIO
from time import sleep
.
.

GPIO.setmode(GPIO.BCM)
inPin = 21
outPin = 17

GPIO.setup(inPin, GPIO.IN)
GPIO.setup(outPin, GPIO.OUT)

try:
    while true:
        sleep(1)
        readVal = GPIO.input(inPin)
        GPIO.output(outPin, True)
        print(readVal)
except KeyboardInterruption:
    GPIO.cleanup();

