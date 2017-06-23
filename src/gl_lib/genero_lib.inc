&define GL_DBGMSG( lev, msg ) \
	CALL gl_dbgMsg( __FILE__, __LINE__, lev, NVL(msg,"NULL!")) \

&define GL_MODULE_ERROR_HANDLER   WHENEVER ANY ERROR CALL gl_error