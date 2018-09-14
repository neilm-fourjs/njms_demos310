
-- The goal of the module is to allow the application to detect and trigger an
-- update of the GDC.
-- Contains library functions also used by the gdc_update_srv restful WS.

IMPORT com
IMPORT util
IMPORT os

IMPORT FGL gl_lib
IMPORT FGL gl_lib_aui
IMPORT FGL gl_lib_gdcupd

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

	IF NOT gl_validGDCUpdateDir() THEN
		DISPLAY m_ret.stat_txt,":",m_ret.reply
		RETURN
	END IF

-- Do we have an update server defined?
	LET l_updServer = fgl_getEnv("GDCUPDATESERVER")
	IF l_updServer.getLength() > 1 THEN
		CALL useGDCUpdateWS( l_updServer||"/chkgdc?ver=" ||l_curGDC|| "&os="||l_osTarget )
	ELSE -- no update server, try a local update
		CALL gl_getCurrentGDC() RETURNING l_newGDC, l_newGDCBuild
		IF NOT gl_chkIfUpdate( l_curGDC, l_newGDC ) THEN
			RETURN
		END IF
		IF NOT gl_getUpdateFileName(l_newGDC, l_newGDCBuild, l_osTarget) THEN
			RETURN
		END IF
	END IF

	DISPLAY "Stat:",l_stat," Reply:",gl_lib_gdcupd.m_ret.reply," ReplyStat:",gl_lib_gdcupd.m_ret.stat
	IF gl_lib_gdcupd.m_ret.stat != 1 THEN RETURN END IF

-- We have a new GDC Update ! confirm with user
	IF gl_lib.gl_winQuestion("GDC Update",SFMT(%"%1\nUpdate Now?",gl_lib_gdcupd.m_ret.reply),"Yes","Yes|No","question") = "No" THEN
		RETURN
	END IF

	CALL gl_lib_aui.gl_winInfo(1,SFMT(%"%1\nPreparing\nPlease Wait ...",gl_lib_gdcupd.m_ret.reply),"information")

-- does the GDC update file exist on our server
	LET l_localFile = os.path.join(gl_lib_gdcupd.m_gdcUpdateDir,gl_lib_gdcupd.m_ret.upd_file)
	IF NOT os.path.exists( l_localFile ) THEN
		IF m_ret.upd_url IS NOT NULL THEN
			CALL gl_lib_aui.gl_winInfo(1,SFMT(%"%1\nServer Downloading Update File\nPlease Wait ...",gl_lib_gdcupd.m_ret.reply),"information")
			IF NOT getGDCUpdateZipFile( l_localFile, gl_lib_gdcupd.m_ret.upd_url, gl_lib_gdcupd.m_ret.upd_file ) THEN
				CALL abortGDCUpdate(SFMT(%"Getting GDC Update file failed!\nFile:%1",l_localFile))
				RETURN
			END IF
		ELSE
			CALL abortGDCUpdate(SFMT(%"The GDC Update file is missing!\nFile:%1",l_localFile))
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
	LET l_newFile = l_tmp||gl_lib_gdcupd.m_ret.upd_file
	DISPLAY "Put:",l_localFile," to ",l_newFile
	CALL gl_lib_aui.gl_winInfo(1,SFMT(%"%1\nClient Downloading Update File\nPlease Wait ...",m_ret.reply),"information")
	TRY
		CALL fgl_putFile(l_localFile,  l_tmp||gl_lib_gdcupd.m_ret.upd_file )
	CATCH
		CALL abortGDCUpdate(SFMT(%"Copy of GDC auto update file failed!\nSource:%1\nDest:%2\nErr:%3",os.path.join(m_ret.upd_dir,m_ret.upd_file),l_newFile,ERR_GET(STATUS)))
		RETURN
	END TRY

	CALL gl_lib_aui.gl_winInfo(3,"","")

-- Trigger the GDC update
	CALL ui.Interface.frontCall("monitor", "update", [l_newFile], [l_ret]) 
	IF l_ret != 0 THEN
		CALL abortGDCUpdate("GDC Autoupdate Failed!")
	END IF
END FUNCTION
--------------------------------------------------------------------------------
-- Do the web service REST call to check for a new GDC
PRIVATE FUNCTION abortGDCUpdate(l_msg STRING)
	CALL gl_lib_aui.gl_winInfo(3,"","")
	CALL gl_lib.gl_winMessage(%"Error",l_msg, "exclamation")
END FUNCTION
--------------------------------------------------------------------------------
-- Do the web service REST call to check for a new GDC
PRIVATE FUNCTION useGDCUpdateWS(l_url STRING)
	DEFINE l_req com.HttpRequest
	DEFINE l_resp com.HttpResponse
	DEFINE l_stat SMALLINT
	DISPLAY "useGDCUpdateWS URL:",l_url
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
			CALL util.JSON.parse( l_resp.getTextResponse(), gl_lib_gdcupd.m_ret )
		ELSE
			CALL abortGDCUpdate(SFMT("WS chkgdc call failed!\n%1\n%1-%2",l_url,l_stat, l_resp.getStatusDescription()))
		END IF
	CATCH
		LET l_stat = STATUS
		LET gl_lib_gdcupd.m_ret.reply = ERR_GET( l_stat )
	END TRY
END FUNCTION
--------------------------------------------------------------------------------
-- get the zip file from a remote server
PRIVATE FUNCTION getGDCUpdateZipFile( l_localFile STRING, l_url STRING, l_file STRING ) RETURNS BOOLEAN
	DEFINE l_cmd STRING

	MESSAGE "Getting GDC zip from "||l_url||"  Please wait ... "
	CALL ui.interface.refresh()

	LET l_cmd = "wget -q -O "||l_localFile||" "||l_url||"/"||l_file
	RUN l_cmd

	IF os.Path.exists( l_localFile ) THEN RETURN TRUE END IF
	RETURN FALSE
END FUNCTION