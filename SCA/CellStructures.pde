import java.util.LinkedList;

/**
 *  Main data class, contains the lists of generations and manages generating new generations and drawing the ruleset labels
 */
public class StrandedCellAutomata {
  int currentGeneration;
  LinkedList<StrandedCellGeneration> generationList; //using LinkedLists because Processing ArrayLists don't like to stay sorted for some reason, also LinkedLists have addFirst() and addLast()
  StrandedCellGeneration generation;
  boolean clearNeeded;
  boolean timeVaryingEnabled;
  LinkedList<Ruleset> timeRules;
  int timeRuleIndex;

  /**
   *  Constructor for StrandedCellAutomata
   */
  StrandedCellAutomata(StrandedCellGeneration seed) {
    generationList = new LinkedList<StrandedCellGeneration>();
    generationList.addFirst(seed);
    currentGeneration = 0;
    generation = seed;
    clearNeeded = true;
    timeVaryingEnabled = false;
    timeRules = new LinkedList<Ruleset>();
  }

  /**
   *  Iterates over the latest generation in the generationList and creates a new generation based on the previous generation's cells,
   *  adds the newly created generation to the front of the generationList
   */
  public void growthCycle() {
    StrandedCellGeneration parentGeneration = generationList.get(0);

    int nextX = parentGeneration.xPos;
    int nextY = parentGeneration.yPos - parentGeneration.cellSize;

    LinkedList<StrandedCell> nextCells = new LinkedList<StrandedCell>();

    LinkedList<StrandedCell> tempParentCells = new LinkedList<StrandedCell>();
    tempParentCells.addAll(parentGeneration.cells);
    int shiftFactor = parentGeneration.cellSize/2; //how much to offset the cells in order to create the "staggered brick" structure of the cells

    //checks if the index of the parent generation is even/odd and adjusts the offset accordingly(to the left/negative for even, to the right/positive for odd)
    //also adds an empty cell to the front or end of the tempParentCells list for calculating the cases with only one neighbor and a border cell(border cells count as noStrand cells)
    if (currentGeneration % 2 == 0) {
      StrandedCell noStrandCell = new StrandedCell(0, CellStatus.noStrand, tempParentCells.getFirst().ruleset);
      shiftFactor *= -1;
      tempParentCells.addFirst(noStrandCell);
    } else {
      StrandedCell noStrandCell = new StrandedCell(0, CellStatus.noStrand, tempParentCells.getLast().ruleset);

      tempParentCells.addLast(noStrandCell);
    }

    //for time varying rulesets, increments the index in ruleset list and loops back to zero if it reaches the end of the list
    if (timeVaryingEnabled) {
      timeRuleIndex++; 
      if (timeRuleIndex == timeRules.size()) {
        timeRuleIndex = 0;
      }
    }

    println("generated using ruleset at index " + timeRuleIndex);
    //iterates over every neighbor pair and adds the newly generated cells to the next generation's cell list
    for (int i = 0; i<tempParentCells.size()-1; i++) {
      StrandedCell leftCell = tempParentCells.get(i);
      StrandedCell rightCell = tempParentCells.get(i+1);
      CellStatus leftStatus = leftCell.status;
      CellStatus rightStatus = rightCell.status;
      CellStatus newCellStatus = bitcodeToEnum(calcNextCell(enumToBitcode(leftStatus), enumToBitcode(rightStatus), leftCell.ruleset.turning, leftCell.ruleset.crossing));
      color leftInputColor = leftCell.getRightOutputColor();
      color rightInputColor = rightCell.getLeftOutputColor();

      Ruleset newRules = leftCell.ruleset;

      if (timeVaryingEnabled && !timeRules.isEmpty()) {
        newRules = timeRules.get(timeRuleIndex);
      }

      StrandedCell newCell = new StrandedCell((i*parentGeneration.cellSize), newCellStatus, newRules, leftInputColor, rightInputColor);

      nextCells.addLast(newCell);
    }

    currentGeneration++;

    StrandedCellGeneration nextGeneration = new StrandedCellGeneration(nextX + shiftFactor, nextY, parentGeneration.numCells, currentGeneration, nextCells);
    generationList.addFirst(nextGeneration);
  }

  /**
   *  Draws the adajacent rule labels, with a buffer of 15 rulesets in advance of the currently displayed generations
   */
  public void drawRulesets(int offset) {

    int x = generation.xPos + generation.cells.get(generation.cells.size()-1).deltaX + 4*generation.cellSize/3;
    int y = generation.yPos + generation.cellSize/2 - offset;
    textSize(14);

    fill(220);
    noStroke();
    rect(x, 0, 150, height);
    stroke(0);
    fill(0);
    if (timeVaryingEnabled && !timeRules.isEmpty()) {
      int index = 0;

      for (int i = 0; i<15 + generationList.size(); i++) {
        text(index + ": (" + timeRules.get(index).turningNum + ", " + timeRules.get(index).crossingNum + ")", x, y - (generation.cellSize * i));
        index++;
        if (index == timeRules.size())
          index = 0;
      }
    } else {

      for (int i = 0; i<15 + generationList.size(); i++) {
        text(i + ": (" + generation.cells.get(0).ruleset.turningNum + ", " + generation.cells.get(0).ruleset.crossingNum + ")", x, y - (generation.cellSize * i));
      }
    }
    fill(255);
  }
}


