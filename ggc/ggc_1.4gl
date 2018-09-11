
IMPORT JAVA com.fourjs.ggc.fgl.Application
IMPORT JAVA com.fourjs.ggc.fgl.Session
IMPORT JAVA com.fourjs.ggc.util.Log
IMPORT JAVA java.lang.String

MAIN

	CALL testSession("http://localhost/g/ua/r/njmdemo")

END MAIN
--------------------------------------------------------------------------------
FUNCTION testSession(l_url STRING)
	DEFINE l_session     Session
	DEFINE l_app        Application
--	DEFINE childApp   Application
	DEFINE l_sLog         Log
	DEFINE l_aLog         Log
	DEFINE l_msg				STRING
	DEFINE l_appName		STRING
	DEFINE l_success		BOOLEAN

	LET l_msg = SFMT("Running Tests on %1 ...", l_url)

	-- Run main l_application and make some basic introspection -----------------

	LET l_session = Session.create(l_url)
	LET l_sLog = l_session.getSessionListener().getLogger()
	CALL l_sLog.messageFromBdl(l_msg)

	LET l_app = l_session.getNextApplication(10)
	IF l_app IS NULL THEN
		CALL l_sLog.errorFromBdl("Main Runner not spawned")
		EXIT PROGRAM 1
	END IF

	LET l_aLog = l_app.getApplicationListener().getLogger()
	LET l_appName = l_app.getApplicationName()
	CALL l_sLog.messageFromBdl("Main l_application name:", l_appName)
	IF l_appName != "menu" THEN
		CALL l_sLog.errorFromBdl("Incorrect l_application name. Expecting [demo]")
		EXIT PROGRAM 1
	END IF

	DISPLAY "Sending Login & Password ..."
	CALL l_app.enqueueSetValue("l_login", "test@test.com")
	CALL l_app.enqueueSetValue("l_pass", "12test")
	DISPLAY "Accepting Login form ..."
	CALL l_app.enqueueAction("accept")

	CALL l_app.synchronize(10) -- 10 seconds timeout - Wait until this l_application interface queue is empty
	
	SLEEP 2
	DISPLAY "Sending Logout ..."
	CALL l_app.enqueueAction("logout")
	CALL l_app.synchronize(10)
	-- ...

	DISPLAY "Checking to see if l_application ended ..."
	IF l_app.isRunning() THEN
		CALL l_sLog.messageFromBdl("app is still running!")
		-- Try cancel instead!
		CALL l_app.enqueueAction("cancel")
		IF l_app.isRunning() THEN
			CALL l_sLog.messageFromBdl("app is still running!")
		END IF
	ELSE
		CALL l_sLog.messageFromBdl("app successfully ended!")
	END IF


	IF l_session.getSessionListener().computeResult("Tests") THEN
		LET l_msg = SFMT("DemoTests successful on %1", l_url)
		CALL l_sLog.messageFromBdl(l_msg)
		LET l_success = TRUE
	ELSE
		LET l_msg = SFMT("DemoTests not successful on %1", l_url)
		CALL l_sLog.messageFromBdl(l_msg)
		LET l_success = FALSE
	END IF

END FUNCTION