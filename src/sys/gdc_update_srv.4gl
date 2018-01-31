
-- GDCUPDATEURL is the url for the Genero App server to fetch the zip file
-- if the server is not the same machine.

IMPORT com
IMPORT util
IMPORT os
IMPORT FGL gl_restful_lib
IMPORT FGL gl_gdcupd

MAIN
  DEFINE l_ret INTEGER
  DEFINE l_req com.HTTPServiceRequest
	DEFINE l_str STRING
	DEFINE l_quit BOOLEAN
  DEFER INTERRUPT
	
-- URL To the web server for the GDC Update file zips
	LET gl_gdcupd.m_ret.upd_url = fgl_getEnv("GDCUPDATEURL")

	IF NOT gl_gdcupd.gl_validGDCUpdateDir() THEN -- sets m_gdcUpdateDir
		DISPLAY m_ret.reply
		EXIT PROGRAM
	END IF

  DISPLAY "Starting server..."
  #
  # Starts the server on the port number specified by the FGLAPPSERVER environment variable
  #  (EX: FGLAPPSERVER=8090)
  # 
	TRY
  	CALL com.WebServiceEngine.Start()
  	DISPLAY "The server is listening."
	CATCH
		DISPLAY STATUS,":",ERR_GET(STATUS)
		EXIT PROGRAM
	END TRY

  WHILE NOT l_quit
	  TRY
  		# create the server
		  LET l_req = com.WebServiceEngine.getHTTPServiceRequest(-1)
		  CALL gl_restful_lib.getReqInfo(l_req)

		  DISPLAY "Processing request, Method:", gl_restful_lib.m_reqInfo.method, " Path:", gl_restful_lib.m_reqInfo.path, " format:", gl_restful_lib.m_reqInfo.outformat
		  -- parse the url, retrieve the operation and the operand
		  CASE gl_restful_lib.m_reqInfo.method
			  WHEN "GET"
					CASE
						WHEN gl_restful_lib.m_reqInfo.path.equalsIgnoreCase("/chkgdc") 
							CALL gdcchk()
						WHEN gl_restful_lib.m_reqInfo.path.equalsIgnoreCase("/restart")
							CALL gl_gdcupd.gl_setReply(200,%"OK",%"Service Exiting")
							LET l_quit = TRUE
						OTHERWISE
							CALL gl_gdcupd.gl_setReply(201,%"ERR",SFMT(%"Operation '%1' not found",gl_restful_lib.m_reqInfo.path))
					END CASE
					DISPLAY "Reply:", m_ret.reply
					LET l_str = util.JSON.stringify(m_ret)
			  OTHERWISE
					CALL setError("Unknown request:\n"||m_reqInfo.path||"\n"||m_reqInfo.method)
					LET gl_restful_lib.m_err.code = -3
					LET gl_restful_lib.m_err.desc = SFMT(%"Method '%' not supported",gl_restful_lib.m_reqInfo.method)
					LET l_str = util.JSON.stringify(m_err)
		  END CASE
			-- send back the response.
			CALL l_req.setResponseHeader("Content-Type","application/json")
			CALL l_req.sendTextResponse(200, %"OK", l_str)
		  IF int_flag != 0 THEN LET int_flag=0 EXIT WHILE END IF
		CATCH
			LET l_ret = STATUS
			CASE l_ret
				WHEN -15565
					DISPLAY "Disconnected from application server."
					EXIT WHILE
				OTHERWISE
					DISPLAY "[ERROR] "||l_ret
					EXIT WHILE
				END CASE
		END TRY
	END WHILE
	DISPLAY "Service Exited."
END MAIN
--------------------------------------------------------------------------------
FUNCTION gdcchk()
	DEFINE x SMALLINT
	DEFINE l_curGDC, l_newGDC, l_gdcBuild, l_gdcOS STRING

	LET x = gl_restful_lib.getParameterIndex("ver") 
	IF x = 0 THEN
		CALL gl_gdcupd.gl_setReply(201,%"ERR",%"Missing parameter 'ver'!")
		RETURN
	END IF
	LET x = gl_restful_lib.getParameterIndex("os") 
	IF x = 0 THEN
		CALL gl_gdcupd.gl_setReply(202,%"ERR",%"Missing parameter 'os'!")
		RETURN
	END IF
	LET l_curGDC = gl_restful_lib.getParameterValue(1)
	IF l_curGDC.getIndexOf(".",1) < 1 THEN
		CALL gl_gdcupd.gl_setReply(203,%"ERR",SFMT(%"Expected GDC version x.xx.xx got '%1'!",l_curGDC))
		RETURN
	END IF
	LET l_gdcos = gl_restful_lib.getParameterValue(2)
	IF l_gdcos.getLength() < 1 THEN
		CALL gl_gdcupd.gl_setReply(204,%"ERR",SFMT(%"Expected GDC OS is invalid '%1'!",l_gdcos))
		RETURN
	END IF

-- Get the new GDC version from the directory structure
	CALL gl_gdcupd.gl_getCurrentGDC() RETURNING l_newGDC, l_gdcBuild
	IF l_newGDC IS NULL THEN
		RETURN
	END IF

-- is the 'current' GDC > than the one passed to us?
	IF NOT gl_gdcupd.gl_chkIfUpdate( l_curGDC, l_newGDC ) THEN
		RETURN
	END IF

-- Does the autoupdate.zip file exist
	IF NOT gl_gdcupd.gl_getUpdateFileName(l_newGDC, l_gdcBuild, l_gdcos) THEN
		LET m_ret.upd_url = fgl_getEnv("GDCREMOTESERVER")
	END IF

	DISPLAY "Upd File:",m_ret.upd_file," URL:",m_ret.upd_url
END FUNCTION