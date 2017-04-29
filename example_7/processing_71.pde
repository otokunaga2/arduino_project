import processing.serial.*;
import java.net.*;
import java.io.*;
import java.util.*;

// http -< https
String feed = "https://blog.arduino.cc/feed/";

int interval = 5*60*1000;
int lastTime;
int love = 0;
int peace = 0;
int arduino = 0;
int light = 0;
Serial port;
color c;
String cs;
String buffer = "";
PFont font;

void setup() {
  // put your setup code here, to run once:
  size(640,480);
  frameRate(10);
  font = createFont("Helvetica",24);
  fill(255);
  textFont(font, 32);
  String arduinoPort = null;
  try{
    arduinoPort = Serial.list()[0];
  }catch(Exception e){
    print(e);
    System.exit(1);
  }
   
  port = new Serial(this, arduinoPort, 9600);
  lastTime = millis();
  fetchData();
}
void draw(){
  background(c);
  int n = (lastTime + interval - millis())/1000;
  c = color(peace, love, arduino);
  cs = "#" + hex(c, 6);
  text("Arduino Networked Lamp", 10, 40);
  text("Reading feed:",10, 100);
  text(feed, 10, 140);
  
  text("next update in "+n+ "seconds", 10, 450);
  text("peace", 10, 200);
  text("" + peace, 130, 200);
  rect(200, 172, peace, 28);
  
  text("love ", 10, 240);
  text(" " + love, 130, 240);
  rect(200, 212, peace, 28);
  
  text("arduino", 10, 280);
  text(" " + arduino, 130, 280);
  rect(200, 252, arduino, 28);
  
  
  //display color information
  text("sending", 10,340);
  text(cs, 200, 340);
  text("light level", 10, 380);
  rect(200, 352, light/10.23, 28);
  
  if(n <= 0){
    fetchData();
    lastTime = millis();
  }   
  port.write(cs);
  if(port.available() > 0){
    int inByte = port.read();
    if(inByte != 10){
      buffer = buffer + char(inByte);
    }else{
      if(buffer.length() > 1){
        buffer = buffer.substring(0, buffer.length() -1);
       light = int(buffer);
       buffer = "";
       port.clear();
    
      }
    }
  }
}
void fetchData(){
  String data;
  String chunk;
  love = 0;
  peace = 0;
  arduino = 0;
  try{
    URL url = new URL(feed);
    URLConnection conn = url.openConnection();
    conn.connect(); 
    
    BufferedReader in = new BufferedReader(
      new InputStreamReader(conn.getInputStream()));
      while((data = in.readLine()) != null){
        StringTokenizer st = new StringTokenizer(data, "\"<>,.()[] ");
        while(st.hasMoreTokens()){
          chunk = st.nextToken().toLowerCase();
          System.out.println(chunk);
          if(chunk.indexOf("love") >= 0)
            love++;
          if(chunk.indexOf("peace") >= 0)
            peace++;
          if(chunk.indexOf("arduino") >= 0)
            arduino++; 
        }
      }
      if( peace > 64) peace = 64;
      if( love > 64) love = 64;
      if( arduino > 64) arduino = 64;
      peace = peace * 4;
      love = love * 4;
      arduino = arduino * 4;
  }catch(Exception ex){
    ex.printStackTrace();
    System.exit(-1);
  }
  
  
}


void loop() {
  // put your main code here, to run repeatedly:

}
