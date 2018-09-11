
IMPORT JAVA com.fourjs.ggc.fgl.Application
IMPORT JAVA com.fourjs.ggc.fgl.Session
IMPORT JAVA com.fourjs.ggc.util.Log
IMPORT JAVA java.lang.String

MAIN

	CALL testSession("http://localhost/g/ua/r/njmdemo")

END MAIN
--------------------------------------------------------------------------------
FUNCTION testSession(l_url STRING)
	DEFINE s            Session
	DEFINE app          Application
	DEFINE childApp     Application
	DEFINE sLog         Log
	DEFINE aLog         Log
	DEFINE l_msg				STRING
	DEFINE l_appName		STRING
	DEFINE l_success		BOOLEAN

	LET l_msg = SFMT("Running DemoTests on %1 ...", l_url)

	-- Run main application and make some basic introspection -----------------

	LET s = Session.create(l_url)
	LET sLog = s.getSessionListener().getLogger()
	CALL sLog.messageFromBdl(l_msg)

	LET app = s.getNextApplication(10)
	IF app IS NULL THEN
		CALL sLog.errorFromBdl("Main Runner not spawned")
		EXIT PROGRAM 1
	END IF

	LET aLog = app.getApplicationListener().getLogger()
	LET l_appName = app.getApplicationName()
	CALL sLog.messageFromBdl("Main application name:", l_appName)
	IF l_appName != "menu" THEN
		CALL sLog.errorFromBdl("Incorrect application name. Expecting [demo]")
		EXIT PROGRAM 1
	END IF

	DISPLAY "Sending Login & Password ..."
	CALL app.enqueueSetValue("l_login", "test@test.com")
	CALL app.enqueueSetValue("l_pass", "12test")
	DISPLAY "Accepting Login form ..."
	CALL app.enqueueAction("accept")

	CALL app.synchronize(10)
	
	SLEEP 2
	DISPLAY "Sending Logout ..."
	CALL app.enqueueAction("logout")
	CALL app.synchronize(10)
	-- ...

	DISPLAY "Checking to see if application ended ..."
	IF app.isRunning() THEN
		CALL sLog.messageFromBdl("app is still running!")
		-- Try cancel instead!
		CALL app.enqueueAction("cancel")
		IF app.isRunning() THEN
			CALL sLog.messageFromBdl("app is still running!")
		END IF
	ELSE
		CALL sLog.messageFromBdl("app successfully ended!")
	END IF


	IF s.getSessionListener().computeResult("DemoTests") THEN
		LET l_msg = SFMT("DemoTests successful on %1", l_url)
		CALL sLog.messageFromBdl(l_msg)
		LET l_success = TRUE
	ELSE
		LET l_msg = SFMT("DemoTests not successful on %1", l_url)
		CALL sLog.messageFromBdl(l_msg)
		LET l_success = FALSE
	END IF
END FUNCTION
