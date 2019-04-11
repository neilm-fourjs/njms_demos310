IMPORT util
IMPORT FGL gl_lib
IMPORT FGL gl_calendar
IMPORT FGL wc_d3charts
&include "genero_lib.inc"
CONSTANT C_VER = "3.1"
CONSTANT C_PRGDESC = "WC Charts Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"
DEFINE m_data DYNAMIC ARRAY OF RECORD
  labs STRING,
  vals INTEGER,
  days ARRAY[31] OF INTEGER
END RECORD
DEFINE m_graph_data DYNAMIC ARRAY OF wc_d3charts.t_d3_rec
DEFINE m_monthView BOOLEAN
MAIN
  DEFINE l_debug BOOLEAN
  CALL gl_lib.gl_setInfo(C_VER, NULL, NULL, C_PRGDESC, C_PRGDESC, C_PRGAUTH)
  CALL gl_lib.gl_init(arg_val(1), NULL, TRUE)
  LET gl_lib.gl_noToolBar = TRUE

-- Is the WC debug feature enabled?
  CALL ui.Interface.frontCall("standard", "getenv", ["QTWEBENGINE_REMOTE_DEBUGGING"], l_debug)
  DISPLAY "DEBUG:", l_debug

  CALL genRndData()

-- Pass the d3charts library my click handler function.
  LET wc_d3charts.m_d3_clicked = FUNCTION clicked
  CALL wc_d3charts.wc_d3_init(700, 500, "My Sales")
  LET wc_d3charts.m_y_label = "Total Sales"
  CALL setData(0) --MONTH( CURRENT ) )

  OPEN FORM f FROM "wc_d3charts_demo"
  DISPLAY FORM f

  DIALOG ATTRIBUTES(UNBUFFERED)

    SUBDIALOG wc_d3charts.d3_wc

    DISPLAY ARRAY m_graph_data TO arr.*
    END DISPLAY
    BEFORE DIALOG
      IF NOT l_debug THEN
        CALL DIALOG.setActionActive("wc_debug", FALSE)
      END IF
    ON ACTION newData
      CALL genRndData()
      CALL setData(0)
    ON ACTION wc_debug
      CALL ui.Interface.frontCall("standard", "launchURL", "http://localhost:" || l_debug, [])
    GL_ABOUT
    ON ACTION quit
      EXIT DIALOG
    ON ACTION close
      EXIT DIALOG
  END DIALOG
  CALL gl_lib.gl_exitProgram(0, % "Program Finished")
END MAIN
--------------------------------------------------------------------------------
-- My Click handler
FUNCTION clicked(x SMALLINT)
  DISPLAY "Clicked:", x
  LET m_monthView = NOT m_monthView
  IF m_monthView THEN
    LET x = 0
  END IF
  CALL setData(x)
END FUNCTION
--------------------------------------------------------------------------------
-- Set data that I want in the graph
FUNCTION setData(l_month SMALLINT)
  DEFINE x SMALLINT
  CALL m_graph_data.clear()

  IF l_month > 0 THEN
    LET m_monthView = FALSE
    LET wc_d3charts.m_x_label = "Days"
    LET wc_d3charts.m_title = "Sales for ", gl_calendar.month_fullName_int(l_month)
    FOR x = 1 TO gl_calendar.days_in_month(l_month)
      LET m_graph_data[x].labs = x
      LET m_graph_data[x].vals = m_data[l_month].days[x]
      LET m_graph_data[x].action_name = "back"
    END FOR
  ELSE
    LET m_monthView = TRUE
    LET wc_d3charts.m_x_label = "Months"
    FOR x = 1 TO 12
      LET m_graph_data[x].labs = gl_calendar.month_fullName_int(x)
      LET m_graph_data[x].vals = m_data[x].vals
      LET m_graph_data[x].action_name = "item" || x
    END FOR
  END IF

  CALL wc_d3charts.wc_d3_setData(m_graph_data)
END FUNCTION
--------------------------------------------------------------------------------
-- Generate my random test data
FUNCTION genRndData()
  DEFINE x, y SMALLINT
  CALL m_data.clear()
  DISPLAY "Generating Random Test Data ..."
  FOR x = 1 TO 12
    LET m_data[x].labs = gl_calendar.month_fullName_int(x)
    LET m_data[x].vals = 0
    FOR y = 1 TO gl_calendar.days_in_month(x)
      LET m_data[x].days[y] = 5 + util.math.rand(50)
      LET m_data[x].vals = m_data[x].vals + m_data[x].days[y]
    END FOR
  END FOR
END FUNCTION
