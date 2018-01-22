GLOBALS "wizard_glob.inc"
FUNCTION wizard_ui_md()
	DIALOG ATTRIBUTE(UNBUFFERED)
		INPUT BY NAME currtable ATTRIBUTE(WITHOUT DEFAULTS)
			ON CHANGE currtable CALL on_change_currtable()
		END INPUT
		DISPLAY ARRAY lfields TO l.*
			ON ACTION right CALL right(DIALOG)
		END DISPLAY
		DISPLAY ARRAY rfields TO r.*
			ON ACTION left CALL left(DIALOG)
		END DISPLAY
		ON ACTION allright CALL allright()
		ON ACTION allleft CALL allleft()
		ON ACTION canlwiz EXIT DIALOG
		ON ACTION finiwiz ACCEPT DIALOG
	END DIALOG
END FUNCTION