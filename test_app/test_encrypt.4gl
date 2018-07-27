
IMPORT FGL gl_encrypt

MAIN
	DEFINE l_str STRING

	CALL gl_encrypt.gl_encryptInit("../etc/publickey.crt","../etc/private.key")

	LET l_str = "Hello World"
	DISPLAY "String:",l_str
	DISPLAY ""

	LET l_str = gl_encrypt.gl_encrypt(l_str)
	IF l_str IS NOT NULL THEN
		DISPLAY "Encrypted:",l_str
		DISPLAY "---------------------------------------"
		LET l_str = gl_encrypt.gl_decrypt(l_str)
		DISPLAY "Decrypted:",l_str
	ELSE
		DISPLAY "Failed:",gl_encrypt.m_err
	END IF
END MAIN