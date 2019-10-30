import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Interface_setup_processing extends PApplet {





/////////////////////////////////////////// SETTINGS
int digPins = 7;
int anaPins = 7;

int extraVals = 7;

int heightOffset = 40;
int timeSpeed = 30;         //second for half around

int doublePressInterval = 400;
/////////////////////////////////////////// SETTINGS

ChildApplet dataWindow;
Serial myPort;  

String ardVal;
int detectedFront = 0;
int prevDetectedFront = 0;

int[] dPin = new int[digPins];
int[] aPin = new int[anaPins];
int[] eVal = new int[extraVals];

int[] prevdPin = new int[digPins];
int[] lastDPressMillis = new int[digPins];
int[] secondLastDPressMillis = new int[digPins];


float actHeight;

float timeUpdateInterval;

int pointerValue;








public void settings(){
    smooth();
    fullScreen(3); //3

}

public void setup(){
    background(255);
    surface.setTitle("Interface Window");
    dataWindow = new ChildApplet();
    
            ellipseMode(CENTER);
            rectMode(CORNER);

    actHeight = height+heightOffset;
    timeUpdateInterval = (timeSpeed/180);
    noStroke();

    prevdPin[0] = 1;
}

//Run for Interface window
public void draw(){
    // if(detectedFront != prevDetectedFront){
    //     curScreen = 0;
    // }
    // prevDetectedFront = detectedFront;

    if(detectedFront == 1){
     frontOne(aPin[1]);
    }
    else if(detectedFront == 2){
     frontThree(eVal[0]);
    }


}


public float mm2Pix(float mm){
    return mm*9.2f;
}




public boolean singleDPress(int pressPin){
    if(dPin[pressPin] == 1 && prevdPin[pressPin] == 0){
        prevdPin[pressPin] = dPin[pressPin];
        secondLastDPressMillis[pressPin] = lastDPressMillis[pressPin];
        lastDPressMillis[pressPin] = millis();
        println("Single Press: " + pressPin);
        return true;
    }
    else{
        prevdPin[pressPin] = dPin[pressPin];
        return false;
    }
}

public boolean doubleDPress(int pressPin){
    singleDPress(pressPin);

    if(lastDPressMillis[pressPin] - secondLastDPressMillis[pressPin] < doublePressInterval && (lastDPressMillis[pressPin] - secondLastDPressMillis[pressPin]) > 0){
        println("Double Press: " + pressPin);
        secondLastDPressMillis[pressPin] = millis();
        return true;
    }
    else{
        return false;
    }
}


int[][] colorScheme = {
    //label 1  label 2  label 3  label 4  label 5  label 6
    {0xff9BFFD3, 0xff8FF1FF, 0xff82E8D9, 0xff82E89F, 0xff8FFF8F, 0xff00EBFF},            //scheme 1
    {0xffFF4E47, 0xffE84181, 0xffFF53EB, 0xffC541E8, 0xffA747FF, 0xff5E47FF},            //scheme 2
    {0xff1793FF, 0xff15E5E8, 0xff24FF98, 0xff15E820, 0xff93FF17, 0xffEFFF53},            //scheme 3
    {0xffFFBA26, 0xffE89523, 0xffFF8C33, 0xffE85C23, 0xffFF4526, 0xffFF35B3}
};



String labelNames[][] = {
    {"leaving home", "cooking", "coffee", "media"},
    {"tv", "video", "news", "gaming"},
    {"alone", "with friends", "with grandma", "with family"},
    {"salad", "burned", "serving", "dinner party"}
    
    
};
class ChildApplet extends PApplet {
  public ChildApplet() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(400, 800);
    smooth();
  }
  public void setup() { 
    background(255);
    surface.setTitle("Data Window");

    //connect to arudino
    String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
    myPort = new Serial(this, portName, 115200);



  }

  public void draw() {
    background(255);
    //detectFront();    //this has been moved ot the arudino

    //read arduino and assign+print variables
    if (myPort.available() > 0) 
    {  // If data is available,
    ardVal = myPort.readStringUntil('\n');         // read it and store it in Ardval
    } 
    if(ardVal!=null){
      String[] splitVal = split(ardVal, ",");
      if(splitVal == null){
        println("splitVal = null");
        return;
      }
      else {
      //  print(splitVal);
      }
      fill(0);
      textSize(15);
      text("Variable monitor", 10, 25);
      for(int i = 0; i < digPins; i++){
        text("D"+ i +": ", 10, (55+(i*15)));
        text(splitVal[i], 50, (55+(i*15)));
        dPin[i] = parseInt(splitVal[i]);        
      }
      for(int i = 0; i < anaPins; i++){
        text("A"+ i +": ", 10, ((55+(digPins)*15) + 15 + (i*15)));
        text(splitVal[i+digPins], 50, ((55+(digPins)*15) + 15 + (i*15)));
        aPin[i] = parseInt(splitVal[i+digPins]);
      }
      for(int i = 0; i < extraVals; i++){
        text("E"+ i +": ", 10, ((55+(digPins)*15+(anaPins*15)) + 30 + (i*15)));
        text(splitVal[i+digPins+anaPins], 50, ((55+(digPins)*15+(anaPins*15)) + 30 + (i*15)));
        eVal[i] = parseInt(splitVal[i+digPins+anaPins]);
      }

      
        //note found front (as received by arudino)
        text("Front detected: ", 200, 25);
        detectedFront = PApplet.parseInt(splitVal[digPins+anaPins+extraVals]);
        text(detectedFront, 350, 25);
    }


    text("curScreen", 200, 50);
    text(curScreen, 350, 50);

    text("curSchemeNumb", 200, 75);
    text(currentSchemeNumber, 350, 75);

    text("labelselecocc", 200, 100);
    text(labelSelectorOccupied, 350, 100);

    text("pointervalue", 200, 125);
    text(pointerValue, 350, 125);
  }




  // void detectFront(){
  //   if(aPin[0] < 35 && aPin[0] > 20){
  //     detectedFront = 1;    extraVar[0] = 20;
  //   }
  //   else{
  //     detectedFront = 0;
  //   }
  // }

}
///////////////////////////////////// SETTINGS 
long minGenerateLabelDelay = 15000;              //15 sec
long maxGenerateLabelDelay = 12000000;           //2min



