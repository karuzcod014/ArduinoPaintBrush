int r = 10;
int g = 10;
int b = 10;

int numDataPoints = 50000;
int dataIndex = 1;
String[] dataStrings = new String[numDataPoints]; // Save up to 10k values

// loads a library needed to establish a connection to a serial device
// in our case, the serial device is a Circuit Playground
import processing.serial.*;   

// create a new array that will hold on to the sensor values
// from the Circuit Playground
float[] portValues = new float[8];

// create a new serial connection
Serial myPort;

// Create a string that will hold onto all the sensor values
// we will take this string and break it up into 8 parts in 
// other parts of the code
String inString;  


void setup() 
{ 
  size(1440, 850);  // canvas size
  frameRate(60); // controls how quickly the animation refreshes
  rectMode(CENTER);  // read more about this here: https://processing.org/reference/rectMode_.html
  background(255);
  // change the port name to match yours
  myPort = new Serial(this, "/dev/cu.usbmodem1421", 9600);
  
  // fill up the portValues array with zeros
  // we do this at the beginning so that we don't have
  // any runtime errors if the circuit playground doesn't work
  // right away.
  for(int i = 0; i<8; i++)
  {
    portValues[i] = 0; 
  }
  dataStrings[0] = "x,y,z,leftButton,rightButton,lightSensor,soundSensor,tempSensor";

} 

// convert float data to string data in order to save to a file
String buildDataString(float[] v) {
  String result = "";
  for(int i = 0; i<v.length-1; i++) {
   result += str(v[i]) + ","; 
  }
  result += str(v[7]);
  return result;
}

void draw() { 
  textSize(32);
  fill(255,0,0);
  text("Rows of data saved: ",10,40);
  
  fill(r,g,b);
  noStroke();
  rect(80, 60, 140, 30);
  fill(255);
  textSize(20);
  text((r + "," + g + "," + b), 15, 70);
  
  
   // this if statement makes sure that Processing is actually
   // reading data from the Circuit Playground BEFORE it runs the function
   // processSensorValues()  
  if (inString != null) {
    portValues = processSensorValues(inString); // get data
    // manage data points
    dataIndex++;
    if(dataIndex > numDataPoints - 1) {
     dataIndex = 1; 
    }
    dataStrings[dataIndex] = buildDataString(portValues);
    textSize(32);
    saveStrings("values.csv",dataStrings);
    rect(1390, 30, 100, 60);
    fill(255, 0, 0);
    text(dataIndex,width-80,40);
  }
  
  // use sound value to light yellow circle if sound is loud enough
  // the map() function is used here, its pretty rad

  
   // get the x value from the acceleromoter, use to move object horizontally
  float x = map(portValues[1],-10,10,0,width);
   
  // get the y value from the accelerometer, use to move object vertically
  float y = map(portValues[0],-10,10,0,height);
  
  // get the z value from the accelerometer, use to change rect. size.
  float z = map(portValues[2],-10,10,50,150);
 
  // use the light value to round rectangle corners
  float lightValue = portValues[5];
  
  // change the fill color based on the button presses
  if(portValues[3] == 1) {  // if the right button is pressed...
   fill(r,g,b);
   rect(x, y, z, z,lightValue); 
  } else if(portValues[4] == 1) {  // if the left button is pressed...
   background(255);
  } 
  
    if(key == 'r')
  {
    r++;
    key = ' ';
    if(r > 255)
    {
      r = 0;
    }
  }else if(key == 'g')
  {
    g++;
    key = ' ';
    if(g > 255)
    {
      g = 0;
    }
  }
  else if(key == 'b')
  {
    b++;
    key = ' ';
    if(b > 255)
    {
      b = 0;
    }
  }
 
  
  // draw rectangle using accelerometer values for position and size
  // use lightValue to change the roundedness of the rectangle.
  //
  // see the reference for rect(a,b,c,d,r) to learn more: 
  // https://processing.org/reference/rect_.html
  
  // Show the data coming in from the Circuit Playground in the 
  // console.  You'll see a stream of numbers "flowing" in the
  // console which is below the code window when the code is 
  // running.
  println(inString);
} 

//  this code gets data from the Circuit Playground
// and packages it up inside of an array.  You can go 
// here to learn more about arrays in Processing: 
// https://processing.org/reference/Array.html
//
// There is some error checking here to make sure the 
// Circuit Playground is reporting values
// the code is still a bit buggy.  If you have any errors
// in lines 138 - 164, just press stop and try again.
float[] processSensorValues(String valString) {
  
  String[] temp = {"0", "0", "0", "0", "0", "0", "0", "0"};
  
  temp = split(valString,"\t");
  
  if(temp == null) {
    for(int i = 0; i<8; i++) {
      temp[i] = "0"; 
    }
  }
  
  float[] vals = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
  for(int i = 0; i<8; i++)
  {
    if(temp != null) 
    {
      vals[i] = float(temp[i]); 
    }
    
    else
    {
      vals[i] = 0; 
    }
    
  }
  return vals;
}

// read new data from the Circuit Playground
void serialEvent(Serial p) { 
  inString = myPort.readStringUntil(10);  
} 
