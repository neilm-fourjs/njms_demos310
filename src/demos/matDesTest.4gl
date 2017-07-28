
IMPORT FGL gl_lib
&include "genero_lib.inc"
CONSTANT C_VER="3.1"
CONSTANT PRGDESC = "Material Design Test"
CONSTANT PRGAUTH = "Neil J.Martin"
MAIN
	DEFINE l_rec RECORD
		fld1 CHAR(10),
		fld2 DATE,
		fld4 STRING,
		fld6 STRING
	END RECORD
	DEFINE l_arr DYNAMIC ARRAY OF RECORD
		col1 STRING,
		col2 SMALLINT,
		img STRING
	END RECORD
	DEFINE x SMALLINT
	CALL gl_lib.gl_setInfo(C_VER, NULL, NULL, NULL, PRGDESC, PRGAUTH)
	CALL gl_lib.gl_init( ARG_VAL(1) ,NULL,TRUE)
	CALL ui.Interface.setText( gl_lib.gl_progdesc )

	FOR X = 1 TO 5
		LET l_arr[x].col1 = "Row "||x
		LET l_arr[x].col2 = x
		LET l_arr[x].img = "fa-smile-o"
	END FOR

	OPEN FORM f FROM "matDesTest"
	DISPLAY FORM f

	LET l_rec.fld1 = "Active"
	LET l_rec.fld2 = TODAY
	LET l_rec.fld4 = "Active"
	LET l_rec.fld6 = "Active"

	DISPLAY "Not active" TO fld3
	DISPLAY "Not active" TO fld5
	DISPLAY "Not active" TO fld7

	DIALOG ATTRIBUTE(UNBUFFERED)
		INPUT BY NAME l_rec.* ATTRIBUTES( WITHOUT DEFAULTS )
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