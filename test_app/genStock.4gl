
IMPORT os

MAIN

	CALL genStock( "../pics/products","xx", FALSE)

END MAIN
--------------------------------------------------------------------------------
FUNCTION genStock(l_base STRING, l_cat STRING, l_process BOOLEAN) 
	DEFINE l_ext, l_path, l_dir, l_desc STRING
	DEFINE l_d INT
	DEFINE l_nam STRING

	DISPLAY "---------------Generating Stock from ",l_base, " Cat:",l_cat

	CALL os.Path.dirSort( "name", 1 )
	LET l_d = os.Path.dirOpen( l_base )
	IF l_d > 0 THEN
		WHILE TRUE
			LET l_path = os.Path.dirNext( l_d )
			IF l_path IS NULL THEN EXIT WHILE END IF
			LET l_dir = os.path.baseName(l_base)

			--DISPLAY "Path:",l_path," Dir:", os.path.isDirectory(os.path.join(l_base,l_path)) 
			IF os.path.isDirectory(os.path.join(l_base,l_path)) THEN
				IF l_dir != "." AND l_dir != ".." THEN
					CASE l_path
						WHEN "supplies" LET l_cat = "SUPPLIES"
						WHEN "art" LET l_cat = "ART"
						WHEN "entertainment" LET l_cat = "ENTERTAIN"
						WHEN "furniture" LET l_cat = "FURNITURE" 
						WHEN "travelling" LET l_cat = "TRAVELLING"
						OTHERWISE LET l_cat = "??"
					END CASE
					DISPLAY "DIR --    Path:",l_dir," Cat:",l_cat 
					CALL genStock( os.path.join(l_base,l_path), l_cat, TRUE )
				END IF
				CONTINUE WHILE 
			ELSE
				IF l_process THEN
					LET l_ext = os.path.extension( l_path )
					IF l_ext IS NULL OR (l_ext != "jpg" AND l_ext != "png") THEN CONTINUE WHILE END IF
					LET l_nam = os.path.rootName(l_path) 
					LET l_desc = tidy_name(l_nam)
					DISPLAY "Path:",l_path, " Cat:",l_cat," Name:",l_nam," Ext:",l_ext
				--	CALL insStock(NULL,NULL,l_desc,l_cat,0, "CC", os.path.join( l_dir, l_nam ))
					DISPLAY "Path:",l_path, " Cat:",l_cat," Name:",l_nam, " Desc:",l_desc," Ext:",l_ext, " Dir:",l_dir
				END IF
			END IF
		END WHILE
	END IF
	DISPLAY "---------------END"
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION tidy_name( l_nam STRING ) RETURNS STRING
	DEFINE l_st base.StringTokenizer
	DEFINE l_word CHAR(100)
	LET l_st = base.StringTokenizer.create( l_nam, "-" )
	LET l_nam = ""
	WHILE l_st.hasMoreTokens()
		LET l_word = l_st.nextToken()
		LET l_word[1] = UPSHIFT(l_word[1])
		LET l_nam = l_nam.append( l_word CLIPPED||" ")
	END WHILE
	RETURN l_nam.trim()
END FUNCTION