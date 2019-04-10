
--------------------------------------------------------------------------------
#+ Genero Genero Library Functions - by Neil J Martin ( neilm@4js.com )
#+ This library is intended as an example of useful library code for use with
#+ Genero 3.20 and above
#+
#+ No warrantee of any kind, express or implied, is included with this software;
#+ use at your own risk, responsibility for damages (if any) to anyone resulting
#+ from the use of this software rests entirely with the user.
#+
#+ No includes required.

IMPORT os
IMPORT util

&define GL_DBGMSG( lev, msg ) \
	CALL gl2_dbgMsg( __FILE__, __LINE__, lev, NVL(msg,"NULL!"))

GLOBALS
	DEFINE gl_dbgLev SMALLINT
END GLOBALS

--------------------------------------------------------------------------------
#+ Generic Windows message Dialog.  NOTE: This handles messages when there is 
#+ no window!
#+
#+ @param l_title     = Window Title
#+ @param l_message   = Message text
#+ @param l_icon      = Icon name, "exclamation"
#+ @return none
FUNCTION gl2_winMessage(l_title STRING, l_message STRING, l_icon STRING) RETURNS ()
	DEFINE l_win ui.window
	IF l_title IS NULL THEN LET l_title = "No Title!" END IF
	IF l_message IS NULL THEN
		LET l_message = "Message was NULL!!\n"||base.Application.getStackTrace()
	END IF

	LET l_win = ui.window.getcurrent()
	IF l_win IS NULL THEN -- Needs a current window or dialog doesn't work!!
		OPEN WINDOW dummy AT 1,1 WITH 1 ROWS, 1 COLUMNS
	END IF
	IF l_icon = "exclamation" THEN ERROR "" END IF -- Beep

	GL_DBGMSG(2, "gl_winMessage: "||NVL(l_message,"gl_winMessage passed NULL!"))
	MENU l_title ATTRIBUTES(STYLE="dialog",COMMENT=l_message, IMAGE=l_icon)
		COMMAND "Okay" EXIT MENU
	END MENU

	IF l_win IS NULL THEN
		CLOSE WINDOW dummy
	END IF

END FUNCTION
--------------------------------------------------------------------------------
#+ Generic Windows Question Dialog
#+
#+ @param l_title Window Title
#+ @param l_message Message text
#+ @param l_ans   Default Answer
#+ @param l_items List of Answers ie "Yes|No|Cancel"
#+ @param l_icon  Icon name, "exclamation"
#+ @return string: Entered value.
FUNCTION gl2_winQuestion(l_title STRING, 
												l_message STRING, 
												l_ans STRING, 
												l_items STRING, 
												l_icon STRING) RETURNS STRING
	DEFINE l_result STRING
	DEFINE l_toks base.STRINGTOKENIZER
	DEFINE l_dum BOOLEAN
	DEFINE l_opt DYNAMIC ARRAY OF STRING
	DEFINE x SMALLINT

	LET l_icon = l_icon.trim()
	LET l_title = l_title.trim()
	LET l_message = l_message.trim()
	LET l_icon = l_icon.trim()
	IF l_icon = "info" THEN LET l_icon = "information" END IF

	LET l_toks = base.StringTokenizer.create(l_items,"|")
	IF NOT l_toks.hasMoreTokens() THEN RETURN NULL END IF
	WHILE l_toks.hasMoreTokens()
		LET l_opt[ l_opt.getLength() + 1 ] = l_toks.nextToken()
	END WHILE

	-- Handle the case when there is no current window
	LET l_dum = FALSE
	IF ui.window.getCurrent() IS NULL THEN
		OPEN WINDOW dummy AT 1,1 WITH 1 ROWS, 2 COLUMNS ATTRIBUTE(STYLE="naked")
		CALL fgl_settitle(l_title)
		LET l_dum = TRUE
	END IF

	MENU l_title ATTRIBUTE(STYLE="dialog", COMMENT=l_message, IMAGE=l_icon)
		BEFORE MENU
			HIDE OPTION ALL
			FOR x = 1 TO l_opt.getLength()
				IF l_opt[x] IS NOT NULL THEN
					SHOW OPTION l_opt[x]
					IF l_ans.equalsIgnoreCase(l_opt[x]) THEN
						NEXT OPTION l_opt[x]
					END IF
				END IF
			END FOR
		COMMAND l_opt[1]	LET l_result = l_opt[1]
		COMMAND l_opt[2]	LET l_result = l_opt[2]
		COMMAND l_opt[3]	LET l_result = l_opt[3]
		COMMAND l_opt[4]	LET l_result = l_opt[4]
		COMMAND l_opt[5]	LET l_result = l_opt[5]
		COMMAND l_opt[6]	LET l_result = l_opt[6]
		COMMAND l_opt[7]	LET l_result = l_opt[7]
		COMMAND l_opt[8]	LET l_result = l_opt[8]
		COMMAND l_opt[9]	LET l_result = l_opt[9]
		COMMAND l_opt[10]	LET l_result = l_opt[10]
	END MENU
	IF l_dum THEN CLOSE WINDOW dummy END IF
	RETURN l_result
