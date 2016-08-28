import processing.serial.*;
import toxi.geom.*;
import toxi.processing.*;

// The serial port
Serial port;                         

String message;

float[] q = new float[4];
Quaternion quat = new Quaternion(1, 0, 0, 0);
// new line character in ASCII
int newLine = 13; 
String [] massQ = new String [4];
float[] ypr = new float[3];
int d=25;//диаметр кружка
float x,y;
void setup() 
{
  // size form 300x300
  size(400, 400, P3D); //размер окна
  noStroke();
  // open serial port
  // replace "COM29" with the COM port on which your arduino is connected
  port = new Serial(this, "COM9", 115200);
  background(250);//цвет фона
 

}

void draw() 
{
  // read and parse incoming serial message
  serialEvent();
  // set background to black
 // background(0);
  printQuaternions();
  printYawPitchRoll();
  // set position to centre
  translate(width / 2, height / 2);
  fill(random(128)+128,random(255),random(255));//цвет кружка
  ellipse(x,y, d,d);
  
  y = y -  ypr[2]*0.05; //влияем на Y с помощью Roll
  x = x +  ypr[1]*0.1 ; //влияем на X с помощью 
  
  if (x > width/2) {x = width/2;}
 if (x < -(width/2)) {x = -(width/2);} 
 if (y > height/2) {y = height/2;}
  if (y < -(height/2)) {y = -height/2;}
  
  
  port.write('s');
}

void serialEvent() {
  // read from port until new line (ASCII code 13)
  message = port.readStringUntil(newLine);
  if (message != null) {
    // split message by commas and store in String array 
    massQ = split(message, " ");
    q[0] = float(massQ[0]);
    q[1] = float(massQ[1]);
    q[2] = float(massQ[2]);
    q[3] = float(massQ[3]);
  }
  // print values to console
  print(q[0]);
  print("\t");
  print(q[1]); 
  print("\t");
  print(q[2]);   
  print("\t");
  print(q[3]);   
  println("\t");
  // set our toxilibs quaternion to new data
  quat.set(q[0], q[1], q[2], q[3]);
}

void drawCylinder() {
  float topRadius = 0;
  float bottomRadius = 20;
  float tall = 20;
  int sides = 8;
  // begin object
  pushMatrix();
  translate(0, 0, -120);
  rotateX(PI/2);
  fill(0, 0, 255, 200);

  float angle = 0;
  float angleIncrement = TWO_PI / sides;
  beginShape(QUAD_STRIP);
  for (int i = 0; i < sides + 1; ++i) {
    vertex(topRadius*cos(angle), 0, topRadius*sin(angle));
    vertex(bottomRadius*cos(angle), tall, bottomRadius*sin(angle));
    angle += angleIncrement;
  }
  endShape();

  // if it is not a cone, draw the circular top cap
  if (topRadius != 0) {
    angle = 0;
    beginShape(TRIANGLE_FAN);

    // center point
    vertex(0, 0, 0);
    for (int i = 0; i < sides + 1; i++) {
      vertex(topRadius * cos(angle), 0, topRadius * sin(angle));
      angle += angleIncrement;
    }
    endShape();
  }

  // if it is not a cone, draw the circular bottom cap
  if (bottomRadius != 0) {
    angle = 0;
    beginShape(TRIANGLE_FAN);

    // center point
    vertex(0, tall, 0);
    for (int i = 0; i < sides + 1; i++) {
      vertex(bottomRadius * cos(angle), tall, bottomRadius * sin(angle));
      angle += angleIncrement;
    }
    endShape();
  }
  popMatrix();
}




void printQuaternions() {
  textMode(SHAPE); // set text mode to shape
  textSize(13);
  fill(255, 255, 255);
  text("Quaternions:", 20, 20, 10);
  text(q[0], 20, 40, 10);
  text(q[1], 20, 60, 10);
  text(q[2], 20, 80, 10);
  text(q[3], 20, 100, 10);
}

void printYawPitchRoll() {
  // calculate yaw/pitch/roll angles
  ypr[0] = atan2(2 * q[1] * q[2] - 2 * q[0] * q[3], 2 * q[0] * q[0] + 2 * q[1] * q[1] - 1)*57.2;
  ypr[1] = atan2(2 * q[2] * q[3] - 2 * q[0] * q[1], 2 * q[0] * q[0] + 2 * q[3] * q[3] - 1)*57.2;
  ypr[2] = -atan2(2.0f * (q[0] * q[2] - q[1] * q[3]), 1.0f - 2.0f * (q[2] * q[2] + q[1] * q[1]))*57.2;

  text("Yaw:", 150, 20, 10);
  text(ypr[0], 150, 40, 10);
  text("Pitch:", 220, 20, 10);
  text(ypr[1], 220, 40, 10);
  text("Roll:", 290, 20, 10);
  text(ypr[2], 290, 40, 10);
}