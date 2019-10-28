#include <Arduino.h>

#define digPins 7
#define anaPins 7

#define extraVarLength 7


int detectedFront = 0;

int extraVar[extraVarLength] = {};


void frontDetection();
void serialPrinter();

////////////////////////////////////////// FRONT TWO
void PinA();
void PinB();

static int pinA = 2; // Our first hardware interrupt pin is digital pin 2
static int pinB = 3; // Our second hardware interrupt pin is digital pin 3
volatile byte aFlag = 0; // let's us know when we're expecting a rising edge on pinA to signal that the encoder has arrived at a detent
volatile byte bFlag = 0; // let's us know when we're expecting a rising edge on pinB to signal that the encoder has arrived at a detent (opposite direction to when aFlag is set)
volatile byte encoderPos = 0; //this variable stores our current value of encoder position. Change to int or uin16_t instead of byte if you want to record a larger range than 0-255
volatile byte oldEncPos = 0; //stores the last encoder position value so we can compare to the current reading and see if it has changed (so we know when to print to the serial monitor)
volatile byte reading = 0; //somewhere to store the direct values we read from our interrupt pins before checking to see if we have moved a whole detent
////////////////////////////////////////// FRONT TWO







void setup() {
  Serial.begin(115200);

  for(int i = 0; i <= digPins; i++){
    pinMode(i, INPUT);
  }

  for(int i = 0; i < extraVarLength; i++){
    extraVar[i] = 404;
  }

  detectedFront = 0;

  //Serial.println("--------------------- STARUTP ---------------------");

  ////////////////// FRONT TWO 
  pinMode(pinA, INPUT_PULLUP); // set pinA as an input, pulled HIGH to the logic voltage (5V or 3.3V for most cases)
  pinMode(pinB, INPUT_PULLUP); // set pinB as an input, pulled HIGH to the logic voltage (5V or 3.3V for most cases)
  attachInterrupt(0, PinA,RISING); // set an interrupt on PinA, looking for a rising edge signal and executing the "PinA" Interrupt Service Routine (below)
  attachInterrupt(1, PinB,RISING); // set an interrupt on PinB, looking for a rising edge signal and executing the "PinB" Interrupt Service Routine (below)
  //////////////////// FRONT TWO

}

void loop() {

  frontDetection();

  serialPrinter();

 delay(50);
  
}

void serialPrinter(){
  //print digital pins
  for(int i = 0; i < digPins; i++){
    if(i != 0) Serial.print(",");
    Serial.print(digitalRead(i));
  }
  //print analogs
  for(int i = 0; i < anaPins; i++){
    Serial.print(",");
    Serial.print((analogRead(i)));
  
  }
  for(int i = 0; i < extraVarLength; i++){
    Serial.print(",");
    Serial.print(extraVar[i]);
  }
  Serial.print(",");
  Serial.print(detectedFront);      //print detectedfront
  Serial.print(",");

  Serial.println();
}


void frontDetection(){
      int analogValue = analogRead(0);
      //comment this for real values, use this for debug
      // analogValue = 60;
    if(analogValue < 35 && analogValue > 20){
       detectedFront = 1;
      }
    else if(analogValue > 1020){
    //  Serial.println("Got here!");
      detectedFront = 2;
      
      extraVar[0] = encoderPos;     //we allocate the rotary encoder value (retrieved from interrupt functions PinA and PinB) to an extra value < usable in processing
    }
    else{
      detectedFront = 0;
    }

}




////////////////// FRONT TWO 
void PinA(){

  if(detectedFront == 2){
    cli(); //stop interrupts happening before we read pin values
    reading = PIND & 0xC; // read all eight pin values then strip away all but pinA and pinB's values
    if(reading == B00001100 && aFlag) { //check that we have both pins at detent (HIGH) and that we are expecting detent on this pin's rising edge
      encoderPos --; //decrement the encoder's position count
      bFlag = 0; //reset flags for the next turn
      aFlag = 0; //reset flags for the next turn
    }
    else if (reading == B00000100) bFlag = 1; //signal that we're expecting pinB to signal the transition to detent from free rotation
    sei(); //restart interrupts
  }
}
void PinB(){
  if(detectedFront == 2){
    cli(); //stop interrupts happening before we read pin values
    reading = PIND & 0xC; //read all eight pin values then strip away all but pinA and pinB's values
    if (reading == B00001100 && bFlag) { //check that we have both pins at detent (HIGH) and that we are expecting detent on this pin's rising edge
      encoderPos ++; //increment the encoder's position count
      bFlag = 0; //reset flags for the next turn
      aFlag = 0; //reset flags for the next turn
    }
    else if (reading == B00001000) aFlag = 1; //signal that we're expecting pinA to signal the transition to detent from free rotation
    sei(); //restart interrupts
  }
}
 ////////////////// FRONT TWO 