///////////////////////////////////// SETTINGS 



int currentSchemeNumber = 0;

int labelsDrawn = 0;



//color hex
//duration 0-180
//timago 0-180
//certianty 0-100
LabelEvent[] labelEvent = new LabelEvent[]{
    new LabelEvent(0xff00FF00, 10, 10, 50),
    new LabelEvent(0xff0000FF, 5, 90, 40),
    new LabelEvent(0xff0000FF, 20, 150, 90),
    new LabelEvent(0xff000000, 20, 360, 100),            
    new LabelEvent(0xff000000, 20, 360, 100),            
    new LabelEvent(0xff000000, 20, 360, 100),            
    new LabelEvent(0xff000000, 20, 360, 100),            
    new LabelEvent(0xff000000, 20, 360, 100),            
    new LabelEvent(0xff000000, 20, 360, 100),            
    new LabelEvent(0xff000000, 20, 360, 100),            
    new LabelEvent(0xff000000, 20, 360, 100),            

    new LabelEvent(0xff000000, 20, 360, 100),            //not visible because of timeAgo
};



LabelEventSelector[] labelSelec = new LabelEventSelector[]{
new LabelEventSelector(),
new LabelEventSelector(),
new LabelEventSelector(),
new LabelEventSelector(),
};


int curScreen = 0;

float labelSelectorOccupied = 0;

boolean goBack = false;

long lastGenLabel;
long generatorInterval;
int generatedLabelNumber = 3;

