
#+ This module is designed to present a login window and allow a user to login
#+

IMPORT os
IMPORT util
IMPORT FGL lib_secure
IMPORT FGL gl_lib

&include "schema.inc"
&include "genero_lib.inc"
&include "app.inc"

CONSTANT C_OPENIDLOGIN = "https://generodemo.hopto.org/g/ua/r/OpenIdLogin"
CONSTANT C_OPENID = "#OpenId#"
TYPE t_oidc RECORD
		email STRING,
		family STRING,
		given STRING,
		idp_issuer STRING,
		idp_token_endpoint STRING,
		name STRING,
		picture STRING,
		profile STRING,
		sub STRING,
		token_expires_in INTEGER,
		userinfo_endpoint STRING
	END RECORD

TYPE f_new_account FUNCTION() RETURNS STRING
CONSTANT EMAILPROG = "sendemail.sh" --"fglrun sendemail.42r"
CONSTANT C_SESSION_KEY = "NJMDEMOSESSION"
CONSTANT C_SESSION_MINS = 20 -- how long betweeen logins.

PUBLIC DEFINE m_logo_image STRING
PUBLIC DEFINE m_new_acc_func f_new_account
DEFINE m_login_audit_key INTEGER
DEFINE m_login_stat CHAR(1)
DEFINE m_themes DYNAMIC ARRAY OF RECORD
	name STRING,
	title STRING,
	conditions DYNAMIC ARRAY OF STRING
END RECORD
--------------------------------------------------------------------------------
#+ Login function - One day when this program grows up it will have single signon 
#+ then hackers only have one password to crack :)
#+
#+ @param l_appname - String - the name of the application ( used in the welcome message and window title )
#+ @param l_ver - String - the version of the application ( used in the window title )
#+ @param l_allow_new - Boolean - Enable the 'Create New Account' option.
#+ @return login email address or NULL or 'NEW' for a new account.
PUBLIC FUNCTION login(l_appname STRING, l_ver STRING ) RETURNS STRING
	DEFINE l_login, l_pass, l_theme, l_cur_theme, l_old_theme STRING
	DEFINE l_allow_new BOOLEAN
	DEFINE f ui.Form

	LET l_login = checkForSession() -- check to see if they have already logged in
	IF l_login IS NOT NULL THEN RETURN l_login END IF

	LET l_allow_new = TRUE
	IF m_new_acc_func IS NULL THEN LET l_allow_new = FALSE END IF
	LET INT_FLAG = FALSE
	CALL gl_lib.gl_logIt("Allow New:"||l_allow_new||" Ver:"||l_ver)
	OPTIONS INPUT NO WRAP

	OPEN WINDOW login WITH FORM "login"
	CALL login_ver_title(l_appname, l_ver)

	IF m_logo_image IS NOT NULL THEN
		CALL gl_lib.gl_showElement("logo_grid")
		DISPLAY BY NAME m_logo_image
	END IF
	IF ui.Interface.getFrontEndName() = "GBC" THEN
		CALL ui.Interface.frontCall("theme","getCurrentTheme", [], [l_cur_theme])
		LET l_theme = l_cur_theme
	END IF
	LET l_login = fgl_getenv("OPENID_email")
	CALL  gl_lib.gl_logIt("before input for login")
	INPUT BY NAME l_login, l_pass, l_theme ATTRIBUTES(UNBUFFERED, WITHOUT DEFAULTS)
		BEFORE INPUT
			LET f = DIALOG.getForm()
			IF NOT l_allow_new THEN
				CALL DIALOG.setActionActive( "acct_new",FALSE )
				CALL DIALOG.setActionHidden( "acct_new",TRUE )
				CALL f.setElementHidden( "acct_new",TRUE )
			END IF

		AFTER FIELD l_login
			IF l_login = "t" THEN
				LET l_login = "test@test.com"
				LET l_pass = "12test"
				ACCEPT INPUT
			END IF
		AFTER INPUT
			IF NOT int_flag THEN
				IF NOT validate_login(l_login,l_pass) THEN
					ERROR %"Invalid Login Details!"
					NEXT FIELD l_login
				END IF
			ELSE
				LET l_login = "Cancelled"
			END IF

		ON ACTION openid
			CALL openid(C_OPENIDLOGIN) RETURNING l_login
			IF NOT validate_login(l_login,C_OPENID) THEN
				ERROR %"Invalid Login ID!"
				NEXT FIELD l_login
			ELSE
				EXIT INPUT
			END IF

		ON ACTION acct_new
			LET l_login = m_new_acc_func() -- create a new account
			IF l_login IS NOT NULL THEN EXIT INPUT END IF

		ON ACTION forgotten CALL forgotten(l_login)

		ON CHANGE l_theme
			CALL ui.Interface.frontCall("theme","setTheme", [l_theme], [])

		ON ACTION testlogin
			LET l_login = C_DEF_USER_EMAIL
			LET l_pass = C_DEF_USER_PASSWD
			IF validate_login( l_login, l_pass ) THEN
				EXIT INPUT
			END IF

		GL_ABOUT
	END INPUT
	CLOSE WINDOW login

	IF l_login IS NOT NULL AND l_login != "Cancelled" THEN
		CALL lib_secure.glsec_saveSession(C_SESSION_KEY, l_login)
	END IF

	IF ui.Interface.getFrontEndName() = "GBC" THEN
		SELECT gbc_theme INTO l_old_theme FROM sys_users WHERE email = l_login
		IF l_old_theme IS NOT NULL AND l_cur_theme != l_old_theme THEN
			CALL ui.Interface.frontCall("theme","setTheme", [l_old_theme.trim()], [])
		END IF
		IF l_old_theme IS NULL OR l_old_theme != l_theme THEN
			UPDATE sys_users SET gbc_theme = l_theme WHERE email = l_login
		END IF
	END IF

	CALL  gl_lib.gl_logIt("after input for login:"||l_login)
	CALL fgl_setEnv("APPUSER",l_login)
	RETURN l_login
