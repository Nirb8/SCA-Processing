/**
 *  Wrapper object that combines turning rule and crossing rule boolean arrays, with some utility methods
 */
public class Ruleset {
  boolean[] turning;
  boolean[] crossing;
  int turningNum; //for debug/display purposes
  int crossingNum; //for debug/display purposes

  /**
   *  Default constructor, initializes to turning/crossing rule 0
   */
  public Ruleset() {
    turning = new boolean[9];
    crossing = new boolean[9];
    turningNum = 0;
    crossingNum = 0;
  }
  /**
   *  Constructor that takes a int for each rule and writes them to the boolean arrays
   */
  public Ruleset(int turningRuleNum, int crossingRuleNum) {
    turning = new boolean[9];
    crossing = new boolean[9];

    setRules(turningRuleNum, crossingRuleNum);
  }

  /**
   *  Sets the boolean arrays in this Ruleset object to match the given parameters
   */
  public void setRules(int turningRule, int crossingRule) {

    // "zero out" the array just in case the binary strings aren't the full 9 characters
    for (int i = 0; i<9; i++) {
      turning[i] = false;
      crossing[i] = false;
    }

    String binaryTurning = Integer.toBinaryString(turningRule); //this will set binaryTurning to a string that may not be 9 characters in the case of consecutive zeros from bit 8
    //println(binaryTurning);
    String binaryCrossing = Integer.toBinaryString(crossingRule); //does the same with binaryCrossing
    // println(binaryCrossing);

    turningNum = turningRule;
    crossingNum = crossingRule;
    int count = 0;
    //iterate backwards over the binary string, which ends up reading the bits in order
    //ex: for "100001011" it will start reading from the rightmost 1, and it puts that value into the boolean array index 0
    //if the binary string isn't 9 characters long the untouched
    for (int i = binaryTurning.length()-1; i >= 0; i--) {
      if (binaryTurning.charAt(i) == '0')
        turning[count] = false;
      else
        turning[count] = true;

      count++;
    }

    count = 0;
    for (int j = binaryCrossing.length()-1; j>= 0; j--) {
      if (binaryCrossing.charAt(j) == '0')
        crossing[count] = false;
      else
        crossing[count] = true;

      count++;
    }
  }

  /**
   *  Debug method to print current ruleset to console
   */
  public void printRules() {
    println("Current Turning Rule: " + turningNum + "\nCurrent Crossing Rule: " + crossingNum);
  }
  /**
   *  Unused method that returns value of boolean array at the given bit number, returning false by default if the given index doesn't exist in the array
   */
  public boolean turningRule(int bitNumber) {
    if (bitNumber<0 || bitNumber>8)
      return false;

    return turning[bitNumber];
  }
  /**
   *  Unused method that returns value of boolean array at the given bit number, returning false by default if the given index doesn't exist in the array
   */
  public boolean crossingRule(int bitNumber) {
    if (bitNumber<0 || bitNumber>8)
      return false;

    return crossing[bitNumber];
  }
  /**
   *  Syncs the rulesets represented by the ints to match the rulesets represented by the boolean arrays, call this everytime either boolean array is updated
   */
  public void updateNumbers() {

    //convert turning rule boolean array into binary string

    String turningBinaryString = "";
    //does the reverse of the process in setRules() and turns the boolean arrays back into binary strings
    for (int i = 0; i < turning.length; i++) {
      if (turning[i])
        turningBinaryString = "1" + turningBinaryString;
      else
        turningBinaryString = "0" + turningBinaryString;
    }

    turningNum = Integer.parseInt(turningBinaryString, 2); //this reads the string as an integer in radix 2 (reads it as a binary number)

    String crossingBinaryString = "";
    for (int i = 0; i < crossing.length; i++) {
      if (crossing[i])
        crossingBinaryString = "1" + crossingBinaryString;
      else
        crossingBinaryString = "0" + crossingBinaryString;
    }

    crossingNum = Integer.parseInt(crossingBinaryString, 2);
  }
}


/**
 *  Simple container for 2 ints representing a coordinate point
 */
public class Point {
  int x;
  int y;
  public Point(int x, int y) {
    this.x = x;
    this.y = y;
  }
}


/**
 *  Rule picker GUI object
 */
public class RuleDisplay {
  LinkedList<Point> coordinateList;
  Ruleset currentRuleset;
  boolean turningActive;
  int cellSize;
  String textbox;
  int cursorBlink;
  final int blinkInterval = 30;
  
  MessageBox msgbox;