public void frontOne(int pointerValue){


    
    switch(curScreen) {
    	 case 0: 
            screenZero();
            if(singleDPress(0)){
                boolean wasOverLabel = false;
                for(int i = 0; i < labelEvent.length; i++){
                    if(labelEvent[i].curOverEvent(pointerValue)){
                        wasOverLabel = true;
                        labelEvent[i].timeAgo = 360;
                    }
                }
                if(wasOverLabel == false){                                                           //pressed over nothing -> show labelselector
                    curScreen = 1;
                    currentSchemeNumber = 0;
                    labelSelectorOccupied = 0;
                    for(int i = 0; i < labelSelec.length-1; i++){  
                        labelSelec[i].redrawSelector(); 
                    }               
                    goBack = false;
                }
            }
            break;
         case 1:
            screenOne(pointerValue);
            // if(singleDPress(0)){
            //     labelSelectorOccupied = 0;
            // }         
            break;
    } 


    //draw pointer
    fill(255, 0, 0);
    stroke(255);
    arc(mm2Pix(90), (actHeight/2), mm2Pix(100), mm2Pix(100), radians(map(pointerValue, 0, 1023, 360, 0)), (radians(map(pointerValue, 0, 1023, 360, 0)+radians(40))));
    noStroke();

    //generate additional labels
    labelGenerator();
   // println("generatedLabelNumber: " + generatedLabelNumber);
}


public void labelGenerator(){
    if(millis() - lastGenLabel > generatorInterval){
        generatorInterval = (long) random(minGenerateLabelDelay, maxGenerateLabelDelay);
        labelEvent[generatedLabelNumber].timeAgo = 0;
        labelEvent[generatedLabelNumber].eventColor = color(random(100, 255), random(100, 255), random(100, 255));
        labelEvent[generatedLabelNumber].certainty = random(0, 100);
        labelEvent[generatedLabelNumber].duration = random(10, 90);
        

        int tempColor = colorScheme[PApplet.parseInt(random(0, colorScheme.length-1))][PApplet.parseInt(random(0, colorScheme[0].length-1))];
        labelEvent[generatedLabelNumber].eventColor = tempColor;
        
        lastGenLabel = millis();
        generatedLabelNumber++;
    }

    if(generatedLabelNumber >= (labelEvent.length-1)){
        generatedLabelNumber = 3;
    }
}

public void clearScreen(){
    // draw labelEvent circle
    fill(255);
    ellipse(mm2Pix(90), (float) (actHeight/2), mm2Pix(100), mm2Pix(100));
}


public void screenZero(){
    clearScreen();

    //draw events
    for(int i = 0; i < labelEvent.length; i++){
        labelEvent[i].drawLabelEvent();
        labelEvent[i].updateTime();
    }
}


public void screenOne(int pointerValue){
    clearScreen();

        // print("labelSelectorOccupied: ");
        // print(labelSelectorOccupied);
        // println();

    labelsDrawn = 0;
    for(int i = 0; i < labelSelec.length-1; i++){
        labelSelec[i].r = (int) red(colorScheme[currentSchemeNumber][i]);
        labelSelec[i].g = (int) green(colorScheme[currentSchemeNumber][i]);
        labelSelec[i].b = (int) blue(colorScheme[currentSchemeNumber][i]);
        labelSelec[i].drawLabelSelector();
        labelsDrawn = labelsDrawn + 1;


       /*if(0){ print("labelSelectorOccupied");
        print(labelSelectorOccupied);
        print("\t");
        print("labelselecNumber:");
        print(i);
        print("\t");
        print("certainty");
        print(labelSelec[i].certainty);
        print("\t");
        print("startpoint");
        print(labelSelec[i].startPoint);
        print("\t");
        print("endpoint");
        print(labelSelec[i].endPoint);
        println();
       }
       */
    }
    
    labelSelec[labelSelec.length-1].redrawLastSelector();
    labelSelec[labelSelec.length-1].drawLabelSelector();
    // print(labelSelec[labelSelec.length-1].startPoint);
    // print("-");
    // print(labelSelec[labelSelec.length-1].endPoint);
    // println();
    
    // delay(100);

    if(singleDPress(0)){        //animate the label being selected for (var) timeinterval of double press -> insert label as LabelEvent
       // println(findLabel());                     //note on what label the cursor is located
        int foundLabel = findLabel(pointerValue); 

        print("foundLabel: " + foundLabel);
        
        labelEvent[labelEvent.length-1].timeAgo = 0;
        labelEvent[labelEvent.length-1].eventColor = color(labelSelec[foundLabel].r, labelSelec[foundLabel].g, labelSelec[foundLabel].b);

        labelSelec[foundLabel].r = 0;               //change the color of the selected label as FB
        labelSelec[foundLabel].g = 0;
        labelSelec[foundLabel].b = 0;
        labelSelec[foundLabel].drawLabelSelector();

        goBack = true;
    }


    if(doubleDPress(0)){                            //redraw labelselector for next layer of control
            currentSchemeNumber++;
        if(currentSchemeNumber > colorScheme.length-1) currentSchemeNumber = 0;       //prevent outofboundexception
        goBack = false;
        labelSelectorOccupied = 0;
        for(int i = 0; i < (labelSelec.length-2); i++){
              labelSelec[i].redrawSelector();
        	  labelSelec[i].drawLabelSelector();
        }        
        labelSelec[labelSelec.length-1].redrawLastSelector();
        labelSelec[labelSelec.length-1].drawLabelSelector();
    }
    else{
        if(goBack && millis() - lastDPressMillis[0] > doublePressInterval){
            curScreen = 0; //return to main screen
            goBack = false;
        }
    }

}