END FUNCTION
--------------------------------------------------------------------------------
#+ Check to see if email address exists in database
#+
#+ @param l_email Email address to check
#+ @return true if exists else false
PUBLIC FUNCTION sql_checkEmail(l_email VARCHAR(80)) RETURNS BOOLEAN
	SELECT * FROM sys_users WHERE email = l_email
	IF STATUS = NOTFOUND THEN RETURN FALSE END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
PUBLIC FUNCTION logout()
	CALL lib_secure.glsec_removeSession( C_SESSION_KEY )
	CALL audit_logout()
END FUNCTION
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  PRIVATE FUNCTIONS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
PRIVATE FUNCTION validate_login(
	l_login LIKE sys_users.email,
	l_pass LIKE sys_users.login_pass) RETURNS BOOLEAN

	DEFINE l_acc RECORD LIKE sys_users.*

-- does account exist?
	SELECT * INTO l_acc.* FROM sys_users WHERE email = l_login
	IF STATUS = NOTFOUND THEN
		CALL gl_logIt("No account for:"||l_login)
		CALL audit_login(l_login,"A")
		RETURN FALSE
	END IF

	IF l_pass = C_OPENID THEN
		CALL audit_login(l_login,"I")
		RETURN TRUE
	END IF

-- is password correct?
	IF NOT lib_secure.glsec_chkPassword(l_pass,l_acc.pass_hash,l_acc.salt,l_acc.hash_type) THEN
		DISPLAY "Hash wrong for:",l_login," PasswordHash:",l_acc.pass_hash, " Hashtype:",l_acc.hash_type
		CALL audit_login(l_login,"P")
		RETURN FALSE
	END IF

-- Has the password expired?
	IF l_acc.pass_expire IS NOT NULL AND l_acc.pass_expire > DATE("01/01/1990") THEN
		IF l_acc.pass_expire <= TODAY THEN
			CALL gl_lib.gl_logIt("Password has expired:"||l_acc.pass_expire)
			CALL gl_lib.gl_errPopup(%"Your password has expired!\nYou will need to create a new one!")
			LET l_acc.forcepwchg = "Y" 
		END IF
	END IF

-- do we need to force a password change?
	IF l_acc.forcepwchg = "Y" THEN
		IF NOT passchg(l_login) THEN
			CALL audit_login(l_login,"C")
			RETURN FALSE
		END IF
	END IF
	CALL audit_login(l_login,"I")
-- all okay
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
#+ Forgotten password routine.
#+
#+ @param l_login - String - email address to send email to
PRIVATE FUNCTION forgotten( l_login LIKE sys_users.email)
	DEFINE l_acc RECORD LIKE sys_users.*
	DEFINE l_cmd, l_subj, l_body, l_b64 STRING
	DEFINE l_ret SMALLINT

	IF l_login IS NULL OR l_login = " " THEN
		CALL gl_lib.gl_errPopup(%"You must enter your email address!")
		RETURN
	END IF

	IF NOT sql_checkEmail(l_login) THEN
		CALL gl_lib.gl_errPopup(%"Email address not registered!")
		RETURN
	END IF

	IF gl_lib.gl_winQuestion(%"Confirm",%"Are you sure you want to reset your password?\n\nA link will be emailed to you,\nyou will then be able to change and clicking the link.",
			%"No",%"Yes|No","question") = %"No" THEN
		RETURN
	END IF

	CALL gl_lib.gl_logIt("Password regenerated for:"||l_login)

	LET l_acc.pass_expire = TODAY + 2
	LET l_acc.login_pass = lib_secure.glsec_genPassword()
	LET l_acc.hash_type = lib_secure.glsec_getHashType()
	LET l_acc.salt = lib_secure.glsec_genSalt(l_acc.hash_type)
	LET l_acc.pass_hash = lib_secure.glsec_genPasswordHash(l_acc.login_pass ,l_acc.salt,l_acc.hash_type)
	LET l_acc.forcepwchg = "Y"
	LET l_b64 = lib_secure.glsec_toBase64( l_acc.pass_hash )
