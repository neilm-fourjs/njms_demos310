
IMPORT util
IMPORT FGL gl_lib
IMPORT FGL gl_calendar

&include "genero_lib.inc"	
CONSTANT C_VER="3.1"
DEFINE m_data DYNAMIC ARRAY OF RECORD
		labs STRING,
		vals INTEGER,
		days ARRAY [31] OF INTEGER
	END RECORD

DEFINE m_data2 DYNAMIC ARRAY OF RECORD
		labs STRING,
		vals INTEGER
	END RECORD
MAIN
	DEFINE l_data STRING

	CALL gl_lib.gl_init(ARG_VAL(1),NULL,TRUE)
	LET gl_lib.gl_noToolBar = TRUE

	OPEN FORM f FROM "wc_d3charts_demo"
	DISPLAY FORM f

	CALL genRndData()
	LET l_data = getData(0)
	DIALOG ATTRIBUTES(UNBUFFERED)
		INPUT BY NAME l_data ATTRIBUTE(WITHOUT DEFAULTS)
		END INPUT
		DISPLAY ARRAY m_data2 TO arr.*
		END DISPLAY

		ON ACTION close EXIT DIALOG
		GL_ABOUT
		ON ACTION quit EXIT DIALOG
	END DIALOG
	CALL gl_lib.gl_exitProgram(0,%"Program Finished")
END MAIN
--------------------------------------------------------------------------------
FUNCTION genRndData()
	DEFINE x,y SMALLINT

	CALL m_data.clear()
	FOR x = 1 TO 12
		LET m_data[x].labs = x
		LET m_data[x].labs = gl_calendar.month_fullName_int(x)
		LET m_data[x].vals = 0
		LET m_data2[x].labs = m_data[x].labs
		FOR y = 1 TO days_in_month( x )
			LET m_data[x].days[y] = util.math.rand(50)
			LET m_data[x].vals = m_data[x].vals + m_data[x].days[y]
		END FOR
		LET m_data2[x].vals = m_data[x].vals
	END FOR

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getData(l_month)
	DEFINE l_month, l_max SMALLINT
	DEFINE l_jo util.JSONObject
	DEFINE l_ja util.JSONArray
	DEFINE x SMALLINT
	DEFINE l_val INTEGER
	LET l_jo = util.JSONObject.create()
	LET l_ja = util.JSONArray.create()

	IF l_month = 0 THEN 
		LET l_max = m_data.getLength()
	ELSE
		LET l_max = m_data[l_month].days.getLength()
	END IF

	FOR x = 1 TO l_max
		LET l_jo = util.JSONObject.create()
		IF l_month = 0 THEN
			LET l_val = m_data[x].vals
			CALL l_jo.put( "name",  NVL( m_data[x].labs.subString(1,3), x) )
			CALL l_jo.put( "value", l_val )
		ELSE
			LET l_val = m_data[l_month].days[x]
			CALL l_jo.put( "name", x )
			CALL l_jo.put( "value",l_val )
		END IF
		CALL l_ja.put( x, l_jo )
	END FOR

	DISPLAY "JSONData:",l_ja.toString()
	RETURN l_ja.toString()
END FUNCTION