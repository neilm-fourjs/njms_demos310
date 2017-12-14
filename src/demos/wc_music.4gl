
IMPORT util
IMPORT os
IMPORT FGL gl_lib
&include "genero_lib.inc"	
CONSTANT C_VER="3.1"

DEFINE m_base STRING
DEFINE m_songs DYNAMIC ARRAY OF RECORD
	artist STRING,
	album STRING,
	name STRING,
	file STRING
END RECORD
DEFINE m_songno SMALLINT
MAIN
	DEFINE l_data STRING
	DEFINE l_tree DYNAMIC ARRAY OF RECORD
		id			STRING,
		pid			STRING,
		descr		STRING,
		artist	STRING,
		album		STRING,
		track		STRING,
		file		STRING,
		img			STRING
	END RECORD
	DEFINE l_songno, x, pid SMALLINT
	DEFINE l_prev_art, l_prev_alb, l_art_pid STRING
	CALL gl_lib.gl_init(ARG_VAL(1),NULL,TRUE)
	LET gl_lib.gl_noToolBar = FALSE
	LET m_base = fgl_getEnv("MUSICDIR")

	CALL get_artist_list()

	OPEN FORM f FROM "wc_music"
	DISPLAY FORM f

	LET x = 1
	LET pid = 0
	LET l_prev_art = "."
	LET l_prev_alb = "."
	FOR l_songno = 1 TO m_songs.getLength()
		IF m_songs[l_songno].artist != l_prev_art THEN
			LET l_tree[x].id = (x USING "&&&" )
			LET l_tree[x].pid = "000"
			LET l_tree[x].descr = m_songs[l_songno].artist
			LET l_tree[x].img = "fa-user"
			LET pid = x
			LET l_art_pid = (pid USING "&&&")
			LET x = x + 1
			LET l_prev_art = m_songs[l_songno].artist
		END IF
		IF m_songs[l_songno].album != l_prev_alb THEN
			LET l_tree[x].id = (x USING "&&&" )
			LET l_tree[x].pid = l_art_pid
			LET l_tree[x].descr = m_songs[l_songno].album
			LET l_tree[x].img = "fa-folder"
			LET pid = x
			LET x = x + 1
			LET l_prev_alb = m_songs[l_songno].album
		END IF
		LET l_tree[x].id = (x USING "&&&" )
		LET l_tree[x].pid = (pid USING "&&&")
		LET l_tree[x].descr = m_songs[l_songno].name
		LET l_tree[x].file = m_songs[l_songno].file
		LET l_tree[x].track = m_songs[l_songno].name
		LET l_tree[x].artist = m_songs[l_songno].artist
		LET l_tree[x].album = m_songs[l_songno].album
		LET l_tree[x].img = "fa-music"
		LET x = x + 1
	END FOR

	LET l_songno = 1

	DIALOG  ATTRIBUTES(UNBUFFERED)
		DISPLAY ARRAY l_tree TO arr.*
			ON ACTION accept
				LET l_songno = arr_curr()
				CALL wc_setProp("mp3file", l_tree[l_songno].file )
				CALL wc_setProp("name", l_tree[l_songno].artist||" - "||l_tree[l_songno].track )
		END DISPLAY
		INPUT BY NAME l_data
		END INPUT
		ON ACTION quit EXIT DIALOG
		ON ACTION previous
			IF l_songno > 1 THEN LET l_songno = l_songno - 1 END IF
			CALL wc_setProp("mp3file", m_songs[l_songno].file )
			CALL wc_setProp("name", m_songs[l_songno].name )
		ON ACTION next
			IF l_songno < m_songs.getLength() THEN LET l_songno = l_songno + 1 END IF
			CALL wc_setProp("mp3file", m_songs[l_songno].file )
			CALL wc_setProp("name", m_songs[l_songno].name )
		ON ACTION close EXIT DIALOG
		GL_ABOUT
	END DIALOG
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
--------------------------------------------------------------------------------
#+ Get a songs from $MUSICDIR folder
FUNCTION get_artist_list()
	DEFINE l_path STRING
	DEFINE d INTEGER

	DISPLAY "Getting Artists from ",m_base
	LET m_songno = 1
	CALL m_songs.clear()
	CALL os.Path.dirSort( "name", 1 )
	LET d = os.Path.dirOpen( m_base )
	IF d > 0 THEN
		WHILE TRUE
			LET l_path = os.Path.dirNext( d )
			IF l_path IS NULL THEN EXIT WHILE END IF
			IF l_path = "." OR l_path = ".." THEN CONTINUE WHILE END IF
			IF l_path = "Audacity" THEN CONTINUE WHILE END IF
			IF os.path.isDirectory( os.path.join(m_base,l_path) ) THEN
				LET m_songs[ m_songno ].artist = l_path
--				DISPLAY "Processing Dir:",l_path, " songno=",(m_songno USING "&&&&")," Artist:", m_songs[ m_songno ].artist
				CALL get_song_list( os.path.join(m_base,l_path) )
			ELSE
--				DISPLAY "Skipping File:",l_path
			END IF
		END WHILE
	END IF
END FUNCTION
--------------------------------------------------------------------------------
#+ Get a songs from $MUSICDIR folder
FUNCTION get_song_list(l_path STRING)
	DEFINE l_ext, l_dir STRING
	DEFINE d INTEGER

	LET l_dir = l_path
--	DISPLAY "Getting Songs from songno=",(m_songno USING "###&"),":",l_dir

	CALL os.Path.dirSort( "name", 1 )
	LET d = os.Path.dirOpen( l_path )
	IF d > 0 THEN
		WHILE TRUE
			LET l_path = os.Path.dirNext( d )
			IF l_path IS NULL THEN EXIT WHILE END IF
			IF l_path = "." OR l_path = ".." THEN CONTINUE WHILE END IF

			IF os.path.isDirectory( os.path.join(l_dir,l_path) ) THEN
--				DISPLAY "Processing Sub Dir:",l_path
				LET m_songs[ m_songno ].album = l_path
				CALL get_song_list( os.path.join(l_dir,l_path) )
			END IF

			LET l_ext = os.path.extension( l_path )
			IF l_ext IS NULL OR (l_ext != "mp3") THEN 
--				DISPLAY "Skipping File:",l_path
				CONTINUE WHILE
			END IF

			IF m_songs[ m_songno ].artist IS NULL THEN 
				LET m_songs[ m_songno ].artist = m_songs[ m_songno - 1 ].artist
			END IF
			IF m_songs[ m_songno ].album IS NULL THEN
				IF m_songno > 1 THEN
					LET m_songs[ m_songno ].album = m_songs[ m_songno - 1 ].album
				ELSE
					LET m_songs[ m_songno ].album = "Unknown"
				END IF
			END IF
			LET m_songs[ m_songno ].file = os.path.join(l_dir,l_path)
			LET m_songs[ m_songno ].name = os.path.rootName( l_path )
			DISPLAY "Adding Song:",l_path," songno=",(m_songno USING "###&")," Artist:", m_songs[ m_songno ].artist," File:",m_songs[ m_songno ].file," Name:",m_songs[ m_songno ].name

			LET m_songno = m_songno + 1
		END WHILE
	ELSE
		DISPLAY "ERROR in Opening Dir!"
	END IF
END FUNCTION