-- Need to actually send email!!
	LET l_subj = %"Password Reset"
	LET l_body = 
				SFMT(%"Your password for the Login Demo has been reset.\n"||
				"You are now required to change your password."||
				"\nClick the link below to enter a new password:\n"||
				"https://%1/g/ua/r/g/logindemo?Arg=__reset%2\n\n"||
				"NOTE: This link is only valid for 2 days.\n\n"||
				"Please do not reply to this email.",fgl_getEnv("LOGINDEMO_SRV"),l_b64)

	LET l_cmd = EMAILPROG||" "||NVL(l_login,"NOEMAILADD!")||" \"[LoginDemo] "||NVL(l_subj,"NULLSUBJ")||"\" \""||NVL(l_body,"NULLBODY")||"\" 2> "||os.path.join(m_logdir,"sendemail.err")
	--DISPLAY "CMD:",NVL(l_cmd,"NULL")
	ERROR "Sending Email, please wait ..."
	CALL ui.interface.refresh()
	RUN l_cmd RETURNING l_ret
	CALL gl_lib.gl_logIt("Sendmail return:"||NVL(l_ret,"NULL"))
	IF l_ret = 0 THEN -- email send okay
		UPDATE sys_users 
			SET (salt, pass_hash, forcepwchg, pass_expire) = 
					(l_acc.salt, l_acc.pass_hash, l_acc.forcepwchg, l_acc.pass_expire )
			WHERE email = l_login
		CALL gl_lib.gl_winMessage(%"Password Reset",%"A Link has been emailed to you","information")
	ELSE -- email send failed
		CALL gl_lib.gl_winMessage(%"Password Reset",%"Reset Email failed to send!\nProcess aborted","information")
	END IF
	
END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION login_ver_title(l_appname STRING, l_ver STRING)
	DEFINE w ui.Window
	DEFINE f ui.Form
	DEFINE n om.DomNode
	LET w = ui.Window.getCurrent()
	IF w IS NOT NULL THEN
		LET n = w.getNode()
		CALL n.setAttribute("name", l_appname||"_"||l_ver )
		CALL w.setText( l_appname||"-"||l_ver||" Login" )
		LET f = w.getForm()
		CALL f.setElementText("titl",SFMT(%"Welcome to %1",l_appname))
	END IF
END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION passchg(l_login LIKE sys_users.email) RETURNS BOOLEAN
	DEFINE l_pass1, l_pass2 LIKE sys_users.login_pass
	DEFINE l_f ui.Form
	DEFINE l_rules STRING
	DEFINE l_acc RECORD LIKE sys_users.*

	LET l_pass1 = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	LET l_rules = lib_secure.glsec_passwordRules( LENGTH(l_pass1) )

	LET l_f = gl_lib.gl_getForm(NULL)
	CALL l_f.setElementHidden("grp2",FALSE)
	DISPLAY BY NAME l_rules, l_login
	
	WHILE TRUE
		INPUT BY NAME l_pass1, l_pass2
			AFTER FIELD l_pass1
				LET l_rules = lib_secure.glsec_isPasswordLegal(l_pass1 CLIPPED)
				IF l_rules != "Okay" THEN
					ERROR l_rules
					NEXT FIELD l_pass1
				END IF
		END INPUT
		IF int_flag THEN LET int_flag = FALSE RETURN FALSE END IF

		IF l_pass1 != l_pass2 THEN
			ERROR %"Passwords didn't match!"
			LET l_pass1 = ""
			LET l_pass2 = ""
			CONTINUE WHILE
		END IF
		EXIT WHILE
	END WHILE

	LET l_acc.login_pass = l_pass1
	LET l_acc.hash_type = lib_secure.glsec_getHashType()
	LET l_acc.salt = lib_secure.glsec_genSalt(l_acc.hash_type)
	LET l_acc.pass_hash = lib_secure.glsec_genPasswordHash(l_acc.login_pass ,l_acc.salt,l_acc.hash_type)
	LET l_acc.forcepwchg = "N"
	LET l_acc.pass_expire = NULL
	--DISPLAY "New Hash:",l_acc.pass_hash
	UPDATE sys_users 
		SET (salt, pass_hash, forcepwchg, pass_expire, hash_type) = 
				(l_acc.salt, l_acc.pass_hash, l_acc.forcepwchg, l_acc.pass_expire, l_acc.hash_type)
		WHERE email = l_login

	CALL gl_lib.gl_warnPopup(%"Your password has be updated, please don't forget it.\nWe cannot retrieve this password, only reset it.\n")

	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- Try and use an OpenID Login
