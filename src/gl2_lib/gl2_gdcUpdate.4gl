# Library functions for GDC Auto Update.
IMPORT os
IMPORT com
IMPORT util

IMPORT FGL gl2_lib
IMPORT FGL gl2_lib_aui
IMPORT FGL gl2_lib_gdcUpdate
&include "gl2_debug.inc"

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
FUNCTION gl2_gdcUpate()
  DEFINE l_updServer STRING
  DEFINE l_curGDC, l_os, l_osTarget, l_tmp, l_localFile, l_newFile STRING
  DEFINE l_newGDC, l_newGDCBuild STRING
  DEFINE x SMALLINT
  DEFINE l_stat SMALLINT
  DEFINE l_ret SMALLINT

  IF DOWNSHIFT(ui.Interface.getFrontEndName()) != "gdc" THEN
    RETURN
  END IF

  LET l_curGDC = ui.Interface.getFrontEndVersion()
  LET x = l_curGDC.getIndexOf("-", 1)
  IF x < 5 THEN
    CALL gl2_lib.gl2_winMessage(
        "Error", SFMT(% "Invalid GDC Version error '%1'!", l_curGDC), "exclamation")
    RETURN
  END IF
  LET l_curGDC = l_curGDC.subString(1, x - 1)
  CALL ui.Interface.frontCall("standard", "feinfo", "target", l_osTarget)

  IF NOT gl2_lib_gdcUpdate.gl2_validGDCUpdateDir() THEN
    DISPLAY gl2_lib_gdcUpdate.m_ret.stat_txt, ":", gl2_lib_gdcUpdate.m_ret.reply
    RETURN
  END IF

-- Do we have an update server defined?
  LET l_updServer = fgl_getenv("GDCUPDATESERVER")
  IF l_updServer.getLength() > 1 THEN
    CALL useGDCUpdateWS(l_updServer || "/chkgdc?ver=" || l_curGDC || "&os=" || l_osTarget)
  ELSE -- no update server, try a local update
    CALL gl2_lib_gdcUpdate.gl2_getCurrentGDC() RETURNING l_newGDC, l_newGDCBuild
    IF NOT gl2_lib_gdcUpdate.gl2_chkIfUpdate(l_curGDC, l_newGDC) THEN
      RETURN
    END IF
    IF NOT gl2_lib_gdcUpdate.gl2_getUpdateFileName(l_newGDC, l_newGDCBuild, l_osTarget) THEN
      RETURN
    END IF
  END IF

  DISPLAY "Stat:",
      l_stat,
      " Reply:",
      gl2_lib_gdcUpdate.m_ret.reply,
      " ReplyStat:",
      gl2_lib_gdcUpdate.m_ret.stat
  IF gl2_lib_gdcUpdate.m_ret.stat != 1 THEN
    RETURN
  END IF

-- We have a new GDC Update ! confirm with user
  IF gl2_lib.gl2_winQuestion(
              "GDC Update",
              SFMT(% "%1\nUpdate Now?", gl2_lib_gdcUpdate.m_ret.reply),
              "Yes",
              "Yes|No",
              "question")
          = "No"
      THEN
    RETURN
  END IF

  CALL gl2_lib_aui.gl2_notify(SFMT(% "%1\nPreparing\nPlease Wait ...", gl2_lib_gdcUpdate.m_ret.reply))

-- does the GDC update file exist on our server
  LET l_localFile = os.path.join(gl2_lib_gdcUpdate.m_gdcUpdateDir, gl2_lib_gdcUpdate.m_ret.upd_file)
  IF NOT os.path.exists(l_localFile) THEN
    IF gl2_lib_gdcUpdate.m_ret.upd_url IS NOT NULL THEN
      CALL gl2_lib_aui.gl2_notify(
          SFMT(% "%1\nServer Downloading Update File\nPlease Wait ...", gl2_lib_gdcUpdate.m_ret.reply))
      IF NOT getGDCUpdateZipFile(
              l_localFile, gl2_lib_gdcUpdate.m_ret.upd_url, gl2_lib_gdcUpdate.m_ret.upd_file)
          THEN
        CALL abortGDCUpdate(SFMT(% "Getting GDC Update file failed!\nFile:%1", l_localFile))
        RETURN
      END IF
    ELSE
      CALL abortGDCUpdate(SFMT(% "The GDC Update file is missing!\nFile:%1", l_localFile))
      RETURN
    END IF
  END IF

