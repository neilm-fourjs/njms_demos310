
IMPORT util

&include "OpenIdLogin.inc"

MAIN
	DEFINE l_oidc t_oidc
	DEFINE l_store STRING

	CALL ui.Interface.loadStyles("OpenIdLogin")

	OPEN FORM frm FROM "OpenIdLogin"
	DISPLAY FORM frm

	LET l_oidc.email = fgl_getEnv("OIDC_EMAIL")
	LET l_oidc.family = fgl_getEnv("OIDC_FAMILY_NAME")
	LET l_oidc.given  = fgl_getEnv("OIDC_GIVEN_NAME")
	LET l_oidc.idp_issuer  = fgl_getEnv("OIDC_IDP_ISSUER")
	LET l_oidc.idp_token_endpoint  = fgl_getEnv("OIDC_IDP_TOKEN_ENDPOINT")
	LET l_oidc.name  = fgl_getEnv("OIDC_NAME")
	LET l_oidc.picture  = fgl_getEnv("OIDC_PICTURE")
	LET l_oidc.profile  = fgl_getEnv("OIDC_PROFILE")
	LET l_oidc.sub  = fgl_getEnv("OIDC_SUB")
	LET l_oidc.token_expires_in  = fgl_getEnv("OIDC_TOKEN_EXPIRES_IN")
	LET l_oidc.userinfo_endpoint  = fgl_getEnv("OIDC_USERINFO_ENDPOINT")

	IF l_oidc.email IS NULL THEN
--		DISPLAY "Invalid Login" TO name
		DISPLAY "homer-doh_Login.png" TO img
		CALL dumpEnv()
	ELSE
		DISPLAY "Welcome "||NVL(l_oidc.name,"Unknown User!") TO name
		DISPLAY l_oidc.picture TO img
		DISPLAY "Login Okay:",l_oidc.email
	END IF

	LET l_store = util.JSONObject.fromFGL( l_oidc ).toString()
	CALL ui.Interface.frontCall("localStorage", "setItem", ["openid", l_store], [])

	MENU "OpenIdLogin"
		ON ACTION close EXIT MENU
		ON ACTION exit EXIT MENU
		ON IDLE 20 EXIT MENU
	END MENU

END MAIN
--------------------------------------------------------------------------------
FUNCTION dumpEnv()
	DEFINE c base.channel
	DEFINE l_line STRING
	LET c = base.Channel.create()

	DISPLAY "----------Environment---------"
	CALL c.openPipe("env | sort", "r")
	WHILE NOT c.isEof()
		LET l_line = c.readLine()
		IF l_line.getLength() > 1 THEN
			DISPLAY "Env: "||l_line
		END IF
	END WHILE
	CALL c.close()

END FUNCTION
--------------------------------------------------------------------------------
