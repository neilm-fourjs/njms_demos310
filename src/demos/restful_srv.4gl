IMPORT com
IMPORT util 
IMPORT FGL gl_lib_restful

CONSTANT ERR_OPERATION	  = "Operation not found"
CONSTANT ERR_METHOD		 = "Method not supported"

TYPE t_myReply RECORD
		stat SMALLINT,
		txt STRING,
		reply STRING
	END RECORD

MAIN
  DEFINE l_ret INTEGER
  DEFINE l_req com.HTTPServiceRequest
  DEFINE l_reply t_myReply
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
		DISPLAY STATUS,":",ERR_GET(STATUS)
		EXIT PROGRAM
	END TRY

  WHILE TRUE
	  TRY
  		# create the server
		  LET l_req = com.WebServiceEngine.getHTTPServiceRequest(-1)
		  CALL gl_lib_restful.gl_getReqInfo(l_req)

		  DISPLAY "Processing request, Method:", gl_lib_restful.m_reqInfo.method, " Path:", gl_lib_restful.m_reqInfo.path, " format:", gl_lib_restful.m_reqInfo.outformat
		  -- parse the url, retrieve the operation and the operand
		  CASE gl_lib_restful.m_reqInfo.method
			  WHEN "GET"
					CASE
						WHEN gl_lib_restful.m_reqInfo.path.equalsIgnoreCase("/ginfo") 
							CALL ginfo() RETURNING l_reply.*
						OTHERWISE
							LET l_reply.reply = ERR_OPERATION
							LET l_reply.stat = 201
							LET l_reply.txt = "ERR"
					END CASE
					LET l_str = util.JSON.stringify(l_reply)
			  OTHERWISE
					CALL gl_lib_restful.gl_setError("Unknown request:\n"||m_reqInfo.path||"\n"||m_reqInfo.method)
					LET gl_lib_restful.m_err.code = -3
					LET gl_lib_restful.m_err.desc = ERR_METHOD
					LET l_str = util.JSON.stringify(m_err)
		  END CASE
			-- send back the response.
			CALL l_req.setResponseHeader("Content-Type","application/json")
			CALL l_req.sendTextResponse(200, "OK", l_str)
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
END MAIN
--------------------------------------------------------------------------------
FUNCTION ginfo()
	DEFINE x SMALLINT
	DEFINE l_ret t_myReply
	LET x = gl_lib_restful.gl_getParameterIndex("fgl") 
	IF x > 0 THEN
		LET l_ret.reply =  "Param 'fgl' = ",gl_lib_restful.gl_getParameterValue(x)
		LET l_ret.txt = "OK"
		LET l_ret.stat = 200
	ELSE
		LET l_ret.reply = "Missing parameters!"
		LET l_ret.txt = "ERR"
		LET l_ret.stat = 202
	END IF
	RETURN l_ret.*
END FUNCTION