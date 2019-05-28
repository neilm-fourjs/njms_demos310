--https://www.amcharts.com/
IMPORT util
IMPORT os
IMPORT FGL g2_lib
IMPORT FGL g2_about
IMPORT FGL g2_appInfo
IMPORT FGL g2_calendar

CONSTANT C_PRGVER = "3.1"
CONSTANT C_PRGDESC = "WC Charts Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_PRGICON = "njm_demo_icon"

DEFINE m_data DYNAMIC ARRAY OF RECORD
  labs STRING,
  vals INTEGER,
  days ARRAY[31] OF INTEGER
END RECORD

DEFINE m_data2 DYNAMIC ARRAY OF RECORD
  labs STRING,
  vals INTEGER
END RECORD

DEFINE m_appInfo g2_appInfo.appInfo
MAIN
  DEFINE l_data STRING
  CALL m_appInfo.progInfo(C_PRGDESC, C_PRGAUTH, C_PRGVER, C_PRGICON)
  CALL g2_lib.g2_init(ARG_VAL(1), "default")

  DISPLAY "RT PATH:", fgl_getenv("PATH")
  CALL ui.Interface.frontCall("standard", "getenv", "PATH", l_data)
  DISPLAY "FE PATH:", l_data
  IF os.Path.pathSeparator() = ":" THEN
    DISPLAY "RT LD_LIBRARY_PATH:", fgl_getenv("LD_LIBRARY_PATH")
    CALL ui.Interface.frontCall("standard", "getenv", "LD_LIBRARY_PATH", l_data)
    DISPLAY "FE LD_LIBRARY_PATH:", l_data
  END IF

  OPEN FORM f FROM "wc_amcharts"
  DISPLAY FORM f

  CALL genRndData()
  LET l_data = getData(0)
  DIALOG ATTRIBUTES(UNBUFFERED)
    INPUT BY NAME l_data ATTRIBUTE(WITHOUT DEFAULTS)
    END INPUT
    DISPLAY ARRAY m_data2 TO arr.*
    END DISPLAY
    ON ACTION back
      DISPLAY "BACK"
      CALL setGraphTitle("title", "Sales")
      LET l_data = getData(0)
    ON ACTION newData
      CALL setGraphTitle("title", "Sales")
      CALL genRndData()
      LET l_data = getData(0)
    ON ACTION close
      EXIT DIALOG
		ON ACTION about
			CALL g2_about.g2_about(m_appInfo)
    ON ACTION quit
      EXIT DIALOG
    ON ACTION act1
      DISPLAY "Data:", l_data
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(1))
      LET l_data = getData(1)
    ON ACTION act2
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(2))
      LET l_data = getData(2)
    ON ACTION act3
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(3))
      LET l_data = getData(3)
    ON ACTION act4
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(4))
      LET l_data = getData(4)
    ON ACTION act5
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(5))
      LET l_data = getData(5)
    ON ACTION act6
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(6))
      LET l_data = getData(6)
    ON ACTION act7
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(7))
      LET l_data = getData(7)
    ON ACTION act8
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(8))
      LET l_data = getData(8)
    ON ACTION act9
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(9))
      LET l_data = getData(9)
    ON ACTION act10
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(10))
      LET l_data = getData(10)
    ON ACTION act11
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(11))
      LET l_data = getData(11)
    ON ACTION act12
      CALL setGraphTitle("title", g2_calendar.month_fullName_int(12))
      LET l_data = getData(12)
  END DIALOG
  CALL g2_lib.g2_exitProgram(0, % "Program Finished")
END MAIN
--------------------------------------------------------------------------------
FUNCTION setGraphTitle(l_prop, l_val)
  DEFINE l_prop, l_val STRING
  DEFINE w ui.Window
  DEFINE n om.domNode
  LET w = ui.Window.getCurrent()
  LET n = w.findNode("Property", l_prop)
  IF n IS NULL THEN
    DISPLAY "can't find property:", l_prop
    RETURN
  END IF
  CALL n.setAttribute("value", l_val)

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION genRndData()
  DEFINE x, y SMALLINT

  CALL m_data.clear()
  FOR x = 1 TO 12
    LET m_data[x].labs = x
    LET m_data[x].labs = g2_calendar.month_fullName_int(x)
    LET m_data[x].vals = 0
    LET m_data2[x].labs = m_data[x].labs
    FOR y = 1 TO g2_calendar.days_in_month(x)
      LET m_data[x].days[y] = util.math.rand(50)
      LET m_data[x].vals = m_data[x].vals + m_data[x].days[y]
    END FOR
    LET m_data2[x].vals = m_data[x].vals
  END FOR

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getColor(x)
  DEFINE x SMALLINT
  DEFINE l_col STRING

  IF x MOD 2 THEN
    LET x = x * 5
    LET l_col = "#FF00" || dec2hex(x)
  ELSE
    LET x = x * 5
    LET l_col = "#00" || dec2hex(x) || "FF"
  END IF
  --DISPLAY l_col
  RETURN l_col
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getData(l_month)
  DEFINE l_month, l_max SMALLINT
  DEFINE jo util.JSONObject
  DEFINE ja util.JSONArray
  DEFINE x SMALLINT
  DEFINE l_val INTEGER
  LET jo = util.JSONObject.create()
  LET ja = util.JSONArray.create()

  IF l_month = 0 THEN
    LET l_max = m_data.getLength()
  ELSE
    LET l_max = m_data[l_month].days.getLength()
  END IF

  FOR x = 1 TO l_max
    LET jo = util.JSONObject.create()
    IF l_month = 0 THEN
      CALL jo.put("action", "act" || x)
      LET l_val = m_data[x].vals
      CALL jo.put("label", NVL(m_data[x].labs.subString(1, 3), x))
    ELSE
      CALL jo.put("action", "back")
      LET l_val = m_data[l_month].days[x]
      CALL jo.put("label", x)
    END IF

    CALL jo.put("value", l_val)
    CALL jo.put("colour", getColor(x))

    CALL ja.put(x, jo)
  END FOR
  DISPLAY "JSONData:", ja.toString()
  RETURN ja.toString()
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION dec2hex(l_x)
  DEFINE l_x, l_y INTEGER
  DEFINE l_ch CHAR(2)
  LET l_y = l_x / 16
  LET l_ch[1] = l_y
  IF l_y > 9 THEN
    LET l_ch[1] = ASCII (55 + l_y)
  END IF
  LET l_x = l_x - (l_y * 16)
  LET l_ch[2] = l_x
  IF l_x > 9 THEN
    LET l_ch[2] = ASCII (55 + l_x)
  END IF
  RETURN l_ch
END FUNCTION