public int findLabel(int pointerValue){
    for(int i = 0; i < labelSelec.length; i++){
        if((map(pointerValue, 0, 1023, 0, 360)-90) >= labelSelec[i].startPoint && (map(pointerValue, 0, 1023, 0, 360)-90) <= labelSelec[i].endPoint){
            return i;
        }
    }

    return 404;
}
//radians(map(pointerValue, 0, 1023, 360, 0))

//labelevents for logging waht events happend
class LabelEvent{
    //duration 0-180
    //certianty 0-100
    //timago 0-180
    //color hex

    float duration, certainty, timeAgo;
    int eventColor;
    long prevTimeUpdateMillis;

    LabelEvent (int newEventColor, float newDuration, float newTimeAgo, float newCertainty){
        duration = newDuration;
        certainty = newCertainty;
        eventColor = newEventColor;
        timeAgo = newTimeAgo;
        prevTimeUpdateMillis = millis();
    }
    public void drawLabelEvent(){
        int alpha = 0;
        if(timeAgo > (180+duration)){
            alpha = 0;
        }
        else{
            alpha = 255;
        }
        fill(eventColor, alpha);
        arc(mm2Pix(90), (actHeight/2), map(certainty, 0, 100, mm2Pix(40), mm2Pix(100)), map(certainty, 0, 100, mm2Pix(40), mm2Pix(100)),
        (radians(270-timeAgo)), radians((270-timeAgo)+duration));

    }
    public void updateTime(){
        if(millis() - prevTimeUpdateMillis > timeUpdateInterval){
            timeAgo = timeAgo + 0.1f;
            prevTimeUpdateMillis = millis();
        }
    }


    public boolean curOverEvent(int pointerValue){
        if(map(pointerValue, 0, 1023, 360, 0) >  (270-timeAgo) && map(pointerValue, 0, 1023, 360, 0) < (270-timeAgo)+duration){
            return true;
        }
        else{
            return false;
        }
    }

}

//labelselector
class LabelEventSelector{
    int g, b, r;
    int labelColor;
    float certainty;
    float startPoint, endPoint;



    LabelEventSelector(){

        if(labelSelectorOccupied == 180){
            println("labelselector full!");
        }
        else{
        startPoint = labelSelectorOccupied;
        certainty = random(0, (180-labelSelectorOccupied));
        endPoint = labelSelectorOccupied + certainty;
        labelSelectorOccupied = labelSelectorOccupied + certainty;
        }

       }

    public void redrawSelector(){
      r = PApplet.parseInt(red(colorScheme[currentSchemeNumber][labelsDrawn]));
      g = PApplet.parseInt(green(colorScheme[currentSchemeNumber][labelsDrawn]));
      b = PApplet.parseInt(blue(colorScheme[currentSchemeNumber][labelsDrawn]));

        if(labelSelectorOccupied == 180){
            println("labelselector full!");
        }
        else{
            startPoint = labelSelectorOccupied;
            certainty = random(0, (180-labelSelectorOccupied));
            endPoint = labelSelectorOccupied + certainty;
            labelSelectorOccupied = labelSelectorOccupied + certainty;

            r = (int) random(100, 255);
            g = (int) random(100, 255);
            b = (int) random(100, 255);
        }

    }

