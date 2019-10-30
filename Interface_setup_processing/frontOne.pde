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
    new LabelEvent(#00FF00, 10, 10, 50),
    new LabelEvent(#0000FF, 5, 90, 40),
    new LabelEvent(#0000FF, 20, 150, 90),
    new LabelEvent(#000000, 20, 360, 100),            
    new LabelEvent(#000000, 20, 360, 100),            
    new LabelEvent(#000000, 20, 360, 100),            
    new LabelEvent(#000000, 20, 360, 100),            
    new LabelEvent(#000000, 20, 360, 100),            
    new LabelEvent(#000000, 20, 360, 100),            
    new LabelEvent(#000000, 20, 360, 100),            
    new LabelEvent(#000000, 20, 360, 100),            

    new LabelEvent(#000000, 20, 360, 100),            //not visible because of timeAgo
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

void frontOne(int pointerValue){


    
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


void labelGenerator(){
    if(millis() - lastGenLabel > generatorInterval){
        generatorInterval = (long) random(minGenerateLabelDelay, maxGenerateLabelDelay);
        labelEvent[generatedLabelNumber].timeAgo = 0;
        labelEvent[generatedLabelNumber].eventColor = color(random(100, 255), random(100, 255), random(100, 255));
        labelEvent[generatedLabelNumber].certainty = random(0, 100);
        labelEvent[generatedLabelNumber].duration = random(10, 90);
        

        color tempColor = colorScheme[int(random(0, colorScheme.length-1))][int(random(0, colorScheme[0].length-1))];
        labelEvent[generatedLabelNumber].eventColor = tempColor;
        
        lastGenLabel = millis();
        generatedLabelNumber++;
    }

    if(generatedLabelNumber >= (labelEvent.length-1)){
        generatedLabelNumber = 3;
    }
}

void clearScreen(){
    // draw labelEvent circle
    fill(255);
    ellipse(mm2Pix(90), (float) (actHeight/2), mm2Pix(100), mm2Pix(100));
}


void screenZero(){
    clearScreen();

    //draw events
    for(int i = 0; i < labelEvent.length; i++){
        labelEvent[i].drawLabelEvent();
        labelEvent[i].updateTime();
    }
}


void screenOne(int pointerValue){
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


int findLabel(int pointerValue){
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
    color eventColor;
    long prevTimeUpdateMillis;

    LabelEvent (color newEventColor, float newDuration, float newTimeAgo, float newCertainty){
        duration = newDuration;
        certainty = newCertainty;
        eventColor = newEventColor;
        timeAgo = newTimeAgo;
        prevTimeUpdateMillis = millis();
    }
    void drawLabelEvent(){
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
    void updateTime(){
        if(millis() - prevTimeUpdateMillis > timeUpdateInterval){
            timeAgo = timeAgo + 0.1;
            prevTimeUpdateMillis = millis();
        }
    }


    boolean curOverEvent(int pointerValue){
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
    color labelColor;
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

    void redrawSelector(){
      r = int(red(colorScheme[currentSchemeNumber][labelsDrawn]));
      g = int(green(colorScheme[currentSchemeNumber][labelsDrawn]));
      b = int(blue(colorScheme[currentSchemeNumber][labelsDrawn]));

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

    void redrawLastSelector(){
        //make the last one fill everything

        r = int(red(colorScheme[currentSchemeNumber][labelSelec.length]));
        g = int(green(colorScheme[currentSchemeNumber][labelSelec.length]));
        b = int(blue(colorScheme[currentSchemeNumber][labelSelec.length]));


        labelSelec[labelSelec.length-1].startPoint = labelSelectorOccupied;
        labelSelec[labelSelec.length-1].certainty = 180-labelSelectorOccupied;
        labelSelec[labelSelec.length-1].endPoint = labelSelectorOccupied + labelSelec[labelSelec.length-1].certainty;
      //  labelSelectorOccupied = labelSelectorOccupied + labelSelec[labelSelec.length-1].certainty;

        // r = (int) 255;
        // g = (int) 0;
        // b = (int) 0;

       // println("redrewlastselector endpoint: " + labelSelec[labelSelec.length-1].endPoint);
    }

    void drawLabelSelector(){
        stroke(0);
        strokeWeight(4);
        fill(r, g, b, 255);
        arc(mm2Pix(90), (actHeight/2), mm2Pix(100), mm2Pix(100), radians(270-endPoint), radians(270-startPoint), PIE);

        noStroke();
    }
}

