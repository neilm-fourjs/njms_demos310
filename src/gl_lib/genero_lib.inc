&define GL_DBGMSG( lev, msg ) \
	CALL gl_dbgMsg( __FILE__, __LINE__, lev, NVL(msg,"NULL!")) \

&define GL_MODULE_ERROR_HANDLER   WHENEVER ANY ERROR CALL gl_error

&define GL_ABOUT ON ACTION about CALL gl_about( gl_version )

GLOBALS
	DEFINE gl_dbgLev SMALLINT  -- debug level: 0=None, 1=General, 2=All
	DEFINE gl_version STRING
	DEFINE gl_progIcon STRING
	DEFINE gl_progName STRING -- base.application.getProgramName
	DEFINE gl_progDesc STRING
	DEFINE gl_progAuth STRING
	DEFINE gl_splashImage STRING
	DEFINE gl_toolbar,  gl_topmenu STRING
	DEFINE gl_os STRING
	DEFINE gl_userName STRING
	DEFINE gl_app_build STRING -- Applcation Build 
	DEFINE gl_app_name STRING -- Applcation Name
	DEFINE gl_cli_os STRING
	DEFINE gl_cli_osver STRING
	DEFINE gl_cli_un STRING
	DEFINE gl_cli_res STRING
	DEFINE gl_cli_dir STRING
	DEFINE gl_fe_typ STRING
	DEFINE gl_fe_ver STRING
END GLOBALS