    public void redrawLastSelector(){
        //make the last one fill everything

        r = PApplet.parseInt(red(colorScheme[currentSchemeNumber][labelSelec.length]));
        g = PApplet.parseInt(green(colorScheme[currentSchemeNumber][labelSelec.length]));
        b = PApplet.parseInt(blue(colorScheme[currentSchemeNumber][labelSelec.length]));


        labelSelec[labelSelec.length-1].startPoint = labelSelectorOccupied;
        labelSelec[labelSelec.length-1].certainty = 180-labelSelectorOccupied;
        labelSelec[labelSelec.length-1].endPoint = labelSelectorOccupied + labelSelec[labelSelec.length-1].certainty;
      //  labelSelectorOccupied = labelSelectorOccupied + labelSelec[labelSelec.length-1].certainty;

        // r = (int) 255;
        // g = (int) 0;
        // b = (int) 0;

       // println("redrewlastselector endpoint: " + labelSelec[labelSelec.length-1].endPoint);
    }

    public void drawLabelSelector(){
        stroke(0);
        strokeWeight(4);
        fill(r, g, b, 255);
        arc(mm2Pix(90), (actHeight/2), mm2Pix(100), mm2Pix(100), radians(270-endPoint), radians(270-startPoint), PIE);

        noStroke();
    }
}

public void frontThree(int threePointer){

    int tempPointer = 0;

    
        tempPointer = PApplet.parseInt(map(threePointer, 0, 255, 0, 1023)) % 1023;
    

    // if(tempPointer > 510 && tempPointer < 750) tempPointer = 510;
    // if(tempPointer < 1023 && tempPointer > 750) tempPointer = 0;
    frontOne(tempPointer+270);
    pointerValue = tempPointer;         //assign to general pointervalue in datawindow

    //draw extra info
    fill(0);
    rect(width/2, 0, width/2, height);

    if(curScreen == 0){
    drawTime(tempPointer);
    }
    else if(curScreen ==1){
    drawLabelNames(tempPointer+270);
    }


}



public void drawTime(int tempPointer){
    fill(255);
    textSize(75);


    curHours = (hour() + PApplet.parseInt(map(tempPointer, 0, 1023, 0, -12))) % 24;

    String minuteString;
    minuteString = str(minute());
    if(minute() < 10) { minuteString = str(curMin) + "0";}



    
  pushMatrix();
  translate(2*(width/3)+100, height/2);
  rotate(3*(PI/2));
      textAlign(CENTER, CENTER);

  text(curHours + ":" + minuteString, 0, 0);
  popMatrix(); 
 
}



public void drawLabelNames(int pointer){
    String labelName = "no lablename found";


    for(int i = 0; i < labelSelec.length; i++){
        if((map(pointer, 0, 1023, 0, 360)-90) >= labelSelec[i].startPoint && (map(pointer, 0, 1023, 0, 360)-90) <= labelSelec[i].endPoint){
           labelName = labelNames[currentSchemeNumber][i];
        }
    }

      fill(255);
    textSize(75);


    pushMatrix();
    translate(2*(width/3)+120, height/2-50);
    rotate(3*(PI/2));
    textAlign(CENTER, CENTER);
    text(labelName, 0, 0);
    popMatrix(); 
}
int pointerSpeed = 50; //define the speeed of the pointer


int tempVal = 404;

