final int SIZE_CONSTANT = 90; //<>// //<>//


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


  //bit 8
  //drawStrands(centerX, centerY, CellStatus.noStrand, width/24);
  //drawStrands(centerX - width/48, centerY + width/24, CellStatus.noStrand, width/24);
  //drawStrands(centerX + width/48, centerY + width/24, CellStatus.noStrand, width/24);

  //centerX = centerX + (width/12) + (width/36);




  //  centerX = centerX + (width/12) + (width/36);
  //  centerY = centerY + (width/12) + (width/36);


  //  drawStrands(centerX, centerY, CellStatus.noStrand, width/24);

  //  centerX = centerX + (width/12) + (width/36);

  //  drawStrands(centerX, centerY, CellStatus.noStrand, width/24);
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

  //int centerX = 7*width/12;

  //int centerY = height/6;

  //ruleGui.drawTurningDisplay();



  if (ruleGui.turningActive) {
    ruleGui.drawTurningDisplay();
  } else {
    ruleGui.drawCrossingDisplay();
  }

  for (StrandedCellGeneration g : SCA.generationList) {
    g.drawGeneration();
  }
}

void mouseClicked() {

  //"buttons" for manipulating zeroth generation
  if (mouseY >= zero.yPos && mouseY <= zero.yPos + zero.cellSize) {
    for (int i = 0; i<zero.cells.size()-1; i++) {
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

  for (int i = 0; i<9; i++) {
    Point pt = ruleGui.coordinateList.get(i);
    if (checkCellRegion(pt, ruleGui.cellSize)) {
      int bitChange = 1;
      for (int j = i; j>0; j--) {
        bitChange *= 2;
      }
      if (ruleGui.turningActive) { //TURNING RULE

        if (!ruleGui.currentRuleset.turning[i]) { //Selected bit is OFF and we toggle it ON
          ruleGui.currentRuleset.turning[i] = true;
          ruleGui.currentRuleset.updateNumbers();
          
        } else {  //Selected bit is ON and we toggle it OFF
          ruleGui.currentRuleset.turning[i] = false;
          ruleGui.currentRuleset.updateNumbers();
        }
      } else { //CROSSING RULE
        if(!ruleGui.currentRuleset.crossing[i]){  //Selected bit is OFF and we toggle it ON
          ruleGui.currentRuleset.crossing[i] = true;
          ruleGui.currentRuleset.updateNumbers();
        }else{  //Selected bit is ON and we toggle it OFF
          ruleGui.currentRuleset.crossing[i] = false;
          ruleGui.currentRuleset.updateNumbers();
        }
        
      }
      ruleGui.currentRuleset.printRules();
    }
  }
}

void keyPressed() {
  if (key == ' ') {
    SCA.growthCycle();
  }

  if (key == 'p') {
    //SCA.pollGenerations();
    ruleGui.currentRuleset.printRules();
  }

  if (key == 'r') {
    SCA = new StrandedCellAutomata(zero);
  }

  //if (key == 'n') {
  //  ruleTester++;
  //  println(ruleTester);
  //  if (ruleTester==512) {
  //    ruleTester = 0;
  //  }
  //  ruleGui.currentRuleset.printRules();
  //}
  if(key == 'l'){
     zero.updateCellRulesets(ruleGui.currentRuleset); 
  }

  if (key == 'm') {
    ruleGui.turningActive = !ruleGui.turningActive;
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
