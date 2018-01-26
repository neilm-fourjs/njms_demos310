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
							CALL setReply(200,%"OK",%"Service Exiting")
							LET l_quit = TRUE
						OTHERWISE
							CALL setReply(201,%"ERR",SFMT(%"Operation '%1' not found",gl_restful_lib.m_reqInfo.path))
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
	DEFINE l_gdcVer, l_gdcBuild, l_gdcOS STRING
	DEFINE l_major, l_new_maj DECIMAL(4,2)
	DEFINE l_minor, l_new_min SMALLINT
	DEFINE l_updFile STRING

	LET x = gl_restful_lib.getParameterIndex("ver") 
	IF x = 0 THEN
		CALL setReply(201,%"ERR",%"Missing parameter 'ver'!")
		RETURN
	END IF
	LET x = gl_restful_lib.getParameterIndex("os") 
	IF x = 0 THEN
		CALL setReply(202,%"ERR",%"Missing parameter 'os'!")
		RETURN
	END IF
	CALL gl_gdcupd.getVer( gl_restful_lib.getParameterValue(1) ) RETURNING l_major, l_minor
	IF l_major = 0 THEN
		CALL setReply(203,%"ERR",SFMT(%"Expected GDC version x.xx.xx got '%1'!",gl_restful_lib.getParameterValue(1)))
		RETURN
	END IF
	LET l_gdcos = gl_restful_lib.getParameterValue(2)
	IF l_gdcos.getLength() < 1 THEN
		CALL setReply(204,%"ERR",SFMT(%"Expected GDC OS is invalid '%1'!",l_gdcos))
		RETURN
	END IF
	
	CALL gl_gdcupd.getCurrentGDC() RETURNING l_gdcVer, l_gdcBuild
	IF l_gdcVer IS NULL THEN
		CALL setReply(205,%"ERR", l_gdcBuild)
		RETURN
	END IF

	CALL gl_gdcupd.getVer( l_gdcVer ) RETURNING l_new_maj, l_new_min
	IF l_new_maj = 0 THEN
		CALL setReply(210,%"ERR",SFMT(%"Current GDC Version is not correct format '%1'!",l_gdcver))
		RETURN
	END IF

	IF l_new_maj = l_major AND l_new_min = l_minor THEN
		CALL setReply(0,%"OK",%"GDC is current version")
		RETURN
	END IF

-- Is the GDC version older than the requesting GDC
	IF l_new_maj > l_major THEN
		CALL setReply(1,%"OK",SFMT(%"There is new GDC major release available: %1",l_gdcver))
	END IF
	IF l_new_maj = l_major OR l_new_min > l_minor THEN
		CALL setReply(1,%"OK",SFMT(%"There is new GDC minor release available: %1",l_gdcver))
	END IF

-- Does the autoupdate.zip file exist
	LET l_updFile = "fjs-gdc-"||l_gdcVer||"-"||l_gdcBuild||"-"||l_gdcos||"-autoupdate.zip"
	IF NOT os.path.exists( os.path.join(m_gdcUpdateDir,l_updFile) ) THEN
		CALL setReply(211,%"ERR",SFMT(%"GDC Update File '%1' is Missing!",l_updFile))
		RETURN
	END IF

	IF m_ret.stat = 0 THEN
		RETURN
	END IF

	LET m_ret.upd_dir = m_gdcUpdateDir
	LET m_ret.upd_file = l_updFile
	DISPLAY "Upd File:",m_ret.upd_file
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION setReply(l_stat INT, l_txt STRING, l_msg STRING)
	LET m_ret.stat = l_stat
	LET m_ret.txt = l_txt
	LET m_ret.reply = l_msg
END FUNCTION