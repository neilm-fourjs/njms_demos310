
IMPORT FGL gl_lib
IMPORT FGL lib_login
IMPORT FGL lib_secure

&include "schema.inc"
--------------------------------------------------------------------------------
#+ Create a new account.
FUNCTION new_acct() RETURNS STRING
	DEFINE l_acc RECORD LIKE accounts.*
	DEFINE l_email STRING
	LET l_acc.acct_id = 0
	LET l_acc.acct_type = 1
	LET l_acc.active = TRUE
	LET l_acc.forcepwchg = "Y"
	LET l_acc.pass_expire = TODAY + 6 UNITS MONTH

	OPEN WINDOW new_acct WITH FORM "new_acct"

	INPUT BY NAME l_acc.* ATTRIBUTES(WITHOUT DEFAULTS, FIELD ORDER FORM, UNBUFFERED)
		AFTER FIELD email
			IF lib_login.sql_checkEmail(l_acc.email) THEN
				CALL gl_lib.gl_winMessage(%"Error",%"This Email is already registered.","exclamation")
				NEXT FIELD email
			ELSE
				LET l_acc.login_pass = lib_secure.glsec_genPassword()
			END IF
		AFTER FIELD pass_expire
			IF l_acc.pass_expire < (TODAY + 1 UNITS MONTH) THEN
				ERROR %"Password expire date can not be less than 1 month."
				NEXT FIELD pass_expire
			END IF
		BEFORE INPUT
			CALL DIALOG.setFieldActive("accounts.acct_id",FALSE)
			CALL DIALOG.setFieldActive("accounts.forcepwchg",FALSE)
			CALL DIALOG.setFieldActive("accounts.active",FALSE)
			CALL DIALOG.setFieldActive("accounts.acct_type",FALSE)
		ON ACTION generate
			LET l_acc.login_pass = lib_secure.glsec_genPassword()
			--CALL gl_lib.gl_winMessage(%"Password",SFMT(%"Your Generated Password is:\n%1\nDon't forget it!",l_acc.login_pass),"information")
	END INPUT

	CLOSE WINDOW new_acct

	IF NOT int_flag THEN
		LET l_email = l_acc.email
		LET l_acc.hash_type = lib_secure.glsec_getHashType()
		LET l_acc.salt = lib_secure.glsec_genSalt(l_acc.hash_type) -- NOTE: for Genero 3.10 we don't need to store this
		LET l_acc.pass_hash = lib_secure.glsec_genPasswordHash(l_acc.login_pass ,l_acc.salt,l_acc.hash_type)
		LET l_acc.login_pass = "PasswordEncrypted!" -- we don't store their clear text password!
		INSERT INTO accounts VALUES l_acc.*
	END IF

	LET int_flag = FALSE
	RETURN l_email
END FUNCTION
