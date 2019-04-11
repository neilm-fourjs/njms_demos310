IMPORT com
IMPORT util
IMPORT xml
IMPORT FGL gl_lib_restful

CONSTANT ERR_OPERATION = "Operation not found"
CONSTANT ERR_METHOD = "Method not supported"

TYPE t_myReply RECORD
  stat SMALLINT,
  txt STRING,
  reply STRING
END RECORD

MAIN
  DEFINE l_ret INTEGER
  DEFINE l_req com.HTTPServiceRequest
  DEFINE l_reply t_myReply
  DEFINE l_xml_doc xml.DomDocument
  DEFINE l_str STRING
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
    DISPLAY STATUS, ":", err_get(STATUS)
    EXIT PROGRAM
  END TRY

  WHILE TRUE
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
            WHEN gl_lib_restful.m_reqInfo.path.equalsIgnoreCase("ginfo")
              CALL ginfo() RETURNING l_reply.*
            WHEN gl_lib_restful.m_reqInfo.path.equalsIgnoreCase("err422")
              LET l_reply.reply = ERR_OPERATION
              LET l_reply.stat = 422
              LET l_reply.txt = "Test reply for UNPROCESSABLE ENTITY"
              LET l_xml_doc = xml_err(l_reply.stat, l_reply.txt)
            OTHERWISE
              DISPLAY "Setting XML err for invalid request"
              LET l_reply.reply = ERR_OPERATION
              LET l_reply.stat = 400
              LET l_reply.txt = "You supplied an invalid request, expected 'ginfo'"
              LET l_xml_doc = xml_err(l_reply.stat, l_reply.txt)
          END CASE
          LET l_str = util.JSON.stringify(l_reply)
        OTHERWISE
          DISPLAY "Not GET!"
          CALL gl_lib_restful.gl_setError(
              "Unknown request:\n" || gl_lib_restful.m_reqInfo.path || "\n" || gl_lib_restful.m_reqInfo.method)
          LET gl_lib_restful.m_err.code = -3
          LET gl_lib_restful.m_err.desc = ERR_METHOD
          LET l_str = util.JSON.stringify(gl_lib_restful.m_err)
      END CASE
      -- send back the response.
      IF l_reply.stat < 400 THEN
        DISPLAY "Attempting to send text response..."
        CALL l_req.setResponseHeader("Content-Type", "application/'")
        CALL l_req.sendTextResponse(l_reply.stat, l_reply.reply, l_str)
      ELSE
        DISPLAY "Attempting to send xml response..."
        CALL l_req.setResponseHeader("Content-Type", "application/xml")
        CALL l_req.sendXmlResponse(l_reply.stat, l_reply.reply, l_xml_doc)
      END IF
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
          DISPLAY "[ERROR] " || l_ret || " - " || err_get(l_ret)
          EXIT WHILE
      END CASE
    END TRY
  END WHILE
END MAIN
--------------------------------------------------------------------------------
FUNCTION xml_err(l_stat SMALLINT, l_txt STRING)
  DEFINE l_xml_doc xml.DomDocument
  DEFINE l_xml_node, l_xml_root xml.DomNode
  LET l_xml_doc = xml.DomDocument.CreateDocument("Reason")
  LET l_xml_root = l_xml_doc.getDocumentElement()
  LET l_xml_node = l_xml_doc.createElement("desc")
  CALL l_xml_root.appendChild(l_xml_node)
  CALL l_xml_node.setAttribute("status", l_stat)
  CALL l_xml_node.setAttribute("text", l_txt)
  RETURN l_xml_doc
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION ginfo()
  DEFINE x SMALLINT
  DEFINE l_ret t_myReply
  DISPLAY "Processing ginfo ..."
  LET x = gl_lib_restful.gl_getParameterIndex("fgl")
  IF x > 0 THEN
    LET l_ret.reply = "Param 'fgl' = ", gl_lib_restful.gl_getParameterValue(x)
    LET l_ret.txt = "OK"
    LET l_ret.stat = 200
  ELSE
    LET l_ret.reply = "Missing parameters!"
    LET l_ret.txt = "ERR"
    LET l_ret.stat = 202
  END IF
  RETURN l_ret.*
END FUNCTION