END FUNCTION
--------------------------------------------------------------------------------
#+ Simple error message
#+
#+ @return Nothing.
FUNCTION gl2_errPopup(l_msg STRING)
  CALL gl2_winMessage(%"Error!",l_msg,"exclamation")
END FUNCTION
--------------------------------------------------------------------------------
#+ Display an error message in a window, console & logfile.
#+
#+ @param l_fil __FILE__ - File name
#+ @param l_lno __LINE__ - Line Number
#+ @param l_err Error Message.
#+ @return Nothing.
FUNCTION gl2_errMsg( l_fil STRING, l_lno INT, l_err STRING)

	CALL gl2_errPopup(l_err)
	ERROR "* ",l_err.trim()," *"
	IF l_fil IS NOT NULL THEN
		DISPLAY l_fil.trim(),":",l_lno,": ",l_err.trim()
		CALL ERRORLOG(l_fil.trim()||":"||l_lno||": "||l_err)
	END IF

END FUNCTION
--------------------------------------------------------------------------------
#+ Cleanly exit program, setting exit status.
#+
#+ @param stat Exit status 0 or -1 normally.
#+ @param reason For Exit, clean, crash, closed, terminated etc
#+ @return none
FUNCTION gl2_exitProgram( l_stat SMALLINT, l_reason STRING )
	GL_DBGMSG(0, SFMT("gl2_exitProgram: stat=%1 reason:%2",l_stat,l_reason))
	EXIT PROGRAM l_stat
END FUNCTION
--------------------------------------------------------------------------------
#+ On Application Close
FUNCTION gl2_appClose()
	GL_DBGMSG(1,"gl2_appClose")
	CALL gl2_exitProgram(0, "Closed")
END FUNCTION
--------------------------------------------------------------------------------
#+ On Application Terminalate ( kill -15 )
FUNCTION gl2_appTerm()
	GL_DBGMSG(1,"gl2_appTerm")
	TRY
		ROLLBACK WORK
	CATCH
	END TRY
	CALL gl2_exitProgram(0, "Terminated")
END FUNCTION
--------------------------------------------------------------------------------
-- Break the Version string into major and minor
FUNCTION gl2_getVer( l_str STRING ) RETURNS (DECIMAL(4,2), INT)
	DEFINE l_major DECIMAL(4,2)
	DEFINE l_minor SMALLINT
	DEFINE l_st base.StringTokenizer
	LET l_minor = l_str.getIndexOf("-",1)
	IF l_minor > 0 THEN LET l_str = l_str.subString(1,l_minor-1) END IF
	LET l_st = base.StringTokenizer.create(l_str,".")
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
#+ Default error handler
#+
#+ @return Nothing
FUNCTION gl2_error()
  DEFINE l_err,l_mod STRING
  DEFINE l_stat INTEGER
  DEFINE x,y SMALLINT

  LET l_stat = STATUS

  LET l_mod = base.Application.getStackTrace()
  LET x = l_mod.getIndexOf("#",2) + 3
  LET y = l_mod.getIndexOf("#",x+1) - 1
  LET l_mod = l_mod.subString(x,y)
  IF y < 1 THEN LET y = l_mod.getLength() END IF
  LET l_mod = l_mod.subString(x,y)
  IF l_mod IS NULL THEN
		GL_DBGMSG(0,"failed to get module from stackTrace!\n"||base.Application.getStackTrace())
		LET l_mod = "(null module)"
	END IF

  LET l_err = SQLERRMESSAGE||"\n"
  IF l_err IS NULL THEN LET l_err = ERR_GET(l_stat) END IF
  IF l_err IS NULL THEN LET l_err = "Unknown!" END IF
  LET l_err = l_stat||":"||l_err||l_mod
--  CALL gl_logIt("Error:"||l_err)
	IF l_stat != -6300 THEN CALL gl2_errPopup(l_err) END IF

END FUNCTION
--------------------------------------------------------------------------------
#+ Display debug messages to console.
#+
#+ @param fil __FILE__ - File name
#+ @param lno __LINE__ - Line Number
#+ @param lev Level of debug
#+ @param msg Message
#+ @return Nothing.
FUNCTION gl2_dbgMsg( l_fil STRING, l_lno INT, l_lev STRING, l_msg STRING)
	DEFINE l_lin CHAR(22)
	DEFINE x SMALLINT

	IF gl_dbgLev = 0 AND l_lev = 0 THEN
		DISPLAY base.Application.getProgramName(),":",l_msg.trim()
	ELSE
		IF gl_dbgLev >= l_lev THEN
			LET l_fil = os.path.basename( l_fil )
			LET x = l_fil.getIndexOf(".",1)
			LET l_fil = l_fil.subString(1,x-1)
			LET l_lin = "...............:",l_lno USING "##,###"
			LET x = l_fil.getLength()
			IF x > 22 THEN LET x = 22 END IF
			LET l_lin[1,x] = l_fil.trim()
			DISPLAY l_lin,":",l_lev USING "<<&",": ",l_msg.trim()
			CALL ERRORLOG(l_lin||":"||(l_lev USING "<<&")||": "||l_msg.trim())
		END IF
	END IF

