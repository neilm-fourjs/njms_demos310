
&ifndef GL2_DEBUG
&define GL2_DEBUG
IMPORT FGL gl2_debug
&endif

&define GL_DBGMSG( lev, msg ) \
 CALL gl2_dbgMsg( __FILE__, __LINE__, lev, NVL(msg,"NULL!"))

GLOBALS
  DEFINE gl_dbgLev SMALLINT
END GLOBALS
