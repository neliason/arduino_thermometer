import processing.serial.*;

Serial myPort; // The serial port
int button = 0;
boolean display60 = true;
boolean sensorError = false;
boolean switchError = false;
boolean displayCelsius = true;
float celsius = 0;
boolean buttonOver = false;
ArrayList<Float> points = new ArrayList<Float>();
String inString;
int savedTime;
Float fheight;

void setup () {
  size(1500, 600); //window size

  myPort = new Serial(this, Serial.list()[5], 9600); //may have to change Serial.list() array input for correct USB input port
  myPort.bufferUntil('\n'); // don't generate a serialEvent() unless you get a newline character
  background(0);
  frame.setResizable(true);
  savedTime = millis(); //start time to determine if the device is disconnected
}
void draw () {
  
  int passedTime = millis() - savedTime; 
  if (passedTime > 3000) {//if no serial event has occurred for 3 seconds, the program assumes the device has been disconnected
    textSize(24);
    fill(#ED0E0E);
    text("Device Disconnected", 3 * width / 4 - 50, 30);
    fill(255,255,255);
    
    myPort.stop(); //stop the port to so a new one can be set up
    try{
        myPort = new Serial(this, Serial.list()[5], 9600);
        myPort.bufferUntil('\n');
        
    } catch (ArrayIndexOutOfBoundsException e) {
    } 
  } 
}

//this method is called everytime data is available to be read at the port
void serialEvent (Serial myPort) {
  savedTime = millis(); //reset saved time every serial event (~1 second) so disconnection detection works
  update(mouseX, mouseY); //determines position of mouse so button clicks can be read
  fill(0);
  stroke(0, 0, 0);
  rect(0, 0, 2000, 50);
  // get the ASCII string:
  inString = myPort.readStringUntil('\n');
  celsius = Float.parseFloat(inString);
  fheight = celsius * 9 / 5 + 32;
  
  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    // convert to an int and map to the screen height:
    float inByte = float(inString);// * 5;
    if (inByte == -1000) { //-1000 sent from arduino if sensor is unplugged
      sensorError = true;
      inByte = 1000; //set inByte to 1000 so the datapoint does not show on the graph
    } else {
      sensorError = false;
    }
    if (inByte == -1001) { //-1001 sent from arduino if switch is off
      switchError = true;
      inByte = 1000; //set inByte to 1000 so the datapoint does not show on the graph
    } else {
      switchError = false;
    }
    inByte = map(inByte, 10, 50, height / 10, 9 * height / 10); //this sets the y-coordinate value of the datapoint with respect to the height of the window
    points.add(0,inByte); //put datapoint in array to be displayed later
    if (points.size() > 301) {
      points.remove(301); //only 301 datapoints need to be saved
    }
    
    
    clear();
    stroke(0, 0, 255);
    fill(255);
    displayPoints();
    
    textSize(36);
    fill(255, 255, 255);
      
    if (sensorError) {
      fill(#ED0E0E);
      text("Error : Sensor Unplugged!", width / 2 - 150, 30);
      fill(255, 255, 255);
    } else if (switchError) {
      fill(#ED0E0E);
      text("Error : Swich Off!", width / 2 - 150, 30);
      fill(255, 255, 255);
    } else if (displayCelsius) {
      text(inString + "°C", width / 2 - 10, 30);
    } else {
      text(fheight + "°F", width / 2 - 10, 30);
    }
    textSize(12);
    fill(255,255,255);
    stroke(#BABFB8);
    
    //the numbers and lines of the graph
    text(10, width - 25, 9 * height / 10);
    text(20, width - 25, 7 * height / 10);
    text(30, width - 25, 5 * height / 10);
    text(40, width - 25, 3 * height / 10);
    text(50, width - 25, 1 * height / 10);
    line(width - 30, 9 * height / 10, width - 30, height / 10 - 15);
    line(width - 30, 9 * height / 10, 50, 9 * height / 10);
    line(2 * (width - 30) / 3 + 17, 9 * height / 10, 2 * (width - 30) / 3 + 17, height / 10);
    line((width - 30) / 3 + 34, 9 * height / 10, (width - 30) / 3 + 34, height / 10);
    line(50, 9 * height / 10, 50, height / 10);
    line(width - 30, 7 * height / 10, 50, 7 * height / 10);
    line(width - 30, 5 * height / 10, 50, 5 * height / 10);
    line(width - 30, 3 * height / 10, 50, 3 * height / 10);
    line(width - 30, height / 10, 50, height / 10);
    text("Seconds Ago", width / 2, height - 20);
    text("°C", width - 30, 30);
    
    if (button == 1) {
      stroke(255);
    } else {
      stroke(207,216,227);
    }
    rect(40,0,20,20); //designate square to act as a button
    stroke(255);
    text("Cont:", 5,15);
    text("60/300:", 70, 15);
    rect(120,0,20,20); //designate square to act as a button
    text("°C/°F:", 150, 15);
    rect(190,0,20,20); //designate square to act as a button
    
    myPort.write(button); //communicate with arduino the value of continuous mode
    
    
  }
}

void update(int x, int y)
  {
  if (buttonOver(40,0,20,20)) {
    buttonOver = true;
  } else {
    buttonOver = false;
  }
  
}

void mousePressed() {
  if (buttonOver) { //buttonOver is true when mouse is over the continousMode button
    button = 1 - button;
  } else if (buttonOver(120,0,20,20)) { //determine if mouse over display 60/300 "button"
    display60 = !display60; 
  } else if (buttonOver(190,0,20,20)) { //determine if mouse over display C/F "button"
    displayCelsius = !displayCelsius;
  }
  
}

boolean buttonOver(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

//displays scrolling points from write to left
void displayPoints(){
  if (display60) {
      if (points.size() > 60) { //only display 60 points if points arrayList bigger than 60
        for (int i = 0; i < 61; i++) {
          ellipse(width - 30 - (width - 40) / 60 * i, height - points.get(i), 6, 6); //puts circle of datapoint on graph, points.get(i) gets point's mapping
        }
      } else {
        for (int i = 0; i < points.size(); i++) {
          ellipse(width - 30 - (width - 40) / 60 * i, height - points.get(i), 6, 6);
        }
      }
      text(20, 2 * (width - 30) / 3 + 10, height - 30); //x-coordinate values for 60 displaying 60 points
      text(40, 1 * (width - 30) / 3 + 25, height - 30);
      text(60, 45, height - 30);
    } else {
      if (points.size() > 300) {
        for (int i = 0; i < 301; i++) { //only display 300 points if points arrayList bigger than 300
          ellipse(width - 30 - (width - 40) / 300 * i, height - points.get(i), 4, 4);
        }
      } else {
        for (int i = 0; i < points.size(); i++) {
          ellipse(width - 30 - (width - 40) / 300 * i, height - points.get(i), 4, 4);
        }
      }
      text(100, 2 * (width - 30) / 3 + 10, height - 30);// x-coordinate values for displaying 300 points
      text(200, 1 * (width - 30) / 3 + 25, height - 30);
      text(300, 35, height - 30);
    }
}
