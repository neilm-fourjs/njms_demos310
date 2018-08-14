
IMPORT FGL gl_lib
IMPORT FGL lib_login
IMPORT FGL lib_secure

&include "schema.inc"
--------------------------------------------------------------------------------
#+ Create a new account.
FUNCTION new_acct() RETURNS STRING
	DEFINE l_acc RECORD LIKE sys_users.*
	DEFINE l_email, l_rules STRING
	LET l_acc.user_key = 0
	LET l_acc.acct_type = 1
	LET l_acc.active = TRUE
	LET l_acc.forcepwchg = "N"
	LET l_acc.pass_expire = TODAY + 6 UNITS MONTH

	OPEN WINDOW new_acct WITH FORM "new_acct"

	LET l_acc.login_pass = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	LET l_rules = lib_secure.glsec_passwordRules( LENGTH(l_acc.login_pass) )
	DISPLAY BY NAME l_rules

	LET l_acc.login_pass = NULL
	INPUT BY NAME l_acc.* ATTRIBUTES(WITHOUT DEFAULTS, FIELD ORDER FORM, UNBUFFERED)
		AFTER FIELD email
			IF lib_login.sql_checkEmail(l_acc.email) THEN
				CALL gl_lib.gl_errPopup(%"This Email is already registered.")
				NEXT FIELD email
			ELSE
				--LET l_acc.login_pass = lib_secure.glsec_genPassword()
			END IF
		AFTER FIELD pass_expire
			IF l_acc.pass_expire < (TODAY + 1 UNITS MONTH) THEN
				ERROR %"Password expire date can not be less than 1 month."
				NEXT FIELD pass_expire
			END IF
		AFTER FIELD login_pass
			LET l_rules = lib_secure.glsec_isPasswordLegal(l_acc.login_pass CLIPPED)
			IF l_rules != "Okay" THEN
				ERROR l_rules
				NEXT FIELD login_pass
			END IF
		BEFORE INPUT
			CALL DIALOG.setFieldActive("sys_users.user_key",FALSE)
			CALL DIALOG.setFieldActive("sys_users.forcepwchg",FALSE)
			CALL DIALOG.setFieldActive("sys_users.active",FALSE)
			CALL DIALOG.setFieldActive("sys_users.acct_type",FALSE)
		ON ACTION generate
			LET l_acc.login_pass = lib_secure.glsec_genPassword()
			CALL gl_lib.gl_winMessage(%"Password",SFMT(%"Your Generated Password is:\n%1\nDon't forget it!",l_acc.login_pass),"information")
	END INPUT

	CLOSE WINDOW new_acct

	IF NOT int_flag THEN
		LET l_email = l_acc.email
		LET l_acc.hash_type = lib_secure.glsec_getHashType()
		LET l_acc.salt = lib_secure.glsec_genSalt(l_acc.hash_type) -- NOTE: for Genero 3.10 we don't need to store this
		LET l_acc.pass_hash = lib_secure.glsec_genPasswordHash(l_acc.login_pass ,l_acc.salt,l_acc.hash_type)
		LET l_acc.login_pass = "PasswordEncrypted!" -- we don't store their clear text password!
		INSERT INTO sys_users VALUES l_acc.*
	END IF

	LET int_flag = FALSE
	RETURN l_email
END FUNCTION
