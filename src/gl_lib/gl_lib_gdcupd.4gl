
IMPORT os

TYPE t_myReply RECORD
		stat SMALLINT,
		stat_txt STRING,
		reply STRING,
		upd_url STRING,
		upd_dir STRING,
		upd_file STRING
	END RECORD
PUBLIC DEFINE m_ret t_myReply
PUBLIC DEFINE m_gdcUpdateDir STRING

--------------------------------------------------------------------------------
-- These functions are also used by the gbc_update_srv Web Service
--------------------------------------------------------------------------------
-- Valid the folder for the GDC update zip files
FUNCTION gl_validGDCUpdateDir() RETURNS BOOLEAN
	LET m_gdcUpdateDir = fgl_getEnv("GDCUPDATEDIR")
	IF m_gdcUpdateDir.getLength() < 2 THEN
		CALL gl_setReply(205,%"ERR", %"GDCUPDATEDIR Is not set!" )
		RETURN FALSE
	END IF
	IF NOT os.Path.exists(m_gdcUpdateDir) THEN
		CALL gl_setReply(206,%"ERR", SFMT(%"GDCUPDATEDIR '%1' Doesn't Exist",m_gdcUpdateDir))
		RETURN FALSE
	END IF
	DISPLAY base.application.getProgramName(),":GDC Update Dir:",m_gdcUpdateDir
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- Used by local and WS to get the version & build of the 'current' latest GDC.
FUNCTION gl_getCurrentGDC() RETURNS (STRING, STRING)
	DEFINE c base.Channel
	DEFINE l_current STRING
	DEFINE l_gdcVer, l_gdcBuild STRING

	LET l_current = os.path.join(m_gdcUpdateDir,"current.txt")
	IF NOT os.Path.exists(l_current) THEN
		CALL gl_setReply(207,%"ERR", SFMT(%"'%1' Doesn't Exist",l_current))
		RETURN NULL, NULL
	END IF
	LET m_ret.upd_dir = m_gdcUpdateDir
-- Reads the current gdc version from current.txt file 
	LET c = base.Channel.create()
	TRY
		CALL c.openFile(l_current,"r")
		LET l_gdcVer = c.readLine()
		LET l_gdcBuild = c.readLine()
		CALL c.close()
	CATCH
		CALL gl_setReply(208,%"ERR", SFMT(%"Failed to read '%1' '%2'",l_current,ERR_GET(STATUS)))
		RETURN NULL, NULL
	END TRY
	IF l_gdcVer.getLength() < 2 THEN
		CALL gl_setReply(209,%"ERR", SFMT(%"GDC Version is not set in '%1'!",l_gdcVer))

		RETURN NULL, NULL
	END IF
	IF l_gdcBuild.getLength() < 2 THEN
		CALL gl_setReply(210,%"ERR", SFMT(%"GDC Build is not set in '%1'!",l_gdcBuild) )
		RETURN NULL, NULL
	END IF

	RETURN l_gdcVer, l_gdcBuild
END FUNCTION
--------------------------------------------------------------------------------
-- Check to see if the current GDC version of old then the potential new version
FUNCTION gl_chkIfUpdate( l_curGDC STRING, l_newGDC STRING ) RETURNS BOOLEAN
	DEFINE l_cur_maj, l_new_maj DECIMAL(4,2)
	DEFINE l_cur_min, l_new_min SMALLINT

	CALL gl_getVer( l_curGDC ) RETURNING l_cur_maj, l_cur_min
	IF l_cur_maj = 0 THEN
		CALL gl_setReply(211,%"ERR", SFMT(%"Current GDC Version is not correct format '%1'!",l_curGDC))
		RETURN FALSE 
	END IF

	CALL gl_getVer( l_newGDC ) RETURNING l_new_maj, l_new_min
	IF l_new_maj = 0 THEN
		CALL gl_setReply(212,%"ERR", SFMT(%"New GDC Version is not correct format '%1'!",l_newGDC))
		RETURN FALSE
	END IF

	IF l_new_maj = l_cur_maj AND l_new_min = l_cur_min THEN
		CALL gl_setReply(0,%"OK", %"GDC is current version")
		RETURN FALSE
	END IF

-- Is the GDC version older than the requesting GDC
	IF l_new_maj > l_cur_maj THEN
		CALL gl_setReply(1,%"OK",SFMT(%"There is new GDC major release available: %1",l_newGDC))
		RETURN TRUE
	END IF
	IF l_new_maj = l_cur_maj AND l_new_min > l_cur_min THEN
		CALL gl_setReply(1,%"OK",SFMT(%"There is new GDC minor release available: %1",l_newGDC))
		RETURN TRUE
	END IF
	CALL gl_setReply(213,%"ERR", %"chkIfUpdate: Something is not right!")
	RETURN FALSE
END FUNCTION
--------------------------------------------------------------------------------
-- Sets the upd_file name and checks that it exists in the m_gdcUpdateDir
FUNCTION gl_getUpdateFileName(l_newGDC STRING, l_gdcBuild STRING, l_gdcos STRING ) RETURNS BOOLEAN
	DEFINE l_updFile STRING
	LET l_updFile = "fjs-gdc-"||l_newGDC||"-"||l_gdcBuild||"-"||l_gdcos||"-autoupdate.zip"
	IF NOT os.path.exists( os.path.join(m_gdcUpdateDir,l_updFile) ) THEN
		CALL gl_setReply(214,%"ERR", SFMT(%"GDC Update File '%1' is Missing!",l_updFile))
		RETURN FALSE
	END IF
	DISPLAY base.application.getProgramName(),":GDC Update file exists:",os.path.join(m_gdcUpdateDir,l_updFile)
	LET m_ret.upd_file = l_updFile
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- Set the reply record structure values for status, text, reply message
FUNCTION gl_setReply(l_stat INT, l_txt STRING, l_msg STRING)
	LET m_ret.stat = l_stat
	LET m_ret.stat_txt = l_txt
	LET m_ret.reply = l_msg
	DISPLAY base.application.getProgramName(),":Set Reply:",l_stat,":",l_txt,":",l_msg
END FUNCTION
--------------------------------------------------------------------------------
-- Break the GDC Version string into major and minor
FUNCTION gl_getVer( l_str STRING ) RETURNS (DECIMAL, INT)
	DEFINE l_major DECIMAL(4,2)
	DEFINE l_minor SMALLINT
	DEFINE l_st base.StringTokenizer
	LET l_minor = l_str.getIndexOf("-",1)
	IF l_minor > 0 THEN LET l_str = l_str.subString(1,l_minor-1) END IF
	LET l_st = base.StringTokenizer.create(l_str,".")
	--DISPLAY "Tok:",l_st.countTokens()
	IF l_st.countTokens() != 3 THEN
		RETURN 0,0
	END IF
	LET l_minor = l_st.nextToken()
	LET l_major = l_minor
	LET l_minor = l_st.nextToken()
	LET l_major = l_major + (l_minor / 100)
	LET l_minor = l_st.nextToken()
	--DISPLAY "Maj:",l_major," Min:",l_minor
	RETURN l_major, l_minor
END FUNCTION