-- A Simple demo program with a login and menu system.

IMPORT FGL gl_lib
IMPORT FGL gl_splash
IMPORT FGL gl_db
IMPORT FGL gl_gdcupd
IMPORT FGL lib_login
IMPORT FGL menuLib
IMPORT FGL new_acct
&include "genero_lib.inc"
&include "schema.inc"
&include "app.inc"

CONSTANT C_TITLE = "NJM's Demos"
CONSTANT C_SPLASH = "logo_dark"
CONSTANT C_ICON = "njm_demo_icon"
CONSTANT C_PRGDESC = "NJM's Demos Menu System v2"
CONSTANT C_PRGAUTH = "Neil J.Martin"

DEFINE m_user STRING
DEFINE m_user_id INT

MAIN
  CALL gl_lib.gl_setInfo(C_VER, C_SPLASH, C_ICON, C_TITLE, C_PRGDESC, C_PRGAUTH)
  CALL gl_lib.gl_init(arg_val(1), NULL, FALSE)
  CALL ui.Interface.setText(gl_progdesc)

  CLOSE WINDOW SCREEN

  IF gl_lib.m_mdi = "M" THEN
    LET gl_lib.m_mdi = "C"
  END IF -- if MDI container set so child programs are children

  IF do_dbconnect_and_login() THEN
    CALL gl_gdcupd.gl_gdcupd()
    CALL menuLib.do_menu(C_SPLASH, m_user)
  END IF
  CALL gl_lib.gl_exitProgram(0, % "Program Finished")
END MAIN
--------------------------------------------------------------------------------
-- Connect to the database to do the login process
FUNCTION do_dbconnect_and_login() RETURNS BOOLEAN

  IF gl_fe_typ != "GBC" AND gl_lib.m_mdi = "S" THEN
    LET gl_splashImage = C_SPLASH
    CALL gl_splash.gl_splash(0) -- open splash
  END IF

  CALL gl_db.gldb_connect(NULL)

  IF gl_fe_typ != "GBC" AND gl_lib.m_mdi = "S" THEN
    SLEEP 2
    CALL gl_splash.gl_splash(-1) -- close splash
  END IF

  LET lib_login.m_logo_image = C_SPLASH
  LET lib_login.m_new_acc_func = FUNCTION new_acct.new_acct

-- For quick testing only
  IF arg_val(1) = "test@test.com" THEN
    LET m_user = arg_val(1)
  ELSE
    LET m_user = lib_login.login(C_TITLE, C_VER)
  END IF
  IF m_user = "Cancelled" THEN
    RETURN FALSE
  END IF

  SELECT user_key INTO m_user_id FROM sys_users WHERE email = m_user

  LET menuLib.m_args = gl_lib.m_mdi, " ", m_user_id

  RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