END FUNCTION
--------------------------------------------------------------------------------
#+ Get the product version from the $FGLDIR/etc/fpi-fgl
#+ @param l_prod String of product name, eg: fglrun
#+ @return String or NULL
FUNCTION gl2_getProductVer( l_prod STRING ) RETURNS STRING
	DEFINE l_file base.channel
	DEFINE l_line STRING
	LET l_file = base.channel.create()
	CALL l_file.openPipe( "fpi -l", "r")
	WHILE NOT l_file.isEof()
		LET l_line = l_file.readLine()
		IF l_line.getIndexOf(l_prod, 1) > 0 THEN
			LET l_line = l_line.subString(8,l_line.getLength() - 1 )
			EXIT WHILE
		END IF
	END WHILE
	CALL l_file.close()
	RETURN l_line
END FUNCTION
--------------------------------------------------------------------------------
#+ Attempt to convert a String to a date
#+
#+ @param l_str A string containing a date
#+ @returns DATE or NULL
FUNCTION gl2_strToDate(l_str STRING) RETURNS DATE
	DEFINE l_date DATE
	TRY
		LET l_date = l_str
	CATCH
	END TRY
	IF l_date IS NOT NULL THEN RETURN l_date END IF
	LET l_date = util.Date.parse(l_str,"dd/mm/yyyy")
	RETURN l_date
END FUNCTION
--------------------------------------------------------------------------------
#+ Return the result from the uname commend on Unix / Linux / Mac.
#+
#+ @return uname of the OS
FUNCTION gl2_getUname() RETURNS STRING
	DEFINE l_uname STRING
	DEFINE c base.channel
	LET c = base.channel.create()
	CALL c.openPipe("uname","r")
	LET l_uname = c.readLine()
	CALL c.close()
	RETURN l_uname
END FUNCTION
--------------------------------------------------------------------------------
#+ Return the Linux Version
#+
#+ @return OS Version
FUNCTION gl2_getLinuxVer() RETURNS STRING
	DEFINE l_ver STRING
	DEFINE c base.channel
	DEFINE l_file DYNAMIC ARRAY OF STRING
	DEFINE x SMALLINT

-- possible files containing version info
	LET l_file[ l_file.getLength() + 1 ] = "/etc/issue.net"
	LET l_file[ l_file.getLength() + 1 ] = "/etc/issue"
	LET l_file[ l_file.getLength() + 1 ] = "/etc/debian_version"
	LET l_file[ l_file.getLength() + 1 ] = "/etc/SuSE-release"

-- loop thru and see which ones exist
	FOR x = 1 TO l_file.getLength() + 1
		IF l_file[x] IS NULL THEN RETURN "Unknown" END IF
		IF os.Path.exists(l_file[x]) THEN
			EXIT FOR
		END IF
	END FOR

-- read the first line of existing file
	LET c = base.channel.create()
	CALL c.openFile(l_file[x],"r")
	LET l_ver = c.readLine()
	CALL c.close()
	RETURN l_ver
END FUNCTION
--------------------------------------------------------------------------------
#+ Gets sourcefile.module:line from a stacktrace.
#+
#+ @return sourcefile.module:line
FUNCTION gl2_getCallingModuleName() RETURNS STRING
	DEFINE l_fil,l_mod,l_lin STRING
	DEFINE x,y SMALLINT
	LET l_fil = base.Application.getStackTrace()
	IF l_fil IS NULL THEN
		DISPLAY "Failed to get getStackTrace!!"
		RETURN "getStackTrace-failed!"
	END IF

	LET x = l_fil.getIndexOf("#",2) -- skip passed this func
	LET x = l_fil.getIndexOf("#",x+1) -- skip passed func that called this func
	LET x = l_fil.getIndexOf(" ",x) + 1
	LET y = l_fil.getIndexOf("(",x) - 1
	LET l_mod = l_fil.subString(x,y)

	LET x = l_fil.getIndexOf(" ",y) + 4
	LET y = l_fil.getIndexOf("#",x+1) - 2
	IF y < 1 THEN LET y = (l_fil.getLength() - 1) END IF
	LET l_fil = l_fil.subString(x,y)

	-- strip the .4gl from the fil name
	LET x = l_fil.getIndexOf(".",1)
	IF x > 0 THEN
		LET y = l_fil.getIndexOf(":",x)
		LET l_lin = l_fil.subString(y+1,l_fil.getLength())
		LET l_fil = l_fil.subString(1,x-1)
	END IF

	LET l_fil = NVL(l_fil,"FILE?")||"."||NVL(l_mod,"MOD?")||":"||NVL(l_lin,"LINE?")
	RETURN l_fil
END FUNCTION