
# Util to produce a image2font.txt file for FontAwesome 5

IMPORT util
IMPORT os
MAIN
	DEFINE l_file, l_line STRING
	DEFINE l_fontFiles, l_colours DYNAMIC ARRAY OF STRING
	DEFINE l_text TEXT
	DEFINE x, y INTEGER
	DEFINE l_jo, l_jo2 util.JSONObject
	DEFINE l_ja util.JSONArray
	DEFINE c base.channel
	DEFINE l_got_solid BOOLEAN

	LET l_file = "icons.json"
	LOCATE l_text IN FILE l_file

	LET l_fontFiles[1] = "fa-regular-400.ttf"
	LET l_fontFiles[2] = "fa-solid-900.ttf"
	LET l_fontFiles[3] = "fa-brands-400.ttf"
	LET l_colours[1] = "#0000E0"
	LET l_colours[2] = "#000000"
	LET l_colours[3] = "#D00000"

	LET l_jo = util.JSONObject.parse( l_text )

	LET c = base.channel.create()
	CALL c.openFile("fa5.txt","w")

	CALL addFourJSImages(c)

	FOR x = 1 TO l_jo.getLength()
		LET l_jo2 = l_jo.get( l_jo.name(x) )
		IF NOT l_jo2.has( "unicode" ) THEN CONTINUE FOR END IF
		IF l_jo2.has( "styles" ) THEN
			LET l_ja = l_jo2.get( "styles" )
			LET l_line = NULL
			LET l_got_solid = FALSE
			FOR y = 1 TO l_ja.getLength()
				IF l_ja.get(y) = "regular" AND NOT l_got_solid THEN
					LET l_line = "far-",l_jo.name(x),"=",l_fontFiles[ 1 ],":",l_jo2.get( "unicode" ),":",l_colours[1]
				END IF
				IF l_ja.get(y) = "solid" THEN
					LET l_line = "fa-",l_jo.name(x),"=",l_fontFiles[ 2 ],":",l_jo2.get( "unicode" ),":",l_colours[2]
					LET l_got_solid = TRUE
				END IF
			END FOR
			IF l_line IS NOT NULL THEN CALL c.writeLine( l_line ) END IF
		END IF
	END FOR

-- Handle the brands
	FOR x = 1 TO l_jo.getLength()
		LET l_jo2 = l_jo.get( l_jo.name(x) )
		IF NOT l_jo2.has( "unicode" ) THEN CONTINUE FOR END IF
		IF l_jo2.has( "styles" ) THEN
			LET l_ja = l_jo2.get( "styles" )
			LET l_line = NULL
			LET l_got_solid = FALSE
			FOR y = 1 TO l_ja.getLength()
				IF l_ja.get(y) = "brands" THEN
					LET l_line = "fab-",l_jo.name(x),"=",l_fontFiles[ 3 ],":",l_jo2.get( "unicode" ),":",l_colours[3]
					IF l_line IS NOT NULL THEN CALL c.writeLine( l_line ) END IF
				END IF
			END FOR
		END IF
	END FOR

	CALL c.close()

END MAIN
--------------------------------------------------------------------------------
FUNCTION addFourJSImages(c base.channel)
	DEFINE c1 base.channel
	DEFINE l_file, l_line STRING
	LET l_file = fgl_getEnv("FGLDIR")
	LET l_file = os.path.join(l_file,"lib")
	LET l_file = os.path.join(l_file,"image2font.txt")
	LET c1 = base.channel.create()
	CALL c1.openFile(l_file,"r")
	CALL c.writeLine(c1.readLine())
	WHILE NOT c1.isEof()
		LET l_line = c1.readLine()	
		IF l_line.getCharAt(1) != "#" AND l_line.subString(1,3) != "fa-" THEN
			CALL c.writeLine( l_line )
		END IF
	END WHILE
	CALL c1.close()
	CALL c.writeLine("# New Mapping from FontAwesume 5")
END FUNCTION
