final int SIZE_CONSTANT = 90;  //<>//

final int DEFAULT_TURNING = 324;
final int DEFAULT_CROSSING = 140;

boolean colorActive = true;

boolean turningTextboxActive = false;

boolean crossingTextboxActive = false;

int textboxErrorTimer = 0;

int offset = 0;

StrandedCellGeneration zero = new StrandedCellGeneration((width*16)/37, (height/6) + 10*90, 10);

StrandedCellAutomata SCA = new StrandedCellAutomata(zero);

RuleDisplay ruleGui = new RuleDisplay();


void setup() {
  fullScreen(2);
  //println("resolution is " + width + "x" + height);
  cursor();
  background(220);
  stroke(0);
  strokeWeight(2.5);
  fill(255);

  zero.xPos = (width*4)/37;
  zero.yPos = (5*height/6);

  println("x = " + zero.xPos);
  println("y = " + zero.yPos);

  int contrast = 0;

  color red = color(255, contrast, contrast);
  color yellow = color(255, 255, contrast);
  color green = color(contrast, 255, contrast);
  color teal = color(contrast, 255, 255);
  color darkBlue = color(contrast, contrast, 255);
  color violet = color(255, contrast, 255);



  color[] colorArray = new color[zero.numCells * 2];  //create array of colors to assign to each strand in zeroth generation

  float lerpInterval = (zero.numCells * 2)/5.0;

  int lerpIndex = 0;

  int lerpNum = 0;
  for (int i = 0; i<zero.numCells*2; i++) {
    switch(lerpNum) {
    case 3:
      colorArray[i] = lerpColor(red, yellow, lerpIndex/(lerpInterval));
      break;
    case 4:
      colorArray[i] = lerpColor(yellow, green, lerpIndex/(lerpInterval));
      break;
    case 0:
      colorArray[i] = lerpColor(green, teal, lerpIndex/(lerpInterval));
      break;
    case 1:
      colorArray[i] = lerpColor(teal, darkBlue, lerpIndex/(lerpInterval));
      break;
    case 2:
      colorArray[i] = lerpColor(darkBlue, violet, lerpIndex/(lerpInterval));
      break;
    }
    //lerpIndex++;
    //if (lerpIndex == lerpInterval) {
    //  lerpIndex = 0;
    //  lerpNum++;
    //}

    lerpNum++;
    if (lerpNum == 5) {
      lerpNum = 0;
      lerpIndex++;
    }
  }

  int index = 0;
  for (StrandedCell c : zero.cells) {
    c.setColors(colorArray[index], colorArray[index+1]);
    index+=2;
  }


  //noLoop();

  //manual testing of rulesets & sample outputs
  // Ruleset testingSet = new Ruleset(324, 6);
  //println(calcNextCell("33","30", testingSet.turning, testingSet.crossing));

  ruleGui.cellSize = width/24;

  int centerX = 7*width/12;

  int centerY = height/6;

  //bounding box
  fill(200);
  rect(centerX, centerY, 7*width/18, 2*height/3);
  fill(255);
  //top left output cell testing
  //rect(centerX+(width/16), centerY +(height/9),width/24,width/24);
  centerX = centerX+(width/16);
  centerY = centerY +(height/12);

  int origX = centerX;
  int origY = centerY;

  int count = 8;
  for (int i = 0; i<3; i++) {
    for (int j = 0; j<3; j++)
    {
      ruleGui.coordinateList.addFirst(new Point(centerX, centerY));
      fill(0);
      //text(count, centerX, centerY);
      fill(255);
      count--;
      centerX = centerX + (width/12) + (width/36);
    }
    centerX = origX;
    centerY = centerY + (width/12) + (width/36);
  }
  centerY = origY;

  //ruleGui.debugCoords();
}
int ruleTester = 0;