  /**
   *  Default constructor, display shows turning rules by default
   */
  RuleDisplay() {
    currentRuleset = new Ruleset();
    currentRuleset.setRules(0, 0);

    turningActive = true;
    cellSize = SIZE_CONSTANT;
    coordinateList = new LinkedList<Point>();

    textbox = "";
    cursorBlink = 0;
    msgbox = new MessageBox();
  }
  /**
   *  Draws an active turning tab along with the sample cells
   */
  public void drawTurningDisplay() {
    int index = 0;

    int origCenterX = coordinateList.get(8).x - width/18;
    int origCenterY = coordinateList.get(8).y - height/12;

    //draw active turning tab
    fill(255);
    //strokeWeight(5);
    stroke(255, 234, 0); //color of tab
    beginShape();
    vertex(origCenterX, origCenterY);
    vertex(origCenterX + width/32, origCenterY - width/48);
    vertex(origCenterX + width/32 + width/16, origCenterY - width/48);
    vertex(origCenterX + width/8, origCenterY);
    endShape(CLOSE);
    stroke(0);
    fill(180);

    fill(0);
    textSize(20); 
    if (turningTextboxActive) {
      text("Turning: " + textbox, origCenterX + width/32, origCenterY-width/128);
      float cursorDx = textWidth("Turning: " + textbox);

      if (cursorBlink < blinkInterval) {
        text("|", origCenterX + width/32 + cursorDx, origCenterY - width/128);
        cursorBlink++;
      }

      if (cursorBlink >= blinkInterval) {
        cursorBlink++;
        if (cursorBlink > 2*blinkInterval) {
          cursorBlink = 0;
        }
      }
    } else {
      text("Turning: " + currentRuleset.turningNum, origCenterX + width/32, origCenterY-width/128);
      cursorBlink = 0;
    }
    fill(180);
    //strokeWeight(2.5);

    origCenterX += width/8;

    //draw inactive crossing tab
    fill(220);
    beginShape();
    vertex(origCenterX, origCenterY);
    vertex(origCenterX + width/32, origCenterY - width/48);
    vertex(origCenterX + width/32 + width/16, origCenterY - width/48);
    vertex(origCenterX + width/8, origCenterY);
    endShape(CLOSE);
    fill(180);

    fill(0);
    textSize(20);
    text("Crossing: " + currentRuleset.crossingNum, origCenterX + width/32, origCenterY-width/128);
    fill(180);


    //bit 0
    Point center = coordinateList.get(index);
    if (!currentRuleset.turning[index]) {
      drawStrands(center.x, center.y, CellStatus.leftRight, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.straightRight, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.straightLeft, cellSize); //draw right neighbor
    index++;

    //bit 1
    center = coordinateList.get(index);
    if (!currentRuleset.turning[index]) {
      drawStrands(center.x, center.y, CellStatus.straightLeft, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.rightwardSlant, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.straightRight, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.noStrand, cellSize); //draw right neighbor
    index++;

    //bit 2
    center = coordinateList.get(index);
    if (!currentRuleset.turning[index]) {
      drawStrands(center.x, center.y, CellStatus.leftRight, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.straightRight, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.leftwardSlant, cellSize); //draw right neighbor
    index++;

    //bit 3
    center = coordinateList.get(index);
    if (!currentRuleset.turning[index]) {
      drawStrands(center.x, center.y, CellStatus.straightRight, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.leftwardSlant, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.noStrand, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.straightLeft, cellSize); //draw right neighbor
    index++;

    //bit 4
    center = coordinateList.get(index);
    if (!currentRuleset.turning[index]) {
      drawStrands(center.x, center.y, CellStatus.noStrand, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.noStrand, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.noStrand, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.noStrand, cellSize); //draw right neighbor
    index++;

    //bit 5
    center = coordinateList.get(index);
    if (!currentRuleset.turning[index]) {
      drawStrands(center.x, center.y, CellStatus.straightRight, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.leftwardSlant, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.noStrand, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.leftwardSlant, cellSize); //draw right neighbor
    index++;

    //bit 6
    center = coordinateList.get(index);
    if (!currentRuleset.turning[index]) {
      drawStrands(center.x, center.y, CellStatus.leftRight, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.rightwardSlant, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.straightLeft, cellSize); //draw right neighbor
    index++;

    //bit 7
    center = coordinateList.get(index);
    if (!currentRuleset.turning[index]) {
      drawStrands(center.x, center.y, CellStatus.straightLeft, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.rightwardSlant, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.rightwardSlant, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.noStrand, cellSize); //draw right neighbor
    index++;

    //bit 8
    center = coordinateList.get(index);
    if (!currentRuleset.turning[index]) {
      drawStrands(center.x, center.y, CellStatus.leftRight, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.rightwardSlant, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.leftwardSlant, cellSize); //draw right neighbor
  }

  /**
   *  Draws an active crossing tab along with the sample cells
   */
  public void drawCrossingDisplay() {

    int index = 0;

    int origCenterX = coordinateList.get(8).x - width/18;
    int origCenterY = coordinateList.get(8).y - height/12;

    //draw inactive turning tab
    fill(220);
    beginShape();
    vertex(origCenterX, origCenterY);
    vertex(origCenterX + width/32, origCenterY - width/48);
    vertex(origCenterX + width/32 + width/16, origCenterY - width/48);
    vertex(origCenterX + width/8, origCenterY);
    endShape(CLOSE);
    fill(180);

    fill(0);
    textSize(20);
    text("Turning: " + currentRuleset.turningNum, origCenterX + width/32, origCenterY-width/128);
    fill(180);

    origCenterX += width/8;

    //draw active crossing tab
    fill(255);
    //strokeWeight(5);
    stroke(255, 234, 0);
    beginShape();
    vertex(origCenterX, origCenterY);
    vertex(origCenterX + width/32, origCenterY - width/48);
    vertex(origCenterX + width/32 + width/16, origCenterY - width/48);
    vertex(origCenterX + width/8, origCenterY);
    endShape(CLOSE);
    stroke(0);
    fill(180);

    fill(0);
    textSize(20);
    if (crossingTextboxActive) {
      text("Crossing: " + textbox, origCenterX + width/32, origCenterY - width/128);
      float cursorDx = textWidth("Crossing: " + textbox);

      if (cursorBlink < blinkInterval) {
        text("|", origCenterX + width/32 + cursorDx, origCenterY - width/128);
        cursorBlink++;
      }

      if (cursorBlink >= blinkInterval) {
        cursorBlink++;
        if (cursorBlink > 2*blinkInterval) {
          cursorBlink = 0;
        }
      }
    } else {
      text("Crossing: " + currentRuleset.crossingNum, origCenterX + width/32, origCenterY-width/128);
      cursorBlink = 0;
    }

    fill(180);
    // strokeWeight(2.5);

    //bit 0
    Point center = coordinateList.get(index);
    if (!currentRuleset.crossing[index]) {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.zCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.sCross, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.zCross, cellSize); //draw right neighbor
    index++;

    //bit 1
    center = coordinateList.get(index);
    if (!currentRuleset.crossing[index]) {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.zCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.sCross, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.leftwardSlant, cellSize); //draw right neighbor
    index++;

    //bit 2
    center = coordinateList.get(index);
    if (!currentRuleset.crossing[index]) {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.zCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.sCross, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.sCross, cellSize); //draw right neighbor
    index++;

    //bit 3
    center = coordinateList.get(index);
    if (!currentRuleset.crossing[index]) {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.zCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.rightwardSlant, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.zCross, cellSize); //draw right neighbor
    index++;

    //bit 4
    center = coordinateList.get(index);
    if (!currentRuleset.crossing[index]) {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.zCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.rightwardSlant, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.leftwardSlant, cellSize); //draw right neighbor
    index++;

    //bit 5
    center = coordinateList.get(index);
    if (!currentRuleset.crossing[index]) {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.zCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.rightwardSlant, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.sCross, cellSize); //draw right neighbor
    index++;

    //bit 6
    center = coordinateList.get(index);
    if (!currentRuleset.crossing[index]) {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.zCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.zCross, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.zCross, cellSize); //draw right neighbor
    index++;

    //bit 7
    center = coordinateList.get(index);
    if (!currentRuleset.crossing[index]) {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.zCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.zCross, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.leftwardSlant, cellSize); //draw right neighbor
    index++;

    //bit 8
    center = coordinateList.get(index);
    if (!currentRuleset.crossing[index]) {
      drawStrands(center.x, center.y, CellStatus.sCross, cellSize);
    } else {
      drawStrands(center.x, center.y, CellStatus.zCross, cellSize);
    }
    drawStrands(center.x - cellSize/2, center.y + cellSize, CellStatus.zCross, cellSize); //draw left neighbor
    drawStrands(center.x + cellSize/2, center.y + cellSize, CellStatus.sCross, cellSize); //draw right neighbor
  }
  /**
   *  Debug method that prints all the coordinates of the sample cell locations(upper left corners)
   */
  public void debugCoords() {
    for (int i = 0; i<coordinateList.size(); i++) {
      println(i + ":  (" + coordinateList.get(i).x + ", " + coordinateList.get(i).y+ ")");
    }
  }
  
}


public class MessageBox{
  String message;
  int messageTimer;
  
  public MessageBox(){
    message = "";
    messageTimer = 0;
  }
  
  public void clear(){
    noStroke();
      fill(220);
      rect(7 * width/12, 6.8 * height/8, textWidth(message)*1.5, 48);
      fill(255);
      stroke(0);
  }
  
  public void drawMessage(color c, String msg, int time){
    clear();
    messageTimer = time;
    message = msg;
    textSize(24);
    fill(c);
    stroke(c);
    text(msg, 7 * width/12, 7 * height/8);
    stroke(0);
    fill(255);
  }
  
}
