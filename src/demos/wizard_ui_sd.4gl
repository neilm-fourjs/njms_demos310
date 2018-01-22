GLOBALS "wizard_glob.inc"
FUNCTION wizard_ui_sd(l_state STRING)
	WHILE l_state!="exit" AND l_state!="accept" 
		CASE l_state
			WHEN "combo"
				LET l_state="left"
				INPUT BY NAME currtable WITHOUT DEFAULTS ATTRIBUTES(UNBUFFERED)
					ON CHANGE currtable CALL on_change_currtable()
					ON ACTION goleft LET l_state="left" EXIT INPUT
					ON ACTION goright LET l_state="right" EXIT INPUT
					ON ACTION canlwiz LET l_state="exit" EXIT INPUT
					ON ACTION finiwiz LET l_state="accept" EXIT INPUT
				END INPUT
			WHEN "left" 
				LET l_state="right" 
				DISPLAY ARRAY lfields TO l.* ATTRIBUTES(UNBUFFERED) 
					ON ACTION right CALL right(DIALOG) CALL upd_right()
					ON ACTION allright CALL allright() CALL upd_right()
					ON ACTION allleft CALL allleft() CALL upd_left()
					ON KEY(TAB) EXIT DISPLAY 
					ON ACTION gocombo LET l_state="combo" EXIT DISPLAY 
					ON ACTION goright LET l_state="right" EXIT DISPLAY 
					ON ACTION canlwiz LET l_state="exit" EXIT DISPLAY 
					ON ACTION finiwiz LET l_state="accept" EXIT DISPLAY  
				END DISPLAY 
			WHEN "right" 
				LET l_state="combo" 
				DISPLAY ARRAY rfields TO r.* ATTRIBUTES(UNBUFFERED) 
					ON ACTION left CALL left(DIALOG) CALL upd_left()
					ON ACTION allleft CALL allleft() CALL upd_left()
					ON ACTION allright CALL allright() CALL upd_right()
					ON KEY(TAB) EXIT DISPLAY 
					ON ACTION gocombo LET l_state="combo" EXIT DISPLAY 
					ON ACTION goleft LET l_state="left" EXIT DISPLAY 
					ON ACTION canlwiz LET l_state="exit" EXIT DISPLAY 
					ON ACTION finiwiz LET l_state="accept" EXIT DISPLAY 
				END DISPLAY 
		END CASE 
	END WHILE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION upd_left()
	DISPLAY ARRAY lfields TO l.*
		BEFORE DISPLAY EXIT DISPLAY
	END DISPLAY
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION upd_right()
	DISPLAY ARRAY rfields TO r.*
		BEFORE DISPLAY EXIT DISPLAY
	END DISPLAY
END FUNCTION
--------------------------------------------------------------------------------