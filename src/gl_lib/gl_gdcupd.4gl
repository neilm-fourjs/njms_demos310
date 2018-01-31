
-- The goal of the module is to allow the application to detect and trigger an
-- update of the GDC.
-- Contains library functions also used by the gdc_update_srv restful WS.

IMPORT com
IMPORT util
IMPORT os

IMPORT FGL gl_lib
IMPORT FGL gl_lib_aui

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
-- Primary function to call from program to test for and do GDC update.
FUNCTION gl_gdcupd()
	DEFINE l_updServer STRING
	DEFINE l_curGDC, l_os, l_osTarget, l_tmp, l_localFile, l_newFile STRING
	DEFINE l_newGDC, l_newGDCBuild STRING
	DEFINE x SMALLINT
	DEFINE l_stat SMALLINT
	DEFINE l_ret SMALLINT

	IF DOWNSHIFT(ui.Interface.getFrontEndName()) != "gdc" THEN RETURN END IF

	LET l_curGDC = ui.Interface.getFrontEndVersion()
	LET x = l_curGDC.getIndexOf("-",1)
	IF x < 5 THEN
		CALL gl_lib.gl_winMessage("Error",SFMT(%"Invalid GDC Version error '%1'!",l_curGDC),"exclamation")
		RETURN
	END IF
	LET l_curGDC = l_curGDC.subString(1,x-1)
	CALL ui.Interface.frontCall("standard","feinfo", "target", l_osTarget)

	IF NOT validGDCUpdateDir() THEN
		DISPLAY m_ret.stat_txt,":",m_ret.reply
		RETURN
	END IF

-- Do we have an update server defined?
	LET l_updServer = fgl_getEnv("GDCUPDATESERVER")
	IF l_updServer.getLength() > 1 THEN
		CALL useGDCUpdateWS( l_updServer||"/chkgdc?ver=" ||l_curGDC|| "&os="||l_osTarget )
	ELSE -- no update server, try a local update
		CALL getCurrentGDC() RETURNING l_newGDC, l_newGDCBuild
		IF NOT chkIfUpdate( l_curGDC, l_newGDC ) THEN
			RETURN
		END IF
		IF NOT getUpdateFileName(l_newGDC, l_newGDCBuild, l_osTarget) THEN
			RETURN
		END IF
	END IF

	DISPLAY "Stat:",l_stat," Reply:",m_ret.reply," ReplyStat:",m_ret.stat
	IF m_ret.stat != 1 THEN RETURN END IF

-- We have a new GDC Update ! confirm with user
	IF gl_lib.gl_winQuestion("GDC Update",SFMT(%"%1\nUpdate Now?",m_ret.reply),"Yes","Yes|No","question") = "No" THEN
		RETURN
	END IF

	CALL gl_lib_aui.gl_winInfo(1,SFMT(%"%1\nPreparing\nPlease Wait ...",m_ret.reply),"information")

-- does the GDC update file exist on our server
	LET l_localFile = os.path.join(m_gdcUpdateDir,m_ret.upd_file)
	IF NOT os.path.exists( l_localFile ) THEN
		IF m_ret.upd_url IS NOT NULL THEN
			CALL gl_lib_aui.gl_winInfo(1,SFMT(%"%1\nServer Downloading Update File\nPlease Wait ...",m_ret.reply),"information")
			IF NOT getGDCUpdateZipFile( l_localFile, m_ret.upd_url, m_ret.upd_file ) THEN
				CALL gl_GDCUpdateAbort(SFMT(%"Getting GDC Update file failed!\nFile:%1",l_localFile))
				RETURN
			END IF
		ELSE
			CALL gl_GDCUpdateAbort(SFMT(%"The GDC Update file is missing!\nFile:%1",l_localFile))
			RETURN
		END IF
	END IF

-- we have a new GDC to update to - a client temp folder name
	CALL ui.Interface.frontcall("standard", "feinfo", "ostype", [l_os])
	CALL ui.Interface.frontcall("standard", "getenv", ["TEMP"], [l_tmp])
	IF l_os = "WINDOWS" THEN
		IF l_tmp.getLength() < 2 THEN LET l_tmp = "C:\\TEMP" END IF
		LET l_tmp = l_tmp.append("\\")
	ELSE
		IF l_tmp.getLength() < 2 THEN LET l_tmp = "/tmp" END IF
		LET l_tmp = l_tmp.append("/")
	END IF
	
