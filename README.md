# SCA-Processing
A Processing 3 implementation of the Stranded Cellular Automaton, with optional time varying and space varying rulesets.

Processing 3 is needed to run the program, you can get it here at https://processing.org/download/

Click the cells in the bottom row to flip through the initial cell states, **spacebar** to generate new rows of cells, and **r** to reset the automata(resetting automata will also reset scroll status). 

For ruleset input, click the cells on the sample grid to the left to toggle their states, **m** or clicking on the tabs to swap between editing turning and crossing rules, and **l** to load the ruleset currently displayed in the sample grid into the bottom row of cells. Alternatively, click on the current active rule tab to type in a rule(only numbers will be accepted into the textbox). Press **enter/return** or click anywhere to confirm the rule selection. If nothing is entered, no changes will be made to the currently displayed ruleset.

Press **t** to toggle time-varying rulesets(current status displayed in console temporarily).

Color is enabled by default, pressing **c** will toggle it on/off.

When analyzing particiularly long braids, you can use the scrollwheel to scroll to a different part of the braid; hold **shift** to scroll faster.

Press **Esc** to quit the program.