PRIVATE FUNCTION openid(l_url STRING) RETURNS STRING
	DEFINE l_ret INTEGER
	DEFINE l_store STRING
	DEFINE l_oidc t_oidc
	DEFINE l_key_list STRING
	DEFINE l_key_array DYNAMIC ARRAY OF STRING
	DEFINE x SMALLINT

	CALL ui.Interface.frontCall("localStorage", "removeItem", ["openid"], [])

	IF ui.Interface.getFrontEndName() = "GDC" THEN
		LET l_url = "../bin/gdc -u "||l_url
		CALL ui.Interface.frontCall("standard","execute",[l_url, TRUE],[l_ret])
	ELSE
		CALL ui.Interface.frontCall("standard","launchURL",[l_url],[])
	END IF

	-- loop looking for openId in storage
	FOR x = 1 TO 10
		SLEEP 2
		CALL ui.Interface.frontCall("localStorage", "keys", [], [l_key_list] )
		CALL util.JSON.parse( l_key_list, l_key_array )
		--DISPLAY "Searching keys:", l_key_list
		IF l_key_array.search(NULL,"openid") > 0 THEN
			--DISPLAY "Found 'openid'"
			EXIT FOR
		END IF
		DISPLAY SFMT("Waiting for openId %1 of 10 ... ",x) TO l_login
		CALL ui.Interface.refresh()
	END FOR

	CALL ui.Interface.frontCall("localStorage", "getItem", ["openid"], [l_store])

	--DISPLAY "Store:",l_store
	IF l_store IS NULL THEN
		ERROR "Login Invalid!"
		RETURN NULL
	END IF

	CALL util.JSON.parse( l_store, l_oidc )

	RETURN l_oidc.email
END FUNCTION
--------------------------------------------------------------------------------
-- Check to see if we have already logged in recently.
PRIVATE FUNCTION checkForSession()
	DEFINE l_id STRING
	LET l_id = lib_secure.glsec_getSession(C_SESSION_KEY, C_SESSION_MINS)
	IF l_id IS NULL THEN RETURN NULL END IF

	IF l_id = "expired" THEN
		CALL gl_winMessage(%"Login",%"Your Session has expired.","information")
		RETURN NULL
	END IF

	SELECT MAX( hist_key ) INTO m_login_audit_key FROM sys_login_hist
		WHERE email = l_id
			AND stat = "I"
	IF m_login_audit_key IS NULL OR m_login_audit_key = 0 THEN -- can't find a login audit record?
		CALL audit_login(l_id,"E")
	END IF

	RETURN l_id	
END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION audit_logout( )
	DEFINE l_dt DATETIME YEAR TO SECOND
 
	LET l_dt = CURRENT
	IF m_login_audit_key != 0 THEN
		LET m_login_stat = DOWNSHIFT(m_login_stat)
		UPDATE sys_login_hist SET (stat, loggedout) = ( m_login_stat, l_dt) WHERE hist_key = m_login_audit_key
	END IF
END FUNCTION
--------------------------------------------------------------------------------
PRIVATE FUNCTION audit_login( l_email LIKE sys_users.email, l_stat CHAR(1) )
	DEFINE l_audit_rec RECORD LIKE sys_login_hist.*
	IF l_email IS NULL THEN RETURN END IF
	LET m_login_stat = l_stat
	LET l_audit_rec.hist_key = 0
	LET l_audit_rec.email = l_email
	LET l_audit_rec.client = ui.interface.getFrontEndName()
	LET l_audit_rec.client_ip = fgl_getEnv("FGL_WEBSERVER_REMOTE_ADDR")
	LET l_audit_rec.last_login = CURRENT
	LET l_audit_rec.stat = l_stat
	INSERT INTO sys_login_hist VALUES l_audit_rec.*
	LET m_login_audit_key = SQLCA.SQLERRD[2]
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION cb_gbc_theme(l_cb ui.Combobox)
	DEFINE l_result STRING
	DEFINE x SMALLINT

	IF ui.Interface.getFrontEndName() != "GBC" THEN
		CALL ui.Window.getCurrent().getForm().setElementHidden("ltheme",TRUE)
		CALL ui.Window.getCurrent().getForm().setFieldHidden("formonly.l_theme",TRUE)
		RETURN
	END IF
	CALL ui.Interface.frontCall("theme", "listThemes", [], [l_result])
	--DISPLAY "GBC Themes:", l_result
	CALL util.JSON.parse(l_result,m_themes)
	FOR x = 1 TO m_themes.getLength()
		CALL l_cb.addItem(m_themes[x].name, m_themes[x].title)
	END FOR
END FUNCTION