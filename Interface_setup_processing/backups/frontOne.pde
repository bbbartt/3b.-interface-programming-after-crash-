//color hex
//duration 0-180
//timago 0-180
//certianty 0-100
LabelEvent cat1 = new LabelEvent(#00FF00, 10, 10, 50);
LabelEvent tv1 = new LabelEvent(#0000FF, 5, 90, 40);
LabelEvent tv2 = new LabelEvent(#0000FF, 20, 150, 90);
LabelEvent addLabel = new LabelEvent(#000000, 20, 360, 100);            //not visible

LabelEventSelector[] labelSelec = new LabelEventSelector[]{
new LabelEventSelector(),
new LabelEventSelector(),
new LabelEventSelector(),
new LabelEventSelector(),
};


int curScreen = 0;

float labelSelectorOccupied = 0;

boolean goBack = false;


void frontOne(){
    switch(curScreen) {
    	 case 0: 
            screenZero();

            //chekc if cursor is on top of event
            //print(cat1.curOverEvent());
            // print("\t");
            // print(tv1.curOverEvent());
            // print("\t");
            // print(tv2.curOverEvent());
            // print("\t");
            // print(addLabel.curOverEvent());
            // print("\t");
         //   println();



            if(singleDPress(0)){
                if(cat1.curOverEvent()) cat1.timeAgo = 360;                     //when pressed over label, remove label
                else if(tv1.curOverEvent()) tv1.timeAgo = 360;
                else if(tv2.curOverEvent()) tv2.timeAgo = 360;
                else if(addLabel.curOverEvent()) addLabel.timeAgo = 360;
                else{                                                           //pressed over nothing -> show labelselector
                curScreen = 1;
                labelSelectorOccupied = 0;
                for(int i = 0; i < 4; i++){  
                    labelSelec[i].redrawSelector(); 
                }               
                goBack = false;
                }
            }
            break;
         case 1:
            screenOne();
            if(singleDPress(0)){
                labelSelectorOccupied = 0;
            }         
            break;
    }


    //draw pointer
    fill(255, 0, 0);
    stroke(255);
    arc(mm2Pix(90), (actHeight/2), mm2Pix(100), mm2Pix(100), radians(map(aPin[1], 0, 1023, 360, 0)), (radians(map(aPin[1], 0, 1023, 360, 0)+radians(40))));
    noStroke();
}


void clearScreen(){
    // draw labelEvent circle
    fill(255);
    ellipse(mm2Pix(90), (float) (actHeight/2), mm2Pix(100), mm2Pix(100));
}


void screenZero(){
    clearScreen();


    //draw events
    cat1.drawLabelEvent();
    tv1.drawLabelEvent();
    tv2.drawLabelEvent();
    addLabel.drawLabelEvent();

    //update time
    cat1.updateTime();
    tv1.updateTime();
    tv2.updateTime();
    addLabel.updateTime();
}


void screenOne(){
    clearScreen();

    for(int i = 0; i < 4; i++){
        labelSelec[i].drawLabelSelector();
    }

    if(singleDPress(0)){        //animate the label being selected for (var) timeinterval of double press -> insert label as LabelEvent
       // println(findLabel());                     //note on what label the cursor is located
        int foundLabel = findLabel(); 
        
        addLabel.timeAgo = 0;
        addLabel.eventColor = color(labelSelec[foundLabel].r, labelSelec[foundLabel].g, labelSelec[foundLabel].b);

        labelSelec[foundLabel].r = 0;               //change the color of the selected label as FB
        labelSelec[foundLabel].g = 0;
        labelSelec[foundLabel].b = 0;
        labelSelec[foundLabel].drawLabelSelector();

        goBack = true;
    }


    if(doubleDPress(0)){                            //redraw labelselector for next layer of control
        goBack = false;
        labelSelectorOccupied = 0;
        for(int i = 0; i < 3; i++){
        labelSelec[i].redrawSelector();
        labelSelec[i].drawLabelSelector();
        }        
        labelSelec[3].redrawLastSelector();
    }
    else{
        if(goBack && millis() - lastDPressMillis[0] > doublePressInterval){
            curScreen = 0; //return to main screen
            goBack = false;
        }
    }

}


int findLabel(){

    // for(int i = 0; i < 4; i++){
    //     print(aPin[1]);
    //     print("\t");        
    //     print((map(aPin[1], 0, 1023, 0, 360)-90));
    //     print("\t");
    //     print(i);
    //     print("\t");
    //     print(labelSelec[i].startPoint);
    //     print("\t");
    //     print(labelSelec[i].endPoint);
    //     println();
    // }


    for(int i = 0; i < 4; i++){
        if((map(aPin[1], 0, 1023, 0, 360)-90) >= labelSelec[i].startPoint && (map(aPin[1], 0, 1023, 0, 360)-90) <= labelSelec[i].endPoint){
            return i;
        }
    }

    return 20;

}



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


    boolean curOverEvent(){
        if(map(aPin[1], 0, 1023, 360, 0) >  (270-timeAgo) && map(aPin[1], 0, 1023, 360, 0) < (270-timeAgo)+duration){
            return true;
        }
        else{
            return false;
        }
    }

}

class LabelEventSelector{
    int r, g, b;
    float certainty;
    float startPoint, endPoint;

    LabelEventSelector(){
        startPoint = labelSelectorOccupied;
        certainty = random(0, (180-labelSelectorOccupied));
        endPoint = labelSelectorOccupied + certainty;
        labelSelectorOccupied = labelSelectorOccupied + certainty;

        r = (int) random(100, 255);
        g = (int) random(100, 255);
        b = (int) random(100, 255);
    }

    void redrawSelector(){
        startPoint = labelSelectorOccupied;
        certainty = random(0, (180-labelSelectorOccupied));
        endPoint = labelSelectorOccupied + certainty;
        labelSelectorOccupied = labelSelectorOccupied + certainty;

        r = (int) random(100, 255);
        g = (int) random(100, 255);
        b = (int) random(100, 255);
    }

    void redrawLastSelector(){
        //make the last one fill everything
        labelSelec[3].startPoint = labelSelectorOccupied;
        labelSelec[3].certainty = 180-labelSelectorOccupied;
        labelSelec[3].endPoint = labelSelectorOccupied + labelSelec[3].certainty;
        labelSelectorOccupied = labelSelectorOccupied + labelSelec[3].certainty;

        r = (int) random(100, 255);
        g = (int) random(100, 255);
        b = (int) random(100, 255);
    }

    void drawLabelSelector(){
        fill(r, g, b, 255);
        arc(mm2Pix(90), (actHeight/2), mm2Pix(100), mm2Pix(100), radians(270-endPoint), radians(270-startPoint));
    }
}