-- Put the local GDC update file to the client
	LET l_newFile = l_tmp||m_ret.upd_file
	DISPLAY "Put:",l_localFile," to ",l_newFile
	CALL gl_lib_aui.gl_winInfo(1,SFMT(%"%1\nClient Downloading Update File\nPlease Wait ...",m_ret.reply),"information")
	TRY
		CALL fgl_putFile(l_localFile,  l_tmp||m_ret.upd_file )
	CATCH
		CALL gl_GDCUpdateAbort(SFMT(%"Copy of GDC auto update file failed!\nSource:%1\nDest:%2\nErr:%3",os.path.join(m_ret.upd_dir,m_ret.upd_file),l_newFile,ERR_GET(STATUS)))
		RETURN
	END TRY

	CALL gl_winInfo(3,"","")

-- Trigger the GDC update
	CALL ui.Interface.frontCall("monitor", "update", [l_newFile], [l_ret]) 
	IF l_ret != 0 THEN
		CALL gl_lib.gl_winMessage("Error","GDC Autoupdate Failed!", "exclamation")
	END IF
END FUNCTION
--------------------------------------------------------------------------------
-- Do the web service REST call to check for a new GDC
FUNCTION gl_GDCUpdateAbort(l_msg STRING)
	CALL gl_winInfo(3,"","")
	CALL gl_lib.gl_winMessage(%"Error",l_msg, "exclamation")
END FUNCTION
--------------------------------------------------------------------------------
-- Do the web service REST call to check for a new GDC
FUNCTION useGDCUpdateWS(l_url STRING)
	DEFINE l_req com.HttpRequest
	DEFINE l_resp com.HttpResponse
	DEFINE l_stat SMALLINT
-- DISPLAY "URL:",l_url
-- Do Rest call to find out if we have a new GDC Update
	TRY
		LET l_req = com.HttpRequest.Create(l_url)
		CALL l_req.setMethod("GET")
		CALL l_req.setHeader("Content-Type", "application/json")
		CALL l_req.setHeader("Accept", "application/json")
		CALL l_req.doRequest()
		LET l_resp = l_req.getResponse()
		LET l_stat = l_resp.getStatusCode()
		IF l_stat = 200 THEN
			CALL util.JSON.parse( l_resp.getTextResponse(), m_ret )
		ELSE
			CALL gl_lib.gl_winMessage("Error",SFMT(" chkgdc cal failed:%1-%2",l_stat, l_resp.getStatusDescription()),"exclamation")
		END IF
	CATCH
		LET l_stat = STATUS
		LET m_ret.reply = ERR_GET( l_stat )
	END TRY
END FUNCTION
--------------------------------------------------------------------------------
-- Valid the folder for the GDC update zip files
FUNCTION validGDCUpdateDir() RETURNS BOOLEAN
	LET m_gdcUpdateDir = fgl_getEnv("GDCUPDATEDIR")
	IF m_gdcUpdateDir.getLength() < 2 THEN
		CALL setReply(205,%"ERR", %"GDCUPDATEDIR Is not set!" )
		RETURN FALSE
	END IF
	IF NOT os.Path.exists(m_gdcUpdateDir) THEN
		CALL setReply(205,%"ERR", SFMT(%"GDCUPDATEDIR '%1' Doesn't Exist",m_gdcUpdateDir))
		RETURN FALSE
	END IF
	DISPLAY base.application.getProgramName(),":GDC Update Dir:",m_gdcUpdateDir
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- Used by local and WS to get the version & build of the 'current' latest GDC.
FUNCTION getCurrentGDC() RETURNS (STRING, STRING)
	DEFINE c base.Channel
	DEFINE l_current STRING
	DEFINE l_gdcVer, l_gdcBuild STRING

	LET l_current = os.path.join(m_gdcUpdateDir,"current.txt")
	IF NOT os.Path.exists(l_current) THEN
		CALL setReply(205,%"ERR", SFMT(%"'%1' Doesn't Exist",l_current))
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
		CALL setReply(205,%"ERR", SFMT(%"Failed to read '%1' '%2'",l_current,ERR_GET(STATUS)))
		RETURN NULL, NULL
	END TRY
	IF l_gdcVer.getLength() < 2 THEN
		CALL setReply(205,%"ERR", SFMT(%"GDC Version is not set in '%1'!",l_gdcVer))

		RETURN NULL, NULL
	END IF
	IF l_gdcBuild.getLength() < 2 THEN
		CALL setReply(205,%"ERR", SFMT(%"GDC Build is not set in '%1'!",l_gdcBuild) )
		RETURN NULL, NULL
	END IF

	RETURN l_gdcVer, l_gdcBuild
