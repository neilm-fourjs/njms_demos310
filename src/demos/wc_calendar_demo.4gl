IMPORT FGL wc_calendar
DEFINE m_lang STRING
DEFINE m_selected_date DATE
MAIN
  DEFINE l_debug STRING

  OPEN FORM f1 FROM "wc_calendar_demo"
  DISPLAY FORM f1

  MESSAGE "Ver:", fgl_getversion()
-- Is the WC debug feature enabled?
  CALL ui.Interface.frontCall("standard", "getenv", ["QTWEBENGINE_REMOTE_DEBUGGING"], l_debug)
  DISPLAY "DEBUG:", l_debug
  LET m_lang = fgl_getenv("LANG")
  DISPLAY m_lang TO lang
  LET m_selected_date = TODAY
  CALL wc_calendar.init(m_selected_date, FUNCTION set_date, m_lang) -- Start
  DIALOG ATTRIBUTES(UNBUFFERED)

    INPUT BY NAME m_selected_date ATTRIBUTES(WITHOUT DEFAULTS, NAME = "sel_date")
    END INPUT

    SUBDIALOG wc_calendar.calendar

    ON ACTION cancel
      EXIT DIALOG
    ON ACTION close
      EXIT DIALOG
    ON ACTION wc_debug
      CALL ui.Interface.frontCall("standard", "launchURL", "http://localhost:" || l_debug, [])

    BEFORE DIALOG
      IF l_debug IS NULL THEN
        CALL DIALOG.setActionHidden("wc_debug", TRUE)
      END IF
  END DIALOG
  CALL wc_calendar.finish() -- Complete
END MAIN
--------------------------------------------------------------------------------
FUNCTION set_date(l_dte DATE) -- Call back function for getting selected date.
  LET m_selected_date = l_dte
END FUNCTION
