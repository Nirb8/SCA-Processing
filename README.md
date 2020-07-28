# SCA-Processing
A Processing 3 implementation of the Stranded Cellular Automaton(SCA), with optional time varying and space varying rulesets.

Processing 3 is needed to run the program, you can get it here at https://processing.org/download/

Click the cells in the bottom row to flip through the initial cell states, **spacebar** to generate new rows of cells (**g** to generate them 5 at a time), and **r** to reset the automata(resetting automata will also reset scroll status). 

Press **t** to toggle through the ruleset modes(Single Ruleset Only, Time-Varying Rulesets, Space-Varying Rulesets), the current status will be displayed in the top right corner of the screen.

Ruleset Input: Click the cells on the sample grid to the right to toggle their states, use **m** or click on the tabs to swap between editing turning or crossing rules, and use **l** to load ruleset into the SCA. Alternatively, you can click on the currently active tab to bring up a textbox that you may enter a rule number into; press **enter/return** or click anywhere to save your changes. If nothing is entered in the textbox when it is saved, no changes will be made to the rule. Pressing **tab** will save the rule currently being edited and open the textbox for editing the other rule. 

Time-Varying Ruleset Input: Hitting **l** will append the ruleset currently displayed in the sample grid to the end of the time-varying ruleset list.

Space-Varying Ruleset Input: The tabs at the bottom of the SCA indicate which side rulesets will be loaded into. Click on the tabs to select the one you want to load rulesets into, and press **l** to load the sample grid ruleset into that side of the SCA. 

Color is enabled by default, pressing **c** will toggle it on/off.

When analyzing particiularly long braids, you can use the scrollwheel to move to a different part of the braid; hold **shift** for increased scroll speed.

Press **Esc** to quit the program.
