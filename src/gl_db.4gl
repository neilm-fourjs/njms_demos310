
#+ General library code for Database access.
#+

IMPORT os

&include "schema.inc"
&include "genero_lib.inc"
&include "gl_db.inc"

DEFINE m_dbtyp, m_dbnam, m_dbsrc,  m_dbdrv,  m_dbcon STRING

FUNCTION gldb_connect( l_db STRING )
  DEFINE con VARCHAR(300)
	DEFINE dbdir, src, drv, l_msg STRING
	DEFINE lockMode, fglprofile BOOLEAN
	DEFINE dbt CHAR(3)
GL_MODULE_ERROR_HANDLER
	IF l_db IS NULL OR l_db = " " THEN LET l_db = fgl_getenv("DBNAME") END IF
	IF l_db IS NULL OR l_db = " " THEN LET l_db = DEF_DBNAME END IF

	LET dbdir = fgl_getenv("DBDIR")
	IF dbdir IS NULL OR dbdir = " " THEN LET dbdir = DEF_DBDIR END IF

	LET fglprofile = TRUE

	LET drv = fgl_getenv("DBDRIVER") 
	IF drv IS NOT NULL AND drv != " " THEN LET fglprofile = FALSE END IF

	LET lockMode = TRUE

	IF fglprofile THEN
		LET src = fgl_getresource("dbi.database."||l_db||".source")
		LET drv = fgl_getresource("dbi.database."||l_db||".driver")
		IF drv IS NULL OR drv = " " THEN
			LET drv = fgl_getresource("dbi.default.driver")
		END IF
		LET con = l_db
		DISPLAY "Database set from fglprofile:",drv
	ELSE
		IF drv IS NULL OR drv = " " THEN LET drv = DEF_DBDRIVER END IF
		DISPLAY "Database set from environment DBDRIVER:",drv
	END IF
	LET dbt = drv.subString(4,6)
	LET m_dbtyp = dbt

	CASE dbt
		WHEN "pgs"
			LET src = fgl_getEnv("PGSERVER") -- ???
			LET m_dbnam = "PostgreSQL "||drv.subString(7,9)
			LET con = "db+driver='"||drv||"',source='"||src||"'"
		WHEN "ifx"
			LET src = fgl_getEnv("INFORMIXSERVER")
			LET m_dbnam = "Informix "||drv.subString(7,9)
			LET src = fgl_getEnv("INFORMIXSERVER")
			LET con = l_db
		WHEN "sqt"	
			LET src = fgl_getEnv("SQLITEDB")
			IF src IS NULL OR src = " " THEN LET src = dbdir||os.path.separator()||l_db||".db" END IF
			LET lockMode = FALSE
			LET m_dbnam = "SQLite "||drv.subString(7,9)
			LET con = "db+driver='"||drv||"',source='"||src||"'"
	END CASE

	LET m_dbsrc = src
	LET m_dbdrv = drv
	LET m_dbcon = con
	TRY
		DISPLAY "Connecting to "||l_db||" Using:",drv, " Source:",src," ..."
		DATABASE con
		DISPLAY "Connected to "||l_db||" Using:",drv, " Source:",src
	CATCH
		LET l_msg = "Connection to database failed\nDB:",l_db,"\nSource:",src, "\nDriver:",drv,"\n",
			 "Status:",SQLCA.SQLCODE,"\n",SQLERRMESSAGE
		DISPLAY l_msg
		IF dbt = "ads" AND SQLCA.SQLCODE = -6366 THEN
			RUN "echo $LD_LIBRARY_PATH;ldd $FGLDIR/dbdrivers/"||drv||".so"
		END IF
		CALL gl_winMessage("Fatal Error",l_msg,"exclamation")
		EXIT PROGRAM
	END TRY

	IF lockMode THEN
		SET LOCK MODE TO WAIT 3 
	END IF
	CALL fgl_setEnv("DBCON",l_db)

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION gldb_getDBName() RETURNS STRING
	RETURN m_dbnam
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION gldb_getDBType() RETURNS STRING
	DEFINE drv STRING
	IF m_dbtyp IS NULL THEN
		LET drv = fgl_getenv("DBDRIVER")
		IF drv IS NULL OR drv = " " THEN LET drv = DEF_DBDRIVER END IF
		LET m_dbtyp = drv.subString(4,6)
	END IF
	RETURN m_dbtyp
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION gldb_getDBInfo() RETURNS ( STRING, STRING, STRING, STRING )
	RETURN m_dbtyp, m_dbsrc, m_dbdrv, m_dbcon
END FUNCTION




