
IMPORT FGL gl_lib
IMPORT FGL gl_lib_aui

MAIN
	CALL STARTLOG("test."||ui.Interface.getFrontEndName()||".log")
	RUN "env | sort > env."||ui.Interface.getFrontEndName()||".txt"

	CALL gl_lib.gl_init("S",NULL,FALSE)

--	CALL gl_lib.gl_mergeAD( "test" )
--	CALL gl_lib.gl_mergeST( "test" )

	DISPLAY "Prod ver:",gl_lib.gl_getProductVer("fglrun")

	OPEN FORM f FROM "test_form"
	DISPLAY FORM f

	MENU
		ON ACTION wininfo1
			CALL gl_winInfo(1,"Preparing for GDC Update, Please Wait ...","information")
		ON ACTION wininfo2
			CALL gl_winInfo(2,"Getting auto update file, Please Wait ...","")
		ON ACTION wininfo3
			CALL gl_winInfo(3,"","")
		ON ACTION about CALL gl_lib.gl_about( "1.0" )
		ON ACTION exit EXIT MENU
		ON ACTION close EXIT MENU
	END MENU

END MAIN