public void frontTwo(int twoPointer){
    switch(curScreen) {
    	 case 0: 
            screenZero();
            if(singleDPress(0)){
                boolean wasOverLabel = false;
                for(int i = 0; i < labelEvent.length; i++){
                    if(curOverEventFrontTwo(i)){
                        wasOverLabel = true;
                        labelEvent[i].timeAgo = 360;
                    }
                }
                if(wasOverLabel == false){                                                           //pressed over nothing -> show labelselector
                    curScreen = 1;
                    currentSchemeNumber = 0;            //set colorscheme
                    labelSelectorOccupied = 0;
                    goBack = false;

                }
            }

                //draw extra info
            fill(0);
            rect(width/2, 0, width/2, height);

            drawTime(twoPointer);


            break;
         case 1:
            screenOneFrontTwo();
            // if(singleDPress(0)){
            //     labelSelectorOccupied = 0;
            // }
            if(tempVal != 404) println("r: " + labelSelec[tempVal].r);
              
            break;
    }



        //draw pointer
    fill(255, 0, 0);
    stroke(255);
    arc(mm2Pix(90), (actHeight/2), mm2Pix(100), mm2Pix(100), radians(map(eVal[0], 0, pointerSpeed, 360, 0)), (radians(map(eVal[0], 0, pointerSpeed, 360, 0)+radians(40))));
    noStroke();





    //draw time
  //  if(drawn == false){    drawTime(); drawn = true;}

}
boolean drawn = false;
int curHours;
int curMin;

public boolean curOverEventFrontTwo(int i){     
    if((map(eVal[0], 0, pointerSpeed, 360, 0)) >  (270-labelEvent[i].timeAgo) && (map(eVal[0], 0, pointerSpeed, 360, 0)) < (270-labelEvent[i].timeAgo)+labelEvent[i].duration){
            return true;
        }
        else{
            return false;
        }
    }








public void screenOneFrontTwo(){
    clearScreen();

    labelsDrawn = 0;
    for(int i = 0; i < labelSelec.length; i++){
        if(i != tempVal){
        labelSelec[i].r = (int) red(colorScheme[currentSchemeNumber][i]);
        labelSelec[i].g = (int) green(colorScheme[currentSchemeNumber][i]);
        labelSelec[i].b = (int) blue(colorScheme[currentSchemeNumber][i]);
        labelSelec[i].drawLabelSelector();
        }
        labelsDrawn = labelsDrawn + 1;
    }
        labelSelec[labelSelec.length-1].redrawLastSelector();
        labelSelec[labelSelec.length-1].drawLabelSelector();

    if(singleDPress(0)){        //animate the label being selected for (var) timeinterval of double press -> insert label as LabelEvent
       // println(findLabel());                     //note on what label the cursor is located
        int foundLabel = findLabelFrontTwo(); 

        print("foundLabel: " + foundLabel);
        tempVal = foundLabel;
        
        labelEvent[labelEvent.length-1].timeAgo = 0;
        labelEvent[labelEvent.length-1].eventColor = color(labelSelec[foundLabel].r, labelSelec[foundLabel].g, labelSelec[foundLabel].b);

        labelSelec[foundLabel].r = 0;               //change the color of the selected label as FB
        labelSelec[foundLabel].g = 0;
        labelSelec[foundLabel].b = 0;
        labelSelec[foundLabel].drawLabelSelector();


        goBack = true;
    }


    if(doubleDPress(0)){                            //redraw labelselector for next layer of control
        goBack = false;
        labelSelectorOccupied = 0;
        currentSchemeNumber = currentSchemeNumber + 1;          //go to the next schemenumber
        for(int i = 0; i < (labelSelec.length-2); i++){
              labelSelec[i].redrawSelector();
        	  labelSelec[i].drawLabelSelector();
        }        
        labelSelec[labelSelec.length-1].redrawLastSelector();
        labelSelec[labelSelec.length-1].drawLabelSelector();
    }
    else{
        if(goBack && millis() - lastDPressMillis[0] > doublePressInterval){
            curScreen = 0; //return to main screen
            goBack = false;
        }
    }

}


public int findLabelFrontTwo(){


    for(int i = 0; i < labelSelec.length; i++){
        print("labelselec: "+ i);
        print("\t");
        print(map(eVal[0], 0, pointerSpeed, 360, 0)-90);
        print("\t");
        print(labelSelec[i].startPoint + "->" + labelSelec[i].endPoint);
        println();

            //map - 90
        if((map(eVal[0], 0, pointerSpeed, 360, 0)-90) >= labelSelec[i].startPoint && (map(eVal[0], 0, pointerSpeed, 360, 0)-90) <= labelSelec[i].endPoint){
            return i;
        }
    }


    return 404;
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Interface_setup_processing" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
