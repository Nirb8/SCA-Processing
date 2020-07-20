
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
      SCA.generationList.clear();
      SCA.generationList.add(zero);
      SCA.clearNeeded = true;
      SCA.currentGeneration = 0;
      offset = 0;
    }

    //toggle color
    if (key == 'c') {
      colorActive = !colorActive;
    }

    if (key == 'l') {
      Ruleset updatedRuleset = new Ruleset(ruleGui.currentRuleset.turningNum, ruleGui.currentRuleset.crossingNum);

      if (!SCA.timeVaryingEnabled && !SCA.spaceVaryingEnabled)
        zero.updateCellRulesets(updatedRuleset);
      else
      {
        if (SCA.timeVaryingEnabled) {
          SCA.rulesetList.addLast(updatedRuleset);
          zero.updateCellRulesets(SCA.rulesetList.get(0));
        } else {
          if (SCA.spaceVaryingEnabled) {
            SCA.rulesetList.addFirst(updatedRuleset);
            if (SCA.rulesetList.size() > 2) {
              SCA.rulesetList.removeLast();
            }
          }
        }
      }
    }

    if (key == 'm') {
      ruleGui.turningActive = !ruleGui.turningActive;
    }
    if (key == 't') {

      if (!SCA.timeVaryingEnabled && !SCA.spaceVaryingEnabled) {
        SCA.timeVaryingEnabled = true;
        SCA.spaceVaryingEnabled = false;
        print("Single Ruleset Mode Disabled");
        println(", Time Varying Rulesets Enabled");
        SCA.ruleIndex = 0;
        SCA.rulesetList.clear();
      } else {
        if (SCA.timeVaryingEnabled && !SCA.spaceVaryingEnabled) {
          SCA.timeVaryingEnabled = false;
          SCA.spaceVaryingEnabled = true;
          print("Time Varying Rulesets Disabled");
          println(", Space Varying Rulesets Enabled");
          SCA.ruleIndex = 0;
          SCA.rulesetList.clear();

          SCA.rulesetList.add(new Ruleset(DEFAULT_TURNING, DEFAULT_CROSSING)); //prepopulate space varying linked list with the zeroth generation's ruleset to avoid having an empty list
          SCA.rulesetList.add(new Ruleset(DEFAULT_TURNING, DEFAULT_CROSSING));
        } else {
          SCA.timeVaryingEnabled = false;
          SCA.spaceVaryingEnabled = false;
          print("Space Varying Rulesets Disabled");
          println(", Single Ruleset Mode Enabled");
        }
      }
    }


    if ( key == 'q'/* && !SCA.rulesetList.isEmpty()*/) {
      print("\nCurrent Rule List Contents: ");
      for (int i = 0; i<SCA.rulesetList.size(); i++) {
        if (i < SCA.rulesetList.size()-1)
          print(" (" + SCA.rulesetList.get(i).turningNum + ", " + SCA.rulesetList.get(i).crossingNum + "), ");
        else
          print(" (" + SCA.rulesetList.get(i).turningNum + ", " + SCA.rulesetList.get(i).crossingNum + ")");
      }
      println("");
    }
  }
}