void draw() {

  if (SCA.clearNeeded)
  {
    fill(220);
    noStroke();
    rect(0, 0, (width/2)-39, height);
    stroke(0);
    fill(255);
    SCA.clearNeeded = false;
  }

  fill(0);
  SCA.drawRulesets(offset);
  fill(220);
  if (ruleGui.turningActive) {
    ruleGui.drawTurningDisplay();
  } else {
    ruleGui.drawCrossingDisplay();
  }

  for (StrandedCellGeneration g : SCA.generationList) {
    g.drawGeneration(colorActive, offset);
  }

  if (textboxErrorTimer > 0) {
    textSize(24);
    fill(#9E0A0A);
    text("Error: Rule specified does not match bounds (0 - 511)", 7 * width/12, 7 * height/8);
    fill(0);
    textboxErrorTimer--;
    if (textboxErrorTimer == 0) {
      noStroke();
      fill(220);
      rect(7 * width/12, 6.8 * height/8, textWidth("Error: Rule specified does not match bounds (0 - 511)"), 48);
      fill(255);
      stroke(0);
    }
  }
}

void mouseClicked() {

  //in order to have "click anywhere" override any other click actions, this goes first
  //executes the same actions as enter/return in writing the ruleset from the active textbox to the corresponding rule, and displaying errors if input not supported
  if (turningTextboxActive || crossingTextboxActive) {
    //attempt to write current textbox input to ruleset
    int newRule = -1;
    if (ruleGui.textbox.length() != 0)
      newRule = Integer.parseInt(ruleGui.textbox);

    println("attempting to write rule #" + newRule);
    if (newRule > 511) {
      textboxErrorTimer = 169;
    } else {
      if (newRule == -1) {
        ruleGui.textbox = "";
        turningTextboxActive = false;
        crossingTextboxActive = false;
      } else
        if (turningTextboxActive) {
          int currentCrossing = ruleGui.currentRuleset.crossingNum;
          ruleGui.currentRuleset.setRules(newRule, currentCrossing);
          turningTextboxActive = false; 
          ruleGui.textbox = ""; //clear textbox buffer
        } else {
          int currentTurning = ruleGui.currentRuleset.turningNum;
          ruleGui.currentRuleset.setRules(currentTurning, newRule);
          crossingTextboxActive = false;
          ruleGui.textbox = "";
        }
    }

    return;
  }


  //"buttons" for manipulating zeroth generation
  if (mouseY >= zero.yPos && mouseY <= zero.yPos + zero.cellSize) {
    for (int i = 0; i<zero.cells.size(); i++) {
      int leftCellBoundary = zero.xPos + zero.cells.get(i).deltaX;
      int rightCellBoundary = leftCellBoundary + zero.cellSize;

      if (mouseX > leftCellBoundary && mouseX < rightCellBoundary && mouseButton == LEFT) {
        zero.cells.get(i).cycleStatus();
      } else {
        if (mouseX > leftCellBoundary && mouseX < rightCellBoundary && mouseButton == RIGHT) {
          for (int j = 0; j<7; j++)
            zero.cells.get(i).cycleStatus();
        } else {
          if (mouseX > leftCellBoundary && mouseX < rightCellBoundary && mouseButton == CENTER) {
            zero.cells.get(i).status = CellStatus.noStrand;
          }
        }
      }
    }
  }

  //"buttons" for rule manipulation

  if (!turningTextboxActive && !crossingTextboxActive)
    for (int i = 0; i<9; i++) {
      Point pt = ruleGui.coordinateList.get(i);
      if (checkCellRegion(pt, ruleGui.cellSize)) {
        if (ruleGui.turningActive) { //TURNING RULE

          if (!ruleGui.currentRuleset.turning[i]) { //Selected bit is OFF and we toggle it ON
            ruleGui.currentRuleset.turning[i] = true;
            ruleGui.currentRuleset.updateNumbers();
          } else {  //Selected bit is ON and we toggle it OFF
            ruleGui.currentRuleset.turning[i] = false;
            ruleGui.currentRuleset.updateNumbers();
          }
        } else { //CROSSING RULE
          if (!ruleGui.currentRuleset.crossing[i]) {  //Selected bit is OFF and we toggle it ON
            ruleGui.currentRuleset.crossing[i] = true;
            ruleGui.currentRuleset.updateNumbers();
          } else {  //Selected bit is ON and we toggle it OFF
            ruleGui.currentRuleset.crossing[i] = false;
            ruleGui.currentRuleset.updateNumbers();
          }
        }
        //ruleGui.currentRuleset.printRules();
      }
    }


  //"buttons" for the turning/crossing tabs

  int tabX = ruleGui.coordinateList.get(8).x - width/18;
  int tabY = ruleGui.coordinateList.get(8).y - height/12;

  if (mouseX > tabX + width/32 && mouseX < tabX + width/32 + width/16 && mouseY<tabY && mouseY>tabY - width/48 && !ruleGui.turningActive ) {
    ruleGui.turningActive = true;
  } else {
    //if turning tab is already active and is clicked a second time
    if (mouseX > tabX + width/32 && mouseX < tabX + width/32 + width/16 && mouseY<tabY && mouseY>tabY - width/48 && ruleGui.turningActive) {
      turningTextboxActive = true;
    }
  }

  tabX += width/8;

  if (mouseX > tabX + width/32 && mouseX < tabX + width/32 + width/16  && mouseY<tabY && mouseY>tabY - width/48 && ruleGui.turningActive && !turningTextboxActive) {
    ruleGui.turningActive = false;
  } else {
    //same as turning version, if tab is already active and is clicked a second time, textbox is activated
    if (mouseX > tabX + width/32 && mouseX < tabX + width/32 + width/16  && mouseY<tabY && mouseY>tabY - width/48 && !ruleGui.turningActive) {
      crossingTextboxActive = true;
    }
  }
}

void mouseWheel(MouseEvent event) {
  int e = event.getCount(); //gets the scroll amount (an int usually around -4 to 4)

  //to make holding shift scroll faster
  if (keyPressed == true)
    if (key == CODED)
      if (keyCode == SHIFT) {
        offset += e * 45;
      }

  offset += e * 15; //default scroll speed booster

  if (offset>0) {
    offset = 0; //no reason to scroll down since the SCA grows from bottom to top, so you can't scroll into positive(downwards) offset territory
  } 
  SCA.clearNeeded = true; //boolean originally made for the resetting feature, but setting this to true will initiate a redraw of the automata, clearing the previous draw
}

void keyPressed() {

  //textbox input, overrides all other keystrokes
  if (turningTextboxActive || crossingTextboxActive) {
    if (key == BACKSPACE) {
      if (ruleGui.textbox.length() > 0)
        ruleGui.textbox = ruleGui.textbox.substring(0, ruleGui.textbox.length()-1); //deletes the last character of the textbox if there is one
    } else {
      //max length of rules is 3 so the reader will ignore any inputs after the textbox has already reached capacity
      if (ruleGui.textbox.length()< 3) {
        if (Character.isDigit(key)) //only takes numbers (0-9)
          ruleGui.textbox += key; //appends number to textbox string
      }
    }
    //for cross-compatibility 
    if (key == ENTER || key == RETURN ) {
      //attempt to write current textbox input to ruleset
      int newRule = -1;
      if (ruleGui.textbox.length() != 0)
        newRule = Integer.parseInt(ruleGui.textbox); //reads the string in the textbox into a decimal number

      //println("attempting to write rule #" + newRule);
      if (newRule > 511) {
        textboxErrorTimer = 169; //adjust for a longer/shorter error message display time
      } else {
        //default case when unable to parse textbox(since it was empty), exits textbox mode without modifying any of the rules
        if (newRule == -1) {
          ruleGui.textbox = "";
          turningTextboxActive = false;
          crossingTextboxActive = false;
        } else
          //modifies turning rule and keeps crossing rule constant
          if (turningTextboxActive) {
            int currentCrossing = ruleGui.currentRuleset.crossingNum;
            ruleGui.currentRuleset.setRules(newRule, currentCrossing);
            turningTextboxActive = false; 
            ruleGui.textbox = ""; //clear textbox buffer
          } else {
            //does the opposite of the above code
            int currentTurning = ruleGui.currentRuleset.turningNum;
            ruleGui.currentRuleset.setRules(currentTurning, newRule);
            crossingTextboxActive = false;
            ruleGui.textbox = "";
          }
      }
    }
  } else {


    if (key == ' ') {
      SCA.growthCycle();
    }

    // print debug information
    if (key == 'p') {
      //SCA.pollGenerations();
      //ruleGui.currentRuleset.printRules();
    }

    //reset automata
    if (key == 'r') {
      SCA = new StrandedCellAutomata(zero);
      offset = 0;
    }

    //toggle color
    if (key == 'c') {
      colorActive = !colorActive;
    }
    
    if (key == 'l') {
      Ruleset updatedRuleset = new Ruleset(ruleGui.currentRuleset.turningNum, ruleGui.currentRuleset.crossingNum);

      if (!SCA.timeVaryingEnabled)
        zero.updateCellRulesets(updatedRuleset);
      else
      {

        SCA.timeRules.addLast(updatedRuleset);
        zero.updateCellRulesets(SCA.timeRules.get(0));
      }
    }

    if (key == 'm') {
      ruleGui.turningActive = !ruleGui.turningActive;
    }
    if (key == 't') {
      SCA.timeVaryingEnabled = !SCA.timeVaryingEnabled;

      if (SCA.timeVaryingEnabled) {
        println("Time Varying Rulesets Enabled");
        SCA.timeRuleIndex = 0;
        SCA.timeRules = new LinkedList<Ruleset>();
      } else {
        println("Time Varying Rulesets Disabled");
        SCA.timeRuleIndex = 0;
        SCA.timeRules = new LinkedList<Ruleset>();
      }
    }

    if (key == 'q' && !SCA.timeRules.isEmpty()) {
      print("\nCurrent Time-Varying Rules: ");
      for (int i = 0; i<SCA.timeRules.size(); i++) {
        print(" (" + SCA.timeRules.get(i).turningNum + ", " + SCA.timeRules.get(i).crossingNum + "), ");
      }
      println("");
    }
  }
}

/*
*  Method to draw a stranded cell, given the coordinates of its upper left corner, what type of cell it is, and its size
 * 
 */
public void drawStrands(int xPos, int yPos, CellStatus status, int cellSize) {
  fill(255);
  rect(xPos, yPos, cellSize, cellSize);
  fill(180);
  switch(status) {

  case noStrand:
    //do nothing
    break;
  case straightLeft:
    rect(xPos+(cellSize/6), yPos, (cellSize/6), cellSize);
    break;
  case straightRight:
    rect(xPos+(4*cellSize/6), yPos, (cellSize/6), cellSize);
    break;
  case leftRight:
    rect(xPos+(cellSize/6), yPos, (cellSize/6), cellSize);
    rect(xPos+(4*cellSize/6), yPos, (cellSize/6), cellSize);
    break;
  case rightwardSlant:
    quad(xPos+(cellSize/6), yPos+cellSize, xPos+(2*cellSize/6), yPos+cellSize, xPos+(5*cellSize/6), yPos, xPos+(4*cellSize/6), yPos);
    break;
  case leftwardSlant:
    quad(xPos+(cellSize/6), yPos, xPos+(2*cellSize/6), yPos, xPos+(5*cellSize/6), yPos+cellSize, xPos+(4*cellSize/6), yPos+cellSize);
    break;
  case zCross:
    quad(xPos+(cellSize/6), yPos, xPos+(2*cellSize/6), yPos, xPos+(5*cellSize/6), yPos+cellSize, xPos+(4*cellSize/6), yPos+cellSize);//leftward slant
    quad(xPos+(cellSize/6), yPos+cellSize, xPos+(2*cellSize/6), yPos+cellSize, xPos+(5*cellSize/6), yPos, xPos+(4*cellSize/6), yPos); //rightward slant ON TOP of previously drawn leftward slant
    break;
  case sCross:
    quad(xPos+(cellSize/6), yPos+cellSize, xPos+(2*cellSize/6), yPos+cellSize, xPos+(5*cellSize/6), yPos, xPos+(4*cellSize/6), yPos); //rightward slant
    quad(xPos+(cellSize/6), yPos, xPos+(2*cellSize/6), yPos, xPos+(5*cellSize/6), yPos+cellSize, xPos+(4*cellSize/6), yPos+cellSize); //leftward slant ON TOP of previously drawn rightward slant
    break;
  }
}

/*
*  Method to draw a *colored* stranded cell, given the coordinates of its upper left corner, what type of cell it is, its size, and colors of its left and right input strands
 * 
 */
public void drawStrands(int xPos, int yPos, CellStatus status, int cellSize, color leftInput, color rightInput) {
  fill(255);
  rect(xPos, yPos, cellSize, cellSize);

  switch(status) {

  case noStrand:
    //do nothing
    break;
  case straightLeft:
    fill(leftInput);
    rect(xPos+(cellSize/6), yPos, (cellSize/6), cellSize);
    break;
  case straightRight:
    fill(rightInput);
    rect(xPos+(4*cellSize/6), yPos, (cellSize/6), cellSize);
    break;
  case leftRight:
    fill(leftInput);
    rect(xPos+(cellSize/6), yPos, (cellSize/6), cellSize);
    fill(rightInput);
    rect(xPos+(4*cellSize/6), yPos, (cellSize/6), cellSize);
    break;
  case rightwardSlant:
    fill(leftInput);
    quad(xPos+(cellSize/6), yPos+cellSize, xPos+(2*cellSize/6), yPos+cellSize, xPos+(5*cellSize/6), yPos, xPos+(4*cellSize/6), yPos);
    break;
  case leftwardSlant:
    fill(rightInput);
    quad(xPos+(cellSize/6), yPos, xPos+(2*cellSize/6), yPos, xPos+(5*cellSize/6), yPos+cellSize, xPos+(4*cellSize/6), yPos+cellSize);
    break;
  case zCross:
    fill(rightInput);
    quad(xPos+(cellSize/6), yPos, xPos+(2*cellSize/6), yPos, xPos+(5*cellSize/6), yPos+cellSize, xPos+(4*cellSize/6), yPos+cellSize);//leftward slant
    fill(leftInput);
    quad(xPos+(cellSize/6), yPos+cellSize, xPos+(2*cellSize/6), yPos+cellSize, xPos+(5*cellSize/6), yPos, xPos+(4*cellSize/6), yPos); //rightward slant ON TOP of previously drawn leftward slant
    break;
  case sCross:
    fill(leftInput);
    quad(xPos+(cellSize/6), yPos+cellSize, xPos+(2*cellSize/6), yPos+cellSize, xPos+(5*cellSize/6), yPos, xPos+(4*cellSize/6), yPos); //rightward slant
    fill(rightInput);
    quad(xPos+(cellSize/6), yPos, xPos+(2*cellSize/6), yPos, xPos+(5*cellSize/6), yPos+cellSize, xPos+(4*cellSize/6), yPos+cellSize); //leftward slant ON TOP of previously drawn rightward slant
    break;
  }
  fill(180);
}

public String calcNextCell(String leftCode, String rightCode, boolean[] turningRule, boolean[] crossingRule) {

  String nextCellCode = "";

  boolean hasCrossing = false;
  switch(leftCode) {
    //20 and 30 are left neighbor possilbilities for bits 0-2, look at right neighbor to determine which bit exactly 
  case "20":
  case "30":
    switch(rightCode) {
      //bit 0
    case "10":
    case "30":
      if (!turningRule[0])
        return "30";
      hasCrossing = true;
      nextCellCode += "3";
      break;

      //bit 1
    case "00":
    case "20":
    case "21":
      if (!turningRule[1])
        return "10";
      return "21";  

      //bit 2
    case "11":
    case "32":
    case "33":
      if (!turningRule[2])
        return "30";
      hasCrossing = true;
      nextCellCode += "3";
      break;
    }
    break;

    //bits 3-5
  case "00":
  case "10":
  case "11":
    switch(rightCode) {
      //bit 3
    case "10":
    case "30":
      if (!turningRule[3])
        return "20";
      return "11";

      //bit 4
    case "00":
    case "20":
    case "21":
      return "00";

      //bit 5
    case "11":
    case "32":
    case "33":
      if (!turningRule[5])
        return "20";
      return "11";
    }


    //bits 6-8
  case "21":
  case "32":
  case "33":
    switch(rightCode) {
      //bit 6
    case "10":
    case "30":
      if (!turningRule[6])
        return "30";
      hasCrossing = true;
      nextCellCode += "3";
      break;

      //bit 7
    case "00":
    case "20":
    case "21":
      if (!turningRule[7])
        return "10";
      return "21";

      //bit 8
    case "11":
    case "32":
    case "33":
      if (!turningRule[8])
        return "30";
      hasCrossing = true;
      nextCellCode += "3";
      break;
    }
  }//end turning rule switch statement block

  //only need to run the crossing rule statement block if there's a crossing
  if (hasCrossing) {
    switch(leftCode) {
      //bits 0-2
    case "33":
      switch(rightCode) {
        //bit 0
      case "32":
        if (crossingRule[0])
          return nextCellCode + "2";
        return nextCellCode + "3";

        //bit 1
      case "10":
      case "11":
      case "30": //tenative?
        if (crossingRule[1])
          return nextCellCode + "2";
        return nextCellCode + "3";

        //bit 2
      case "33":
        if (crossingRule[2])
          return nextCellCode + "2";
        return nextCellCode + "3";
      }
      break;

      //bits 3-5
    case "20":
    case "21":
    case "30": //tenative
      switch(rightCode) {
        //bit 3
      case "32":
        if (crossingRule[3])
          return nextCellCode + "2";
        return nextCellCode + "3";

        //bit 4
      case "10":
      case "11":
      case "30": //tenative?
        if (crossingRule[4])
          return nextCellCode + "2";
        return nextCellCode + "3";

        //bit 5
      case "33":
        if (crossingRule[5])
          return nextCellCode + "2";
        return nextCellCode + "3";
      }
      break;

      //bits 6-8
    case "32":
      switch(rightCode) {
        //bit 6
      case "32":
        if (crossingRule[6])
          return nextCellCode + "2";
        return nextCellCode + "3";

        //bit 7
      case "10":
      case "11":
      case "30": //tenative?
        if (crossingRule[7])
          return nextCellCode + "2";
        return nextCellCode + "3";

        //bit 8
      case "33":
        if (crossingRule[8])
          return nextCellCode + "2";
        return nextCellCode + "3";
      }

      break;
    }
  }


  return nextCellCode; //technically redundant unless somehow none of the cases triggered in which this will return a blank string
}

public String enumToBitcode(CellStatus status) {
  String str = "";
  switch(status) {
  case noStrand:
    str = "00";
    break;
  case straightLeft:
    str = "10";
    break;
  case straightRight:
    str = "20";
    break;
  case leftRight:
    str = "30";
    break;
  case rightwardSlant:
    str = "21";
    break;
  case leftwardSlant:
    str = "11";
    break;
  case zCross:
    str = "32";
    break;
  case sCross:
    str = "33"; 
    break;
  default:
    str = "00";
  }

  return str;
}

public CellStatus bitcodeToEnum(String bitcode) {
  CellStatus status = null;

  switch(bitcode) {
  case "00":
    status = CellStatus.noStrand;
    break;
  case "10":
    status = CellStatus.straightLeft;
    break;
  case "20":
    status = CellStatus.straightRight;
    break;
  case "30":
    status = CellStatus.leftRight;
    break;
  case "21":
    status = CellStatus.rightwardSlant;
    break;
  case "11":
    status = CellStatus.leftwardSlant;
    break;
  case "32":
    status = CellStatus.zCross;
    break;
  case "33":
    status = CellStatus.sCross;
    break;
  default:
    status = CellStatus.noStrand;
  }

  return status;
}
/**
 *
 *  Method to check a square region down and to the right of the given point has the mouse pointer contained inside it
 *
 */
public boolean checkCellRegion(Point p, int cellSize) {

  if (mouseX > p.x && mouseX < p.x + cellSize)
    if (mouseY > p.y && mouseY < p.y + cellSize)
      return true;
  return false;
}
