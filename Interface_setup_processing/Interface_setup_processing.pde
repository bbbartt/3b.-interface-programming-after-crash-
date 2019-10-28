import processing.serial.*;



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








void settings(){
    smooth();
    fullScreen(3); //3

}

void setup(){
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
void draw(){
    // if(detectedFront != prevDetectedFront){
    //     curScreen = 0;
    // }
    // prevDetectedFront = detectedFront;

    if(detectedFront == 1){
     frontOne();
    }
    else if(detectedFront == 2){
     frontTwo();
    }


}


float mm2Pix(float mm){
    return mm*9.2;
}




boolean singleDPress(int pressPin){
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

boolean doubleDPress(int pressPin){
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


