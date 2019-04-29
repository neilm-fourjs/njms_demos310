-- A Simple demo program with a login and menu system.

IMPORT FGL gl2_lib
IMPORT FGL gl2_logging
IMPORT FGL gl2_about
IMPORT FGL gl2_appInfo

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

DEFINE m_user STRING
DEFINE m_user_id INT

MAIN
  DEFINE gl2_log logger
  DEFINE gl2_err logger
  DEFINE l_appInfo appInfo

  CALL l_appInfo.progInfo(C_PRGDESC, C_PRGAUTH, C_PRGVER, C_PRGICON)
  CALL gl2_log.init(NULL, NULL, "log", "TRUE")
  CALL gl2_log.init(NULL, NULL, "err", "TRUE")
  CALL STARTLOG(gl2_err.fullLogPath)
  CALL gl2_lib.gl2_loadStyles("default")

	CALL gl2_lib.gl2_mdisdi(ARG_VAL(1))

--  CALL gl_lib.gl_setInfo(C_VER, C_SPLASH, C_ICON, C_TITLE, C_PRGDESC, C_PRGAUTH)
--  CALL gl_lib.gl_init(arg_val(1), NULL, FALSE)
  CALL ui.Interface.setText(C_PRGDESC)

  CLOSE WINDOW SCREEN

  IF gl2_lib.m_mdi = "M" THEN
    LET gl2_lib.m_mdi = "C"
  END IF -- if MDI container set so child programs are children

  IF do_dbconnect_and_login() THEN
    CALL gl_gdcupd.gl_gdcupd()
    CALL menuLib.do_menu(C_SPLASH, m_user)
  END IF
  CALL gl2_lib.gl2_exitProgram(0, % "Program Finished")
END MAIN
--------------------------------------------------------------------------------
-- Connect to the database to do the login process
FUNCTION do_dbconnect_and_login() RETURNS BOOLEAN

  IF gl_fe_typ != "GBC" AND gl2_lib.m_mdi = "S" THEN
    CALL gl2_lib.gl2_splash(0, C_SPLASH) -- open splash
  END IF

  CALL gl_db.gldb_connect(NULL)

  IF gl_fe_typ != "GBC" AND gl2_lib.m_mdi = "S" THEN
    SLEEP 2
    CALL gl2_lib.gl2_splash(-1, NULL) -- close splash
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

  LET menuLib.m_args = gl2_lib.m_mdi, " ", m_user_id

  RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
