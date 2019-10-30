int pointerSpeed = 50; //define the speeed of the pointer


int tempVal = 404;

void frontTwo(int twoPointer){
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

boolean curOverEventFrontTwo(int i){     
    if((map(eVal[0], 0, pointerSpeed, 360, 0)) >  (270-labelEvent[i].timeAgo) && (map(eVal[0], 0, pointerSpeed, 360, 0)) < (270-labelEvent[i].timeAgo)+labelEvent[i].duration){
            return true;
        }
        else{
            return false;
        }
    }








void screenOneFrontTwo(){
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


int findLabelFrontTwo(){


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