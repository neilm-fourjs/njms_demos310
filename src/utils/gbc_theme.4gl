
-- This program is for basic GBC theme views
-- By: Neil J Martin ( neilm@4js.com )

IMPORT os
IMPORT util
IMPORT FGL gl_lib
&include "genero_lib.inc"
CONSTANT C_VER="3.1"
CONSTANT PRGDESC = "GBC Themes"
CONSTANT PRGAUTH = "Neil J.Martin"
CONSTANT C_PRGICON = "njm_demo_icon"

DEFINE rec DYNAMIC ARRAY OF RECORD
		name STRING,
		title STRING,
		description STRING,
		type STRING,
		contents DYNAMIC ARRAY OF RECORD
			name STRING,
			title STRING,
			description STRING,
			type STRING,
			value STRING,
			defaultValue STRING,
			contents DYNAMIC ARRAY OF RECORD
				name STRING,
				title STRING,
				type STRING,
				defaultValue STRING,
				aliases DYNAMIC ARRAY OF STRING
			END RECORD
		END RECORD
	END RECORD
MAIN

	CALL gl_lib.gl_setInfo(C_VER, NULL, C_PRGICON, NULL, PRGDESC, PRGAUTH)
	CALL gl_lib.gl_init( ARG_VAL(1) ,NULL,TRUE)
	CALL ui.Interface.setText( gl_lib.gl_progdesc )

	OPEN FORM f FROM "gbc_theme"
	DISPLAY FORM f

--	IF NOT open_main_json( os.path.join( fgl_getEnv("GBCPROJDIR"), "src/theme/definitions/main-definition.json" ) ) THEN
	IF NOT open_main_json( "../etc/main-definition.json" ) THEN
		EXIT PROGRAM
	END IF
END MAIN
--------------------------------------------------------------------------------
FUNCTION open_main_json( l_jsonFile STRING ) RETURNS BOOLEAN
	DEFINE c base.Channel
	DEFINE l_jsonData STRING
	DEFINE x,y,z SMALLINT

	IF NOT os.path.exists( l_jsonFile ) THEN
		CALL gl_winMessage("Error",SFMT("%1 doesn't exist!",l_jsonFile),"exclamation")
		RETURN FALSE
	END IF

	DISPLAY "Processing ",l_jsonFile
	LET c = base.Channel.create()
	CALL c.openFile(l_jsonFile, "r")
	WHILE NOT c.isEof()
		LET l_jsonData = l_jsonData.append( c.readLine()||"\n" )
	END WHILE
	CALL c.close()
	DISPLAY l_jsonData
	CALL util.JSON.parse( l_jsonData, rec )

	FOR x = 1 TO rec.getLength()
		DISPLAY rec[x].title
		FOR y = 1 TO rec[x].contents.getLength()
			IF rec[x].contents[y].value IS NULL THEN
				LET rec[x].contents[y].value = rec[x].contents[y].defaultValue
			END IF
			DISPLAY "	",rec[x].contents[y].title," Value:",rec[x].contents[y].value
			FOR z = 1 TO rec[x].contents[y].contents.getLength()
				DISPLAY "		",rec[x].contents[y].contents[z].name," = ",rec[x].contents[y].contents[z].defaultValue
			END FOR
		END FOR
	END FOR

	RETURN TRUE
END FUNCTION