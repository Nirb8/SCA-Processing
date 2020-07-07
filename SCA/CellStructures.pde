import java.util.LinkedList;

public class StrandedCellAutomata {
  int currentGeneration;
  LinkedList<StrandedCellGeneration> generationList;
  StrandedCellGeneration generation;
  boolean clearNeeded;

  StrandedCellAutomata(StrandedCellGeneration seed) {
    generationList = new LinkedList<StrandedCellGeneration>();
    generationList.addFirst(seed);
    currentGeneration = 0;
    generation = seed;
    clearNeeded = true;
  }


  public void growthCycle() {
    StrandedCellGeneration parentGeneration = generationList.get(0);

    int nextX = parentGeneration.xPos;
    int nextY = parentGeneration.yPos - parentGeneration.cellSize;

    LinkedList<StrandedCell> nextCells = new LinkedList<StrandedCell>();

    LinkedList<StrandedCell> tempParentCells = new LinkedList<StrandedCell>();
    tempParentCells.addAll(parentGeneration.cells);
    int shiftFactor = parentGeneration.cellSize/2;

    if (currentGeneration % 2 == 0) {
      StrandedCell noStrandCell = new StrandedCell(0, CellStatus.noStrand, tempParentCells.getFirst().ruleset);
      shiftFactor *= -1;
      tempParentCells.addFirst(noStrandCell);
    } else {
      
      StrandedCell noStrandCell = new StrandedCell(0, CellStatus.noStrand, tempParentCells.getLast().ruleset);
      
      tempParentCells.addLast(noStrandCell);
    }

    for (int i = 0; i<tempParentCells.size()-1; i++) {
      StrandedCell leftCell = tempParentCells.get(i);
      StrandedCell rightCell = tempParentCells.get(i+1);
      CellStatus leftStatus = leftCell.status;
      CellStatus rightStatus = rightCell.status;
      CellStatus newCellStatus = bitcodeToEnum(calcNextCell(enumToBitcode(leftStatus), enumToBitcode(rightStatus), leftCell.ruleset.turning, leftCell.ruleset.crossing));
      
      StrandedCell newCell = new StrandedCell((i*parentGeneration.cellSize), newCellStatus, leftCell.ruleset);
      
      nextCells.addLast(newCell);
}

    currentGeneration++;

    StrandedCellGeneration nextGeneration = new StrandedCellGeneration(nextX + shiftFactor, nextY, parentGeneration.numCells, currentGeneration, nextCells);
    generationList.addFirst(nextGeneration);
  }
}

public class StrandedCellGeneration {
  LinkedList<StrandedCell> cells;
  int cellSize;
  int numCells;
  int generationNumber;
  int xPos; //x coord of leftmost cell
  int yPos; //y coord of leftmost cell


  //temp special constructor for 0th generation
  public StrandedCellGeneration(int x, int y, int numCells) {
    xPos = x;
    yPos = y;
    cellSize = SIZE_CONSTANT;
    this.numCells = numCells;
    cells = new LinkedList<StrandedCell>();
    generationNumber = 0;

   // cells.add(new StrandedCell(0, CellStatus.zCross, new Ruleset(324, 6)));
    for (int i = 0; i<numCells; i++) {
      cells.add(new StrandedCell(i*cellSize, CellStatus.noStrand, new Ruleset(324, 140)));
    }
    //cells.add(new StrandedCell((numCells-1)*cellSize, CellStatus.noStrand, new Ruleset(324, 6)));
  }
  public StrandedCellGeneration(int x, int y, int numCells, int generationNumber, LinkedList<StrandedCell> cellList) {
    xPos = x;
    yPos = y;
    cellSize = SIZE_CONSTANT;
    this.numCells = numCells;
    this.generationNumber = generationNumber;
    cells = cellList;
  }

  public void listCellStatus() {
    for (StrandedCell c : cells) {
      println(c.status + ", ");
    }
  }

  public void drawGeneration() {
    for (StrandedCell c : cells) {
      c.drawCell(xPos, yPos);
    }
  }
}

public class StrandedCell {
  int deltaX;
  CellStatus status;
  Ruleset ruleset;
  int size;

  public StrandedCell(int dx, CellStatus initStatus, Ruleset ruleset) {
    this.deltaX = dx;
    status = initStatus;
    this.ruleset = ruleset;
    size = SIZE_CONSTANT;
  }

  public void drawCell(int x, int y) {
    //if(status != CellStatus.noStrand)
    drawStrands(x + deltaX, y, this.status, this.size);
  }
  
  public void cycleStatus() {
    switch(status) {

    case noStrand:
      status = CellStatus.straightLeft;//set the status to straightLeft
      break;
    case straightLeft:
      status = CellStatus.straightRight;//set the status to straightRight
      break;
    case straightRight:
      status = CellStatus.leftRight;
      break;
    case leftRight:
      status = CellStatus.rightwardSlant;//set the status to rightwardSlant
      break;
    case rightwardSlant:
      status = CellStatus.leftwardSlant;//draw the rightwardSlant
      break;
    case leftwardSlant:
      status = CellStatus.zCross;//set the status to zCross
      break;
    case zCross:
      status = CellStatus.sCross;
      break;
    case sCross:
      status = CellStatus.noStrand;//set the status to noStrand
      break;
    } 

    
  }
}

public class Ruleset {
  boolean[] turning;
  boolean[] crossing;
  int turningNum; //for debug purposes
  int crossingNum; //for debug purposes


  public Ruleset() {
    turning = new boolean[9];
    crossing = new boolean[9];
  }

  public Ruleset(int turningRuleNum, int crossingRuleNum) {
    turning = new boolean[9];
    crossing = new boolean[9];

    setRules(turningRuleNum, crossingRuleNum);
  }

  public void setRules(int turningRule, int crossingRule) {
    String binaryTurning = Integer.toBinaryString(turningRule);
    //println(binaryTurning);
    String binaryCrossing = Integer.toBinaryString(crossingRule);
    // println(binaryCrossing);

    turningNum = turningRule;
    crossingNum = crossingRule;
    int count = 0;
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

  //for debugging
  public void printRules() {
    println("Current Turning Rule: " + turningNum + "\nCurrent Crossing Rule: " + crossingNum);
  }

  public boolean turningRule(int bitNumber) {
    if (bitNumber<0 || bitNumber>8)
      return false;

    return turning[bitNumber];
  }

  public boolean crossingRule(int bitNumber) {
    if (bitNumber<0 || bitNumber>8)
      return false;

    return crossing[bitNumber];
  }
}

public class Point{
   int x;
   int y;
   public Point(int x, int y){
    this.x = x;
    this.y = y;
   }
}

/**
*
*  Rule picker GUI object
*
*/
public class RuleDisplay{
  LinkedList<Point> coordinateList;
  Ruleset currentRuleset;
  
  RuleDisplay(){
    currentRuleset = new Ruleset();
    currentRuleset.setRules(0,0);
    
    coordinateList = new LinkedList<Point>();
  }
  
  public void drawTurningDisplay(){
    
  }
  
  public void drawCrossingDisplay(){
    
  }
  public void debugCoords(){
   for(int i = 0;i<coordinateList.size();i++){
    println(i + ":  (" + coordinateList.get(i).x + ", " + coordinateList.get(i).y+ ")");
   }
  }
}