END FUNCTION
--------------------------------------------------------------------------------
-- Check to see if the current GDC version of old then the potential new version
FUNCTION chkIfUpdate( l_curGDC STRING, l_newGDC STRING ) RETURNS BOOLEAN
	DEFINE l_cur_maj, l_new_maj DECIMAL(4,2)
	DEFINE l_cur_min, l_new_min SMALLINT

	CALL getVer( l_curGDC ) RETURNING l_cur_maj, l_cur_min
	IF l_cur_maj = 0 THEN
		CALL setReply(206,%"ERR", SFMT(%"Current GDC Version is not correct format '%1'!",l_curGDC))
		RETURN FALSE 
	END IF

	CALL getVer( l_newGDC ) RETURNING l_new_maj, l_new_min
	IF l_new_maj = 0 THEN
		CALL setReply(207,%"ERR", SFMT(%"New GDC Version is not correct format '%1'!",l_newGDC))
		RETURN FALSE
	END IF

	IF l_new_maj = l_cur_maj AND l_new_min = l_cur_min THEN
		CALL setReply(0,%"OK", %"GDC is current version")
		RETURN FALSE
	END IF

-- Is the GDC version older than the requesting GDC
	IF l_new_maj > l_cur_maj THEN
		CALL setReply(1,"OK",SFMT(%"There is new GDC major release available: %1",l_newGDC))
		RETURN TRUE
	END IF
	IF l_new_maj = l_cur_maj AND l_new_min > l_cur_min THEN
		CALL setReply(1,"OK",SFMT(%"There is new GDC minor release available: %1",l_newGDC))
		RETURN TRUE
	END IF
	CALL setReply(208,%"ERR", %"chkIfUpdate: Something is not right!")
	RETURN FALSE
END FUNCTION
--------------------------------------------------------------------------------
-- Sets the upd_file name and checks that it exists in the m_gdcUpdateDir
FUNCTION getUpdateFileName(l_newGDC STRING, l_gdcBuild STRING, l_gdcos STRING ) RETURNS BOOLEAN
	DEFINE l_updFile STRING
	LET l_updFile = "fjs-gdc-"||l_newGDC||"-"||l_gdcBuild||"-"||l_gdcos||"-autoupdate.zip"
	IF NOT os.path.exists( os.path.join(m_gdcUpdateDir,l_updFile) ) THEN
		LET m_ret.stat = 211
		LET m_ret.reply = SFMT(%"GDC Update File '%1' is Missing!",l_updFile)
		RETURN FALSE
	END IF
	DISPLAY base.application.getProgramName(),":GDC Update file exists:",os.path.join(m_gdcUpdateDir,l_updFile)
	LET m_ret.upd_file = l_updFile
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- Break the GDC Version string into major and minor
FUNCTION getVer( l_str STRING ) RETURNS (DECIMAL, INT)
	DEFINE l_major DECIMAL(4,2)
	DEFINE l_minor SMALLINT
	DEFINE l_st base.StringTokenizer
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
--------------------------------------------------------------------------------
-- get the zip file from a remote server
FUNCTION getGDCUpdateZipFile( l_localFile STRING, l_url STRING, l_file STRING ) RETURNS BOOLEAN
	DEFINE l_cmd STRING

	MESSAGE "Getting GDC zip from "||l_url||"  Please wait ... "
	CALL ui.interface.refresh()

	LET l_cmd = "wget -q -O "||l_localFile||" "||l_url||"/"||l_file
	RUN l_cmd

	IF os.Path.exists( l_localFile ) THEN RETURN TRUE END IF
	RETURN FALSE
END FUNCTION
--------------------------------------------------------------------------------
-- Set the reply record structure values for status, text, reply message
FUNCTION setReply(l_stat INT, l_txt STRING, l_msg STRING)
	LET m_ret.stat = l_stat
	LET m_ret.stat_txt = l_txt
	LET m_ret.reply = l_msg
	DISPLAY base.application.getProgramName(),":Set Reply:",l_stat,":",l_txt,":",l_msg
END FUNCTION