--------------------------------------------------------------------------------
#+ Show Information for a Failed Connections. Debug.
#+
#+ @param stat Status
#+ @param dbname Database Name
FUNCTION gldb_showInfo(stat,dbname) --{{{
	DEFINE stat INTEGER
	DEFINE dbname STRING
	DEFINE dbtyp CHAR(3)
	DEFINE driver, logname STRING
	
	OPEN WINDOW info WITH FORM "show_info"

	DISPLAY "FGLDIR" TO lab1
	DISPLAY fgl_getenv("FGLDIR") TO fld1
	DISPLAY "FGLASDIR" TO lab2
	DISPLAY fgl_getenv("FGLASDIR") TO fld2
	DISPLAY "FGLPROFILE" TO lab3
	DISPLAY fgl_getenv("FGLPROFILE") TO fld3
	DISPLAY "DBNAME" TO lab4
	DISPLAY dbname TO fld4
	DISPLAY "dbi.database."||dbname||".source" TO lab5
	DISPLAY fgl_getResource("dbi.database."||dbname||".source") TO fld5

	DISPLAY "dbi.database."||dbname||".driver" TO lab6
	LET driver = fgl_getResource("dbi.database."||dbname||".driver")
	DISPLAY driver TO fld6

	LET dbtyp = driver.subString(4,6)
	IF dbtyp IS NULL THEN
		DISPLAY "No driver in FGLPROFILE!!!" TO lab7
	ELSE
		DISPLAY "dbi.database."||dbname||"."||dbtyp||".schema" TO lab7
	END IF
	DISPLAY fgl_getResource("dbi.database."||dbname||"."||dbtyp||".schema") TO fld7

	DISPLAY "dbsrc" TO lab8
	DISPLAY m_dbsrc TO fld8

	DISPLAY "dbconn" TO lab9
	DISPLAY m_dbcon TO fld9

	DISPLAY "DBPATH" TO lab10
	DISPLAY fgl_getenv("DBPATH") TO fld10

	DISPLAY "LD_LIBRARY_PATH" TO lab11
	DISPLAY fgl_getenv("LD_LIBRARY_PATH") TO fld11

	DISPLAY "LOGNAME" TO lab12
	LET logname = fgl_getenv("LOGNAME")
	IF logname IS NULL OR logname.getLength() < 1 THEN
		LET logname = fgl_getenv("USERNAME")
	END IF
	IF logname IS NULL OR logname.getLength() < 1 THEN
		LET logname = "(null)"
	END IF
	DISPLAY logname TO fld12

	DISPLAY "STATUS" TO lab13
	DISPLAY stat TO fld13
	DISPLAY "SQLSTATE" TO lab14
	DISPLAY SQLSTATE TO fld14
	DISPLAY "SQLERRMESSAGE" TO lab15
	DISPLAY SQLERRMESSAGE TO fld15

	MENU "Info"
		ON ACTION exit EXIT MENU
		ON ACTION close EXIT MENU
	END MENU

	CLOSE WINDOW info

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Process the status after an SQL Statement.
#+
#+ @param l_line Line number - should be __LINE__
#+ @param l_mod Module name - should be __FILE__
#+ @param l_stmt = String: The SQL Statement / Message, Can be NULL.
#+ @return TRUE/FALSE.  Success / Failed
FUNCTION gl_sqlStatus(l_line, l_mod, l_stmt) --{{{
	DEFINE l_mod, l_stmt STRING
	DEFINE l_line, l_stat INTEGER

	LET l_stat = STATUS
	LET l_mod = l_mod||" Line:",(l_line USING "<<<<<<<")
	IF l_stat = 0 THEN RETURN TRUE END IF
	IF l_stmt IS NULL THEN
		CALL gl_winMessage("Error","Status:"||l_stat||"\nSqlState:"||SQLSTATE||"\n"||SQLERRMESSAGE||"\n"||l_mod,"exclamation")
	ELSE
		CALL gl_winMessage("Error",l_stmt||"\nStatus:"||l_stat||"\nSqlState:"||SQLSTATE||"\n"||SQLERRMESSAGE||"\n"||l_mod,"exclamation")
		GL_DBGMSG(0, "gl_sqlStatus: Stmt         ='"||l_stmt||"'")
	END IF
	GL_DBGMSG(0, "gl_sqlStatus: WHERE        :"||l_mod)
	GL_DBGMSG(0, "gl_sqlStatus: STATUS       :"||l_stat)
	GL_DBGMSG(0, "gl_sqlStatus: SQLSTATE     :"||SQLSTATE)
	GL_DBGMSG(0, "gl_sqlStatus: SQLERRMESSAGE:"||SQLERRMESSAGE)

	RETURN FALSE

END FUNCTION --}}}