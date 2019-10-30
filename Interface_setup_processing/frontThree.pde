void frontThree(int threePointer){

    int tempPointer = 0;

    
        tempPointer = int(map(threePointer, 0, 255, 0, 1023)) % 1023;
    

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



void drawTime(int tempPointer){
    fill(255);
    textSize(75);


    curHours = (hour() + int(map(tempPointer, 0, 1023, 0, -12))) % 24;

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



void drawLabelNames(int pointer){
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