/**
 *  Represents a SCA Generation  
 */
public class StrandedCellGeneration {
  LinkedList<StrandedCell> cells;
  int cellSize;
  int numCells;
  int generationNumber;
  int xPos; //x coord of leftmost cell
  int yPos; //y coord of leftmost cell

  /**
   *  Special constructor for creating zeroth generation
   */
  public StrandedCellGeneration(int x, int y, int numCells) {
    xPos = x;
    yPos = y;
    cellSize = SIZE_CONSTANT;
    this.numCells = numCells;
    cells = new LinkedList<StrandedCell>();
    generationNumber = 0;

    for (int i = 0; i<numCells; i++) {
      cells.add(new StrandedCell(i*cellSize, CellStatus.noStrand, new Ruleset(DEFAULT_TURNING, DEFAULT_CROSSING)));
    }
  }
  /**
   *  Standard constructor for a StrandedCellGeneration, parameters need to be initialized prior to the use of this constructor
   */
  public StrandedCellGeneration(int x, int y, int numCells, int generationNumber, LinkedList<StrandedCell> cellList) {
    xPos = x;
    yPos = y;
    cellSize = SIZE_CONSTANT;
    this.numCells = numCells;
    this.generationNumber = generationNumber;
    cells = cellList;
  }

  /**
   *  Debug method that shows the status of all cells in a generation's cell list
   */
  public void listCellStatus() {
    for (StrandedCell c : cells) {
      println(c.status + ", ");
    }
  }

  /**
   *  Method to refresh all of a generation's cells with a new ruleset, **ONLY INTENDED FOR USE WITH ZEROTH GENERATION**
   */
  public void updateCellRulesets(Ruleset r) {
    for (StrandedCell c : cells) {
      c.ruleset = r;
    }
  }

  /**
   *  Iterates through a generation's cells and calls each StrandedCell's drawCell method with the given offset and colorActive status
   */
  public void drawGeneration(boolean colorActive, int offset) {
    for (StrandedCell c : cells) {
      c.drawCell(xPos, yPos-offset, colorActive);
    }
  }
}

/**
 *  Represents a single SCA cell
 */
public class StrandedCell {
  int deltaX; //displacement from the origin of the generation this cell belongs to
  CellStatus status; 
  Ruleset ruleset;
  int size;
  color leftInput; //the color of this cell's left strand color
  color rightInput;//the colorof this cell's right strand color

  /**
   *  Depreciated method for creating cells w/o color
   */
  public StrandedCell(int dx, CellStatus initStatus, Ruleset ruleset) {
    this.deltaX = dx;
    status = initStatus;
    this.ruleset = ruleset;
    size = SIZE_CONSTANT;
  }
  /**
   *  Creates cells with color
   */
  public StrandedCell(int dx, CellStatus initStatus, Ruleset ruleset, color leftInput, color rightInput) {
    this.deltaX = dx;
    status = initStatus;
    this.ruleset = ruleset;
    size = SIZE_CONSTANT;
    this.leftInput = leftInput;
    this.rightInput = rightInput;
  }

  /**
   *  Recolors cells given parameters for new colors
   */
  public void setColors(color leftInput, color rightInput) {
    this.leftInput = leftInput;
    this.rightInput = rightInput;
  }

  /**
   *  For use in generating new cells, returns the color of the strand leaving the top left of the cell
   */
  public color getLeftOutputColor() {
    color leftOutput;  
    if (this.status == CellStatus.zCross || this.status == CellStatus.sCross || this.status == CellStatus.leftwardSlant || this.status == CellStatus.rightwardSlant) {
      leftOutput = rightInput;
    } else {
      leftOutput = leftInput;
    }
    return leftOutput;
  }
  /**
   *  For use in generating new cells, returns the color of the strand leaving the top right of the cell
   */
  public color getRightOutputColor() {
    color rightOutput;
    if (this.status == CellStatus.zCross || this.status == CellStatus.sCross || this.status == CellStatus.leftwardSlant || this.status == CellStatus.rightwardSlant) {
      rightOutput = leftInput;
    } else {
      rightOutput = rightInput;
    }
    return rightOutput;
  }

  /**
   *  Deprecated method that calls the drawStrands method with the cell's data, takes the x and y coordinates of the generation it belongs to
   */
  public void drawCell(int x, int y) {
    drawStrands(x + deltaX, y, this.status, this.size, leftInput, rightInput);
  }

  /**
   *  Calls drawStrands method with different parameters depending on status of colorActive, takes the x and y coordinates of the generation it belongs to
   */
  public void drawCell(int x, int y, boolean colorActive) {

    if (colorActive)
      drawStrands(x + deltaX, y, this.status, this.size, leftInput, rightInput);
    else
      drawStrands(x + deltaX, y, this.status, this.size);
  }
  /**
   *  Cycles cell status between the 8 possible states
   */
  public void cycleStatus() {
    //println("cycling status");
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
