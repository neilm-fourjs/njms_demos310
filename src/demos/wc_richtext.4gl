
IMPORT os
IMPORT FGL gl_lib

&include "genero_lib.inc"	
CONSTANT C_VER="3.1"
CONSTANT C_PRGDESC = "WC Richtext Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"

MAIN
	DEFINE l_rec RECORD
		fileName STRING,
		richtext STRING,
		fld2 STRING,
		info STRING
	END RECORD
	DEFINE l_tmp STRING
	DEFINE l_ret SMALLINT

	CALL gl_lib.gl_setInfo(C_VER, NULL, NULL, NULL, C_PRGDESC, C_PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),NULL,TRUE)
	LET gl_lib.gl_noToolBar = FALSE

	LET l_rec.fileName = "text.html"

	OPTIONS INPUT WRAP, FIELD ORDER FORM

	OPEN FORM f1 FROM "wc_richtext"
	DISPLAY FORM f1

	INPUT BY NAME l_rec.* ATTRIBUTES(UNBUFFERED, WITHOUT DEFAULTS, ACCEPT=FALSE)

		ON ACTION myCopy 
			DISPLAY "Copy"
			CALL ui.Interface.frontCall("standard","cbset", 
				DIALOG.getFieldValue(DIALOG.getCurrentItem()), l_ret)

		ON ACTION myPaste
			DISPLAY "Paste"
			CALL ui.Interface.frontCall("standard","cbPaste", "", l_ret)

		ON ACTION clear
			LET l_rec.richtext = NULL
			LET l_rec.info = %"Text cleared."

		ON ACTION autosave ATTRIBUTES(DEFAULTVIEW=NO)
			IF saveText("autosave.html", l_rec.richtext) THEN
				LET l_rec.info = CURRENT HOUR TO SECOND,%":Auto Saved"
				DISPLAY l_rec.info
			ELSE
				LET l_rec.info = CURRENT HOUR TO SECOND,%":No text!"
				DISPLAY l_rec.info
			END IF

		ON ACTION savetext
			IF saveText(l_rec.fileName, l_rec.richtext) THEN
				LET l_rec.info = SFMT(%"Text saved to '%1'",l_rec.fileName)
				DISPLAY l_rec.info
			END IF

		ON ACTION loadText
			LET l_tmp = loadText(l_rec.fileName)
			IF l_tmp IS NOT NULL THEN
				LET l_rec.richtext = l_tmp
				LET l_rec.info = SFMT(%"Text loaded from '%1'",l_rec.fileName)
				DISPLAY l_rec.info
			END IF

		AFTER FIELD fld2
			LET l_tmp = loadText(l_rec.fileName)
			DISPLAY " l_tmp contains ", l_tmp
			IF l_tmp IS NOT NULL THEN
				LET l_rec.richtext = l_tmp
				LET l_rec.info = SFMT(%"Text loaded from '%1'",l_rec.fileName)
				DISPLAY l_rec.info
			END IF
			DISPLAY " l_rec.richtext contains ", l_rec.richtext

		ON ACTION set_focus_to_wc ATTRIBUTES(TEXT=%"Focus to RichText")
			NEXT FIELD richtext

		ON ACTION set_focus_to_info ATTRIBUTES(TEXT=%"Focus to info")
			NEXT FIELD info

		GL_ABOUT
	END INPUT

END MAIN
--------------------------------------------------------------------------------
FUNCTION loadText( l_fileName STRING ) RETURNS STRING
	DEFINE l_txt TEXT
	IF NOT os.path.exists(l_fileName) THEN
		ERROR "File Not Found!"
		RETURN NULL
	END IF
	LOCATE l_txt IN MEMORY
	CALL l_txt.readFile( l_fileName )
	RETURN l_txt
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION saveText( l_fileName STRING, l_html STRING ) RETURNS BOOLEAN
	DEFINE l_txt TEXT
	IF l_html.getLength() = 0 THEN RETURN FALSE END IF
	LOCATE l_txt IN FILE l_fileName
	LET l_txt = l_html
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getDVMVer()
	RETURN "Genero: "||fgl_getVersion()
END FUNCTION