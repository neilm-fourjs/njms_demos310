
IMPORT util
IMPORT FGL gl_lib
IMPORT FGL gl_lib_aui
IMPORT FGL gl_gdcupd

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
		ON ACTION updateGDC
			CALL gl_gdcupd.gl_gdcupd()
		ON ACTION wininfo1
			CALL gl_winInfo(1,"Preparing for GDC Update, Please Wait ...","information")
		ON ACTION wininfo2
			CALL gl_winInfo(2,"Getting auto update file, Please Wait ...","")
		ON ACTION wininfo3
			CALL gl_winInfo(3,"","")
		ON ACTION local_keys
			CALL get_localstorage_keys()
		ON ACTION about CALL gl_about( "1.0" )
		ON ACTION exit EXIT MENU
		ON ACTION close EXIT MENU
	END MENU

END MAIN
--------------------------------------------------------------------------------
FUNCTION get_localstorage_keys()
	DEFINE l_key_list STRING
	DEFINE l_key_array DYNAMIC ARRAY OF STRING
	DEFINE l_pos INTEGER
	DEFINE l_key, l_val STRING

	DISPLAY "Calling setItem"
	CALL ui.Interface.frontCall("localStorage", "setItem", ["myKey","foo"], [])
	DISPLAY "Calling keys"
	CALL ui.Interface.frontCall("localStorage","keys",[],[l_key_list])
	DISPLAY "Calling parse:",l_key_list
	CALL util.JSON.parse(l_key_list,l_key_array)
	DISPLAY "Displaying keys..."
	FOR l_pos = 1 TO l_key_array.getLength()
		DISPLAY l_key_array[l_pos]
		LET l_key = l_key_array[l_pos]
		CALL ui.Interface.frontCall("localStorage", "getItem", [l_key], [l_val])
		DISPLAY "Key:",l_key, " Value:",l_val
	END FOR

END FUNCTION