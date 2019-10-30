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
        detectedFront = int(splitVal[digPins+anaPins+extraVals]);
        text(detectedFront, 350, 25);
    }


    text("curScreen", 200, 50);
    text(curScreen, 350, 50);

    text("curSchemeNumb", 200, 75);
    text(currentSchemeNumber, 350, 75);

    text("labelselecocc", 200, 100);
    text(labelSelectorOccupied, 350, 100);
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