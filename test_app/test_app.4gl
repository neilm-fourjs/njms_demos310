
IMPORT FGL gl_lib

MAIN
	CALL STARTLOG("test."||ui.Interface.getFrontEndName()||".log")
	RUN "env | sort > env."||ui.Interface.getFrontEndName()||".txt"

	CALL gl_lib.gl_init("C",NULL,FALSE)

--	CALL gl_lib.gl_mergeAD( "test" )
--	CALL gl_lib.gl_mergeST( "test" )

	DISPLAY "Prod ver:",gl_lib.gl_getProductVer("fglrun")

	OPEN FORM f FROM "form"
	DISPLAY FORM f
	MENU
		ON ACTION about CALL gl_lib.gl_about( "1.0" )
		ON ACTION exit EXIT MENU
		ON ACTION close EXIT MENU
	END MENU

END MAIN