-- we have a new GDC to update to - a client temp folder name
  CALL ui.Interface.frontcall("standard", "feinfo", "ostype", [l_os])
  CALL ui.Interface.frontcall("standard", "getenv", ["TEMP"], [l_tmp])
  IF l_os = "WINDOWS" THEN
    IF l_tmp.getLength() < 2 THEN
      LET l_tmp = "C:\\TEMP"
    END IF
    LET l_tmp = l_tmp.append("\\")
  ELSE
    IF l_tmp.getLength() < 2 THEN
      LET l_tmp = "/tmp"
    END IF
    LET l_tmp = l_tmp.append("/")
  END IF

-- Put the local GDC update file to the client
  LET l_newFile = l_tmp || gl2_lib_gdcUpdate.m_ret.upd_file
  DISPLAY "Put:", l_localFile, " to ", l_newFile
  CALL gl2_lib_aui.gl2_notify(
      SFMT(% "%1\nClient Downloading Update File\nPlease Wait ...", gl2_lib_gdcUpdate.m_ret.reply))
  TRY
    CALL fgl_putfile(l_localFile, l_tmp || gl2_lib_gdcUpdate.m_ret.upd_file)
  CATCH
    CALL abortGDCUpdate(
        SFMT(% "Copy of GDC auto update file failed!\nSource:%1\nDest:%2\nErr:%3",
            os.path.join(gl2_lib_gdcUpdate.m_ret.upd_dir, gl2_lib_gdcUpdate.m_ret.upd_file),
            l_newFile,
            err_get(STATUS)))
    RETURN
  END TRY

  CALL gl2_lib_aui.gl2_notify("")

-- Trigger the GDC update
  CALL ui.Interface.frontCall("monitor", "update", [l_newFile], [l_ret])
  IF l_ret != 0 THEN
    CALL abortGDCUpdate("GDC Autoupdate Failed!")
  END IF
END FUNCTION
--------------------------------------------------------------------------------
-- Do the web service REST call to check for a new GDC
PRIVATE FUNCTION abortGDCUpdate(l_msg STRING)
  CALL gl2_lib_aui.gl2_notify("")
  CALL gl2_lib.gl2_winMessage(% "Error", l_msg, "exclamation")
END FUNCTION
--------------------------------------------------------------------------------
-- Do the web service REST call to check for a new GDC
PRIVATE FUNCTION useGDCUpdateWS(l_url STRING)
  DEFINE l_req com.HttpRequest
  DEFINE l_resp com.HttpResponse
  DEFINE l_stat SMALLINT
  DISPLAY "useGDCUpdateWS URL:", l_url
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
      CALL util.JSON.parse(l_resp.getTextResponse(), gl2_lib_gdcUpdate.m_ret)
    ELSE
      CALL abortGDCUpdate(
          SFMT("WS chkgdc call failed!\n%1\n%1-%2", l_url, l_stat, l_resp.getStatusDescription()))
    END IF
  CATCH
    LET l_stat = STATUS
    LET gl2_lib_gdcUpdate.m_ret.reply = err_get(l_stat)
  END TRY
END FUNCTION
--------------------------------------------------------------------------------
-- get the zip file from a remote server
PRIVATE FUNCTION getGDCUpdateZipFile(
    l_localFile STRING, l_url STRING, l_file STRING)
    RETURNS BOOLEAN
  DEFINE l_cmd STRING

  MESSAGE "Getting GDC zip from " || l_url || "  Please wait ... "
  CALL ui.interface.refresh()

  LET l_cmd = "wget -q -O " || l_localFile || " " || l_url || "/" || l_file
  RUN l_cmd

  IF os.Path.exists(l_localFile) THEN
    RETURN TRUE
  END IF
  RETURN FALSE
END FUNCTION