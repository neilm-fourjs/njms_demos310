
IMPORT FGL gl_lib
&include "genero_lib.inc"
CONSTANT C_VER="3.1"
CONSTANT PRGDESC = "Material Design Test"
CONSTANT PRGAUTH = "Neil J.Martin"
MAIN
	DEFINE l_rec RECORD
		fld1 CHAR(10),
		fld2 DATE,
		fld3 STRING,
		fld4 STRING,
		fld5 STRING,
		fld6 STRING,
		fld7 STRING,
		fld8 STRING,
		okay BOOLEAN
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
	--LET l_rec.fld3 = "Red"
	LET l_rec.fld4 = "Inactive"
	LET l_rec.fld5 = "Active"
	LET l_rec.fld6 = "Inactive"
	LET l_rec.fld7 = "Active"
	LET l_rec.fld8 = "Inactive"

	DIALOG ATTRIBUTE(UNBUFFERED)
		INPUT BY NAME l_rec.* ATTRIBUTES( WITHOUT DEFAULTS )
		END INPUT
		DISPLAY ARRAY l_arr TO arr.*
		END DISPLAY
		ON ACTION msg MESSAGE "Hello Message"
		ON ACTION err ERROR "Error Message"
		ON ACTION win CALL win()
		ON ACTION wintitle CALL fgl_setTitle("My Window Title")
		ON ACTION dyntext CALL gbc_replaceHTML("dyntext","Dynamic Text")
		ON ACTION darklogo CALL gbc_replaceHTML("logocell","<img src='./resources/img/logo_dark.png'/>")
		ON ACTION lightlogo CALL gbc_replaceHTML("logocell","<img src='./resources/img/logo.png'/>")
		ON ACTION uitext CALL ui.Interface.setText("My UI Text")
		ON ACTION pg CALL pg()
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
--------------------------------------------------------------------------------
FUNCTION pg()
	DEFINE x SMALLINT
	FOR x = 1 TO 5000
		DISPLAY x TO pg
		CALL ui.Interface.refresh()
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION gbc_replaceHTML(l_obj STRING, l_txt STRING)
	DEFINE l_ret STRING
	CALL ui.Interface.frontCall("mymodule","replace_html",[ l_obj, l_txt ], l_ret)
	DISPLAY "l_ret:",l_ret
END FUNCTION