-- GDCUPDATEURL is the url for the Genero App server to fetch the zip file
-- if the server is not the same machine.

IMPORT com
IMPORT util
IMPORT os
IMPORT FGL gl_lib_restful
IMPORT FGL gl_lib_gdcupd

MAIN
  DEFINE l_ret INTEGER
  DEFINE l_req com.HTTPServiceRequest
  DEFINE l_str STRING
  DEFINE l_quit BOOLEAN
  DEFER INTERRUPT

  IF NOT gl_lib_gdcupd.gl_validGDCUpdateDir() THEN -- sets m_gdcUpdateDir
    DISPLAY gl_lib_gdcupd.m_ret.reply
    EXIT PROGRAM
  END IF

  DISPLAY "GDC UpdateDir:", gl_lib_gdcupd.m_gdcUpdateDir, " URL:", gl_lib_gdcupd.m_ret.upd_url

  DISPLAY "Starting server..."
  #
  # Starts the server on the port number specified by the FGLAPPSERVER environment variable
  #  (EX: FGLAPPSERVER=8090)
  #
  TRY
    CALL com.WebServiceEngine.Start()
    DISPLAY "The server is listening."
  CATCH
    DISPLAY STATUS, ":", err_get(STATUS)
    EXIT PROGRAM
  END TRY

  WHILE NOT l_quit
    TRY
      # create the server
      LET l_req = com.WebServiceEngine.getHTTPServiceRequest(-1)
      CALL gl_lib_restful.gl_getReqInfo(l_req)

      DISPLAY "Processing request, Method:",
          gl_lib_restful.m_reqInfo.method,
          " Path:",
          gl_lib_restful.m_reqInfo.path,
          " format:",
          gl_lib_restful.m_reqInfo.outformat
      -- parse the url, retrieve the operation and the operand
      CASE gl_lib_restful.m_reqInfo.method
        WHEN "GET"
          CASE
            WHEN gl_lib_restful.m_reqInfo.path.equalsIgnoreCase("chkgdc")
              CALL gdcchk()
            WHEN gl_lib_restful.m_reqInfo.path.equalsIgnoreCase("restart")
              CALL gl_lib_gdcupd.gl_setReply(200, % "OK", % "Service Exiting")
              LET l_quit = TRUE
            OTHERWISE
              CALL gl_lib_gdcupd.gl_setReply(
                  201, % "ERR", SFMT(% "Operation '%1' not found", gl_lib_restful.m_reqInfo.path))
          END CASE
          DISPLAY "Reply:", gl_lib_gdcupd.m_ret.reply
          LET l_str = util.JSON.stringify(gl_lib_gdcupd.m_ret)
        OTHERWISE
          CALL gl_lib_restful.gl_setError(
              "Unknown request:\n" || gl_lib_restful.m_reqInfo.path || "\n" || gl_lib_restful.m_reqInfo.method)
          LET gl_lib_restful.m_err.code = -3
          LET gl_lib_restful.m_err.desc =
              SFMT(% "Method '%' not supported", gl_lib_restful.m_reqInfo.method)
          LET l_str = util.JSON.stringify(gl_lib_restful.m_err)
      END CASE
      -- send back the response.
      CALL l_req.setResponseHeader("Content-Type", "application/json")
      CALL l_req.sendTextResponse(200, % "OK", l_str)
      IF int_flag != 0 THEN
        LET int_flag = 0
        EXIT WHILE
      END IF
    CATCH
      LET l_ret = STATUS
      CASE l_ret
        WHEN -15565
          DISPLAY "Disconnected from application server."
          EXIT WHILE
        OTHERWISE
          DISPLAY "[ERROR] " || l_ret
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

  LET x = gl_lib_restful.gl_getParameterIndex("ver")
  IF x = 0 THEN
    CALL gl_lib_gdcupd.gl_setReply(201, % "ERR", % "Missing parameter 'ver'!")
    RETURN
  END IF
  LET x = gl_lib_restful.gl_getParameterIndex("os")
  IF x = 0 THEN
    CALL gl_lib_gdcupd.gl_setReply(202, % "ERR", % "Missing parameter 'os'!")
    RETURN
  END IF
  LET l_curGDC = gl_lib_restful.gl_getParameterValue(1)
  IF l_curGDC.getIndexOf(".", 1) < 1 THEN
    CALL gl_lib_gdcupd.gl_setReply(
        203, % "ERR", SFMT(% "Expected GDC version x.xx.xx got '%1'!", l_curGDC))
    RETURN
  END IF
  LET l_gdcos = gl_lib_restful.gl_getParameterValue(2)
  IF l_gdcos.getLength() < 1 THEN
    CALL gl_lib_gdcupd.gl_setReply(
        204, % "ERR", SFMT(% "Expected GDC OS is invalid '%1'!", l_gdcos))
    RETURN
  END IF

-- Get the new GDC version from the directory structure
  CALL gl_lib_gdcupd.gl_getCurrentGDC() RETURNING l_newGDC, l_gdcBuild
  IF l_newGDC IS NULL THEN
    RETURN
  END IF

-- URL To the web server for the GDC Update file zips
  LET gl_lib_gdcupd.m_ret.upd_url = getUpdateURL(fgl_getenv("GDCUPDATEURL"))

-- is the 'current' GDC > than the one passed to us?
  IF NOT gl_lib_gdcupd.gl_chkIfUpdate(l_curGDC, l_newGDC) THEN
    RETURN
  END IF

-- Does the autoupdate.zip file exist
  IF NOT gl_lib_gdcupd.gl_getUpdateFileName(l_newGDC, l_gdcBuild, l_gdcos) THEN
    LET gl_lib_gdcupd.m_ret.upd_url = fgl_getenv("GDCREMOTESERVER")
  END IF

  DISPLAY "Upd File:", gl_lib_gdcupd.m_ret.upd_file, " URL:", gl_lib_gdcupd.m_ret.upd_url
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getUpdateURL(l_url STRING) RETURNS STRING
  DEFINE x SMALLINT
  LET x = l_url.getIndexOf("^", 1)
  IF x > 1 THEN
    LET l_url =
        l_url.subString(1, x - 1),
        gl_lib_restful.m_reqInfo.host,
        l_url.subString(x + 1, l_url.getLength())
  END IF
  RETURN l_url
END FUNCTION
--------------------------------------------------------------------------------
