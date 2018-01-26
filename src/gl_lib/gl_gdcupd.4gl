
IMPORT com
IMPORT util
IMPORT os

TYPE t_myReply RECORD
		stat SMALLINT,
		txt STRING,
		reply STRING,
		upd_dir STRING,
		upd_file STRING
	END RECORD
PUBLIC DEFINE m_ret t_myReply
PUBLIC DEFINE m_gdcUpdateDir STRING

FUNCTION gl_gdcupd()
	DEFINE l_updServer, l_url STRING
	DEFINE l_ver, l_os, l_osTarget, l_tmp, l_localFile, l_newFile STRING
	DEFINE x SMALLINT
	DEFINE l_stat SMALLINT
	DEFINE l_req com.HttpRequest
	DEFINE l_resp com.HttpResponse
	DEFINE l_ret SMALLINT

	DISPLAY "gl_gdcupd:", DOWNSHIFT(ui.Interface.getFrontEndName())
	IF DOWNSHIFT(ui.Interface.getFrontEndName()) != "gdc" THEN RETURN END IF

	LET l_updServer = fgl_getEnv("GDCUPDATESERVER")
	IF l_updServer.getLength() < 2 THEN
--TODO: look for local update files
		CALL gl_winMessage("Error","GDCUPDATESERVER is not valid!","exclamation")
		RETURN
	END IF

	LET l_ver = ui.Interface.getFrontEndVersion()
	LET x = l_ver.getIndexOf("-",1)
	IF x < 5 THEN
		CALL gl_winMessage("Error",SFMT(%"GDC Version error '%1'!",l_ver),"exclamation")
		RETURN
	END IF
	LET l_ver = l_ver.subString(1,x-1)
	CALL ui.Interface.frontCall("standard","feinfo", "target", l_osTarget)
	DISPLAY "Ver:",l_ver," OS:",l_osTarget," UpdateServer:",l_updServer
	LET l_url = l_updServer||"/chkgdc?ver=" ||l_ver|| "&os="||l_osTarget
	DISPLAY "URL:",l_url
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
			CALL gl_winMessage("Error",SFMT(" chkgdc cal failed:%1-%2",l_stat, l_resp.getStatusDescription()),"exclamation")
		END IF
	CATCH
		LET l_stat = STATUS
		LET m_ret.reply = ERR_GET( l_stat )
	END TRY
	DISPLAY "Stat:",l_stat," Reply:",m_ret.reply," ReplyStat:",m_ret.stat
	IF m_ret.stat != 1 THEN RETURN END IF

-- We have a new GDC Update ! confirm with user
	IF gl_winQuestion("GDC Update",SFMT(%"%1\nUpdate Now?",m_ret.reply),"Yes","Yes|No","question") = "No" THEN
		RETURN
	END IF

-- does the GDC update file exist on our server
	LET l_localFile = os.path.join(m_ret.upd_dir,m_ret.upd_file)
	IF NOT os.path.exists( l_localFile ) THEN
--TODO: feature to get it from a remote server
		CALL gl_winMessage(%"Error",SFMT(%"The GDC Update file is missing!\nFile:%1",l_localFile),"exclamation")
		RETURN
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
	TRY
		CALL fgl_putFile(l_localFile,  l_tmp||m_ret.upd_file )
	CATCH
		CALL gl_winMessage(%"Error",SFMT(%"Copy of GDC auto update file failed!\nSource:%1\nDest:%2\nErr:%3",os.path.join(m_ret.upd_dir,m_ret.upd_file),l_newFile,ERR_GET(STATUS)),"exclamation")
		RETURN
	END TRY

-- Trigger the GDC update
	CALL ui.Interface.frontCall("monitor", "update", [l_newFile], [l_ret]) 
	IF l_ret != 0 THEN
		CALL gl_winMessage("Error","GDC Autoupdate Failed!", "exclamation")
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getCurrentGDC()
	DEFINE c base.Channel
	DEFINE l_current STRING
	DEFINE l_gdcVer, l_gdcBuild STRING

	LET m_gdcUpdateDir = fgl_getEnv("GDCUPDATEDIR")
	IF m_gdcUpdateDir.getLength() < 2 THEN
		RETURN NULL, %"GDCUPDATEDIR Is not set!"
	END IF
	IF NOT os.Path.exists(m_gdcUpdateDir) THEN
		RETURN NULL, SFMT(%"GDCUPDATEDIR '%1' Doesn't Exist",m_gdcUpdateDir)
	END IF
	LET l_current = os.path.join(m_gdcUpdateDir,"current.txt")
	IF NOT os.Path.exists(l_current) THEN
		RETURN NULL, SFMT(%"'%1' Doesn't Exist",l_current)
	END IF
-- Reads the current gdc version from current.txt file 
	LET c = base.Channel.create()
	TRY
		CALL c.openFile(l_current,"r")
		LET l_gdcVer = c.readLine()
		LET l_gdcBuild = c.readLine()
		CALL c.close()
	CATCH
		RETURN NULL,SFMT(%"Failed to read '%1' '%2'",l_current,ERR_GET(STATUS))
	END TRY
	IF l_gdcVer.getLength() < 2 THEN
		RETURN NULL, SFMT(%"GDC Version is not set in '%1'!",l_gdcVer)
	END IF
	IF l_gdcBuild.getLength() < 2 THEN
		RETURN NULL,SFMT(%"GDC Build is not set in '%1'!",l_gdcBuild)
	END IF

	RETURN l_gdcVer, l_gdcBuild

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getVer( l_str STRING )
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