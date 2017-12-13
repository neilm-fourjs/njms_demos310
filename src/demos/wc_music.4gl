
IMPORT util
IMPORT os
IMPORT FGL gl_lib
&include "genero_lib.inc"	
CONSTANT C_VER="3.1"

MAIN
	DEFINE l_data STRING
	DEFINE l_songs DYNAMIC ARRAY OF RECORD
		name STRING,
		file STRING
	END RECORD
	DEFINE l_songno SMALLINT
	CALL gl_lib.gl_init(ARG_VAL(1),NULL,TRUE)
	LET gl_lib.gl_noToolBar = FALSE

	OPEN FORM f FROM "wc_music"
	DISPLAY FORM f

	LET l_songs[1].name = "Sólstafir - Silfur-Refur"
	LET l_songs[1].file = "01.mp3"
	LET l_songs[2].name = "Sólstafir -Ísafold"
	LET l_songs[2].file = "02.mp3"
	LET l_songs[3].name = "Sólstafir - Hvít Sæng"
	LET l_songs[3].file = "05.mp3"
	LET l_songno = 1
	CALL wc_setProp("mp3file", l_songs[l_songno].file )
	CALL wc_setProp("name", l_songs[l_songno].name )

	INPUT BY NAME l_data ATTRIBUTES(UNBUFFERED)
		ON ACTION quit EXIT INPUT
		ON ACTION previous
			IF l_songno > 1 THEN LET l_songno = l_songno - 1 END IF
			CALL wc_setProp("mp3file", l_songs[l_songno].file )
			CALL wc_setProp("name", l_songs[l_songno].name )
		ON ACTION next
			IF l_songno < l_songs.getLength() THEN LET l_songno = l_songno + 1 END IF
			CALL wc_setProp("mp3file", l_songs[l_songno].file )
			CALL wc_setProp("name", l_songs[l_songno].name )
		ON ACTION close EXIT INPUT
		GL_ABOUT
	END INPUT
	CALL gl_lib.gl_exitProgram(0,%"Program Finished")
END MAIN
--------------------------------------------------------------------------------
#+ Set a Property in the AUI
FUNCTION wc_setProp(l_prop_name STRING, l_value STRING)
	DEFINE w ui.Window
	DEFINE n om.domNode
	LET w = ui.Window.getCurrent()
	LET n = w.findNode("Property",l_prop_name)
	IF n IS NULL THEN
		DISPLAY "can't find property:",l_prop_name
		RETURN
	END IF
	CALL n.setAttribute("value",l_value)
END FUNCTION