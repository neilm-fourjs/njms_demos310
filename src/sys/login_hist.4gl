-- A Simple demo program with a login and menu system.
IMPORT os
IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL gl_gdcupd
IMPORT FGL lib_login
IMPORT FGL new_acct

&include "genero_lib.inc"
&include "schema.inc"
&include "app.inc"

CONSTANT C_TITLE="Login History"
CONSTANT C_SPLASH="logo_dark"
CONSTANT C_ICON="njm_demo_icon"
CONSTANT C_PRGDESC = "NJM's Demos Login History"
CONSTANT C_PRGAUTH = "Neil J.Martin"

MAIN
	CALL gl_lib.gl_setInfo(C_VER, C_SPLASH, C_ICON, C_TITLE, C_PRGDESC, C_PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),NULL,TRUE)
	LET m_mdi = gl_lib.m_mdi
	CALL ui.Interface.setText( gl_progdesc )

	OPEN FORM login_hist FROM "login_hist"
	DISPLAY FORM login_hist

	CALL gl_db.gldb_connect( NULL )

	CALL login_hist()

	CALL gl_lib.gl_exitProgram(0,%"Program Finished")
END MAIN
--------------------------------------------------------------------------------
FUNCTION login_hist()
	DEFINE l_arr DYNAMIC ARRAY OF RECORD LIKE sys_login_hist.*
	DECLARE cur CURSOR FOR SELECT * FROM sys_login_hist
	FOREACH cur INTO l_arr[ l_arr.getLength() + 1 ].*
	END FOREACH
	CALL l_arr.deleteElement( l_arr.getLength() )
	MESSAGE SFMT(%"%1 Rows found.",l_arr.getLength())
	DISPLAY ARRAY l_arr TO scr_arr.* ATTRIBUTES(ACCEPT=FALSE, CANCEL=FALSE)
		ON ACTION quit EXIT DISPLAY
		ON ACTION close EXIT DISPLAY
	END DISPLAY
END FUNCTION