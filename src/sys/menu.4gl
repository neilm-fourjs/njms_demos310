-- A Simple demo program with a login and menu system.

IMPORT FGL gl2_lib
IMPORT FGL gl2_about
IMPORT FGL gl2_appInfo
IMPORT FGL gl2_db
IMPORT FGL gl2_gdcUpdate

IMPORT FGL lib_login
IMPORT FGL menuLib
IMPORT FGL new_acct
&include "schema.inc"
&include "app.inc"

CONSTANT C_TITLE = "NJM's Demos"
CONSTANT C_SPLASH = "logo_dark"
CONSTANT C_PRGDESC = "NJM's Demos Menu System v3"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_PRGICON = "njm_demo_icon"
CONSTANT C_PRGVER = "3.2"

 DEFINE m_appInfo gl2_appInfo.appInfo
MAIN

  CALL m_appInfo.progInfo(C_PRGDESC, C_PRGAUTH, C_PRGVER, C_PRGICON)
	CALL gl2_lib.gl2_init( ARG_VAL(1), "default")
  WHENEVER ANY ERROR CALL gl2_lib.gl2_error
  CALL ui.Interface.setText(C_PRGDESC)

  CLOSE WINDOW SCREEN

  IF gl2_lib.m_mdi = "M" THEN
    LET gl2_lib.m_mdi = "C"
  END IF -- if MDI container set so child programs are children

  IF do_dbconnect_and_login() THEN
    CALL gl2_gdcUpdate.gl2_gdcUpate()
    CALL menuLib.do_menu(C_SPLASH, m_appInfo)
  END IF
  CALL gl2_lib.gl2_exitProgram(0, % "Program Finished")
END MAIN
--------------------------------------------------------------------------------
-- Connect to the database to do the login process
FUNCTION do_dbconnect_and_login() RETURNS BOOLEAN
  DEFINE l_db gl2_db.dbInfo
	DEFINE l_user STRING
	DEFINE l_user_id INTEGER

  IF gl2_lib.m_mdi = "S" THEN
    CALL gl2_lib.gl2_splash(0, C_SPLASH) -- open splash
  END IF

  CALL l_db.gl2_connect(NULL)

  IF gl2_lib.m_mdi = "S" THEN
    SLEEP 2
    CALL gl2_lib.gl2_splash(-1, NULL) -- close splash
  END IF

  LET lib_login.m_logo_image = C_SPLASH
  LET lib_login.m_new_acc_func = FUNCTION new_acct.new_acct

-- For quick testing only
  IF ARG_VAL(1) = "test@test.com" THEN
    LET l_user = ARG_VAL(1)
  ELSE
    LET l_user = lib_login.login(C_TITLE, C_PRGVER, m_appInfo)
  END IF
  IF l_user = "Cancelled" THEN
    RETURN FALSE
  END IF

  SELECT user_key INTO l_user_id FROM sys_users WHERE email = l_user

  LET menuLib.m_args = gl2_lib.m_mdi, " ", l_user_id

  RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
