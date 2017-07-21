
IMPORT FGL gl_lib
&include "genero_lib.inc"
CONSTANT C_VER="3.1"
CONSTANT PRGDESC = "Material Design Test"
CONSTANT PRGAUTH = "Neil J.Martin"
MAIN
	DEFINE l_rec RECORD
		str STRING,
		dt DATE
	END RECORD
	DEFINE l_arr DYNAMIC ARRAY OF RECORD
		fld1 STRING,
		fld2 SMALLINT
	END RECORD
	DEFINE x SMALLINT
	CALL gl_lib.gl_setInfo(C_VER, NULL, NULL, NULL, PRGDESC, PRGAUTH)
	CALL gl_lib.gl_init( ARG_VAL(1) ,NULL,TRUE)
	CALL ui.Interface.setText( gl_lib.gl_progdesc )

	FOR X = 1 TO 5
		LET l_arr[x].fld1 = "Row "||x
		LET l_arr[x].fld2 = x
	END FOR

	OPEN FORM f FROM "matDesTest"
	DISPLAY FORM f

	DIALOG ATTRIBUTE(UNBUFFERED)
		INPUT BY NAME l_rec.*
		END INPUT
		DISPLAY ARRAY l_arr TO arr.*
		END DISPLAY
		ON ACTION msg MESSAGE "Hello Message"
		ON ACTION err ERROR "Error Message"
		ON ACTION win CALL win()
		GL_ABOUT
		ON ACTION close EXIT DIALOG
		ON ACTION quit EXIT DIALOG
	END DIALOG
END MAIN
--------------------------------------------------------------------------------
FUNCTION win()

	OPEN WINDOW win WITH FORM "matDesTest_modal"
	MENU
		ON ACTION close EXIT MENU
		ON ACTION cancel EXIT MENU
	END MENU
	CLOSE WINDOW win

END FUNCTION