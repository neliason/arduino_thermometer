# arduino_thermometer
Arduino thermometer with Processing interface

NOTE: Connected Arduino Uno with temperature sensor required for Processing application to work.

Parts:
Arduino Uno
Temperatur sensor (https://www.sparkfun.com/products/11050)
8 LEDs
8 150 Ω resistors
1 4.7 kΩ resitor
1 10 MΩ resistor
1 Push Button
1 Toggle Switch

Assembly:
Connect the Arduino 5V power to pin 1 of the temperature sensor and the push putton.
Connect 7 LEDs to pins 3-9, each in series with 150 Ω resistors, then to the Arduino ground.
Connect pin 10 to pin 2 of the temperature sensor.
Connect error LED to pin 12, in series with 150 Ω resistor, then to the Arduino ground.
Connect pin 3 of the temperature sensor to the Arduino ground.




The Arduino Uno serves as the main processing unit of the device. The probe connects through the temperature sensor connector and interfaces with the Arduino. The switch is placed between the battery and the Arduino to turn on and cut off power to the unit when needed. The button sends a control signal to the Arduino to dictate device operation. Beyond these “input” devices there are 8 “output” LEDs which function as a 7 bit binary temperature output as well as one LED that functions as an error bit.

The software makes use of two computer programs that are required to run the device. The first is Arduino’s IDE (download at http://arduino.cc/en/Main/Software) which is used to program the Arduino microprocessor.  The other is Processing (download at https://www.processing.org/download), which is used to create a computer based user interface for graphing the data using Java.
To run the program, download the above applications.  Unzip the source files and open them.  In order for the Arduino code to work, you must first download the OneWire library (downloahttp://playground.arduino.cc/Learning/OneWire).  Once download, unzip the file into your ~/Arduino/libraries folder.  Plug the Arduino into the computer and press the “Upload” button in the Arduino IDE.  Once the code is loaded, you can run the computer interface by pressing the run button on the Processing IDE.
The Arduino code uses the OneWire library to read the temperature sensor.    The program uses pin’s 3-9 for output to LEDs to display a binary reading of the temperature.  A pin is set to high to light the LED and low to dim the LED.  Pin 2 is used as an input for the button.  When the pin is read as high, the button is pressed and code to display binary on the LEDs is run.  Pin 10 is used as input from the temperature sensor, whose data is read in degrees Celsius (code for this can be found at http://bildr.org/2011/07/ds18b20-arduino/). The switch is connected to pin 11.  When the switch is off, the reading on the pin is low, which signals an error with the switch.  Pin 12 is used for output to an error LED, which lights up if there is an error from the switch or the temperature sensor.

The Processing code uses data from the Arduino to graph its data.  A USB is used for input from the Arduino.  There are 3 different messages received from the Arduino.  The first is a data point, which is a temperature reading is Celsius.  The second is a temperature sensor error, which occurs when the sensor is unplugged.  The Arduino sends -1000 as the data point when there is a sensor error.  The third message is a switch error, which occurs when the switch is set to off.  The Arduino sends -1001 as the data point when there is a switch error.  The Processing program sends data to the Arduino when the continuous mode button is pressed.  The program writes a 1 to the port when continuous mode is active and a 0 when it is inactive.  The Arduino reads from the port and turns the LEDs on or off accordingly.  The program can take three inputs from the user.  The first is turning on continuous mode mentioned above.  The second is a button to switch the graph between display modes of 60 points and 300 points.  The last is a button to switch the temperature reading between Celsius and Fahrenheit.

