#include <OneWire.h> //Required for the DS18S20 temperature sensor

int tempPin = 10;
int ledPins[] = {3,4,5,6,7,8,9}; //pins for LED output
int celsius;
int buttonPin = 2;
int continuousState = 0;
int errorPin = 12;
int switchPin = 11;
OneWire ds(tempPin);
boolean sensorError = false;
boolean switchError = false;
int count = 0;

void setup() {
  //initiate the serial channel to communicate with computer through USB 
  Serial.begin(9600);
  
  //set led pins as output to light them up
  for (int i = 0; i < 7; i++) {
    pinMode(ledPins[i], OUTPUT); 
  }
  
  pinMode(switchPin, INPUT);
  pinMode(errorPin, OUTPUT);
  pinMode(buttonPin, INPUT);
  
}

void loop() {
  celsius = getTemp();
  if (celsius == -1000) { //getTemp() method returns -1000 for error with the sensor
    sensorError = true;
    digitalWrite(errorPin, HIGH);
    count -= 31; //this keeps the rate of each datapoint at 1 second since getTemp() takes less time when it returns -1000 
  } else {
    sensorError = false;
    digitalWrite(errorPin, LOW);
  }
  if (digitalRead(switchPin) == LOW) { //the switchpin is low when the switch is off
    digitalWrite(errorPin, HIGH);
    switchError = true;
  } else {
    digitalWrite(errorPin, LOW);
    switchError = false;
  }
  
  if (Serial.available() > 0) { //to determine when data is available from the computer program
    continuousState = Serial.read(); //the program only communicates wheter to start or stop continuous state mode
  }
  
  if ((digitalRead(buttonPin) == HIGH || continuousState == 1) && !switchError && !sensorError) {
    ledDisplay();
    count += 32; //this accounts for the extra time spent by the processor in the ledDisplay() method
  } else {
    for (int i = 0; i < 7; i++) {
       digitalWrite(ledPins[i], LOW); //make sure LEDs return to low when button released or continous mode stopped
     }
  }
  count += 32; //arbitrary number selected to space data points by one second
  if (count >= 928) { //1 second passes when count gets up to 928
    count = 0;
    if (!switchError && !sensorError) {
      Serial.println(celsius);
    } else if (switchError) {
      Serial.println(-1001); //-1001 is read by the computer program to signal a switch error
    } else {
      Serial.println(-1000); //-1000 is read by the computer program to signal a sensor error
    }
  }
  
  
  
}

//the following DS18S20 temperature sensor code is provided at http://bildr.org/2011/07/ds18b20-arduino/
int getTemp() {
  //returns the temperature from one DS18S20 in DEG Celsius

  byte data[12];
  byte addr[8];

  if ( !ds.search(addr)) {
      //no more sensors on chain, reset search
      ds.reset_search();
      return -1000;
  }

  if ( OneWire::crc8( addr, 7) != addr[7]) {
      //Serial.println("CRC is not valid!");
      return -1000;
  }

  if ( addr[0] != 0x10 && addr[0] != 0x28) {
      //Serial.print("Device is not recognized");
      return -1000;
  }

  ds.reset();
  ds.select(addr);
  ds.write(0x44,1); // start conversion, with parasite power on at the end

  byte present = ds.reset();
  ds.select(addr);    
  ds.write(0xBE); // Read Scratchpad

  
  for (int i = 0; i < 9; i++) { // we need 9 bytes
    data[i] = ds.read();
  }
  
  ds.reset_search();
  
  byte MSB = data[1];
  byte LSB = data[0];

  float tempRead = ((MSB << 8) | LSB); //using two's compliment
  float TemperatureSum = tempRead / 16;
  
  return TemperatureSum;
  
}


void ledDisplay() {
   int temp = getTemp();
   if (temp > 0) {
     if (temp >= 32) {
       digitalWrite(ledPins[5], HIGH);
       temp -= 32; //subtracted to determine the remaining bits
     }
     if (temp >= 16) {
       digitalWrite(ledPins[4], HIGH);
       temp -= 16;
     }
     if (temp >= 8) {
       digitalWrite(ledPins[3], HIGH);
       temp -= 8;
     } 
     if (temp >= 4) {
       digitalWrite(ledPins[2], HIGH);
       temp -= 4;
     }
     if (temp >= 2) {
       digitalWrite(ledPins[1], HIGH);
       temp -= 2;
     }
     if (temp == 1) {
       digitalWrite(ledPins[0], HIGH);
       temp -= 1;
     }
   } else if (temp < 0) {
     for (int i = 0; i < 7; i++) {
       digitalWrite(ledPins[i], HIGH); //2s complement of -1 is all high LEDs
     }
     if (temp == -2) {
       digitalWrite(ledPins[0], LOW); //indiviually set pins for numbers less than -1
     }
     else if (temp == -3) {
       digitalWrite(ledPins[1], LOW);
     }
     else if (temp == -4) {
       digitalWrite(ledPins[0], LOW);
       digitalWrite(ledPins[1], LOW);
     }
     else if (temp == -5) {
       digitalWrite(ledPins[2], LOW);
     }
     else if (temp == -6) {
       digitalWrite(ledPins[0], LOW);
       digitalWrite(ledPins[2], LOW);
     }
     else if (temp == -7) {
       digitalWrite(ledPins[1], LOW);
       digitalWrite(ledPins[2], LOW);
     }
     else if (temp == -8) {
       digitalWrite(ledPins[0], LOW);
       digitalWrite(ledPins[1], LOW);
       digitalWrite(ledPins[2], LOW);
     }
     else if (temp == -9) {
       digitalWrite(ledPins[3], LOW);
     }
     else if (temp == -10) {
       digitalWrite(ledPins[3], LOW);
       digitalWrite(ledPins[0], LOW);
     }
   }
   
}
