IMPORT util
IMPORT FGL wc_fglsvgcalendar
IMPORT FGL gl_calendar

PUBLIC DEFINE rec record
  curr_month smallint,
  curr_year  smallint,
  calendar string
END RECORD

PUBLIC TYPE t_cb_set_date FUNCTION(l_dte DATE)
PUBLIC DEFINE selected_date DATE
PUBLIC DEFINE dag_textar DICTIONARY OF STRING

PRIVATE DEFINE cb_sdate t_cb_set_date
PRIVATE DEFINE curdate DATE, cid INTEGER
PRIVATE DEFINE m_lang CHAR(2)
--------------------------------------------------------------------------------
#+ Callback function for returning the selected date
#+
#+ @code
#+ CALL return_date (function my_getdate) 
#+
#+ @param l_date The start date
#+ @param l_setDateCallBack Function for the callback
#+ @oaram l_lang EN or IS
FUNCTION init(l_date DATE, l_setDateCallBack t_cb_set_date, l_lang CHAR(2)) -- Start

  IF l_date IS NULL THEN LET l_date = TODAY END IF

	LET m_lang = UPSHIFT( NVL(l_lang,"EN") )
  LET cb_sdate = l_setDateCallBack
	LET wc_fglsvgcalendar.m_isHoliday = FUNCTION isHoliday -- call back for holiday tests
  CALL wc_fglsvgcalendar.initialize()
  LET cid = wc_fglsvgcalendar.create("formonly.calendar")
  CALL set_type(cid, FGLCALENDAR_TYPE_DEFAULT)
  CALL wc_fglsvgcalendar.setColorTheme(cid, FGLCALENDAR_THEME_DEFAULT)
  CALL wc_fglsvgcalendar.showDayNames(cid, true)
  CALL wc_fglsvgcalendar.showDayNumbers(cid, true)
  CALL wc_fglsvgcalendar.showweekNumbers(cid, false)
  LET rec.curr_year = YEAR(l_date)
  LET rec.curr_month = MONTH(l_date)
  LET selected_date = l_date
  LET curdate = l_date
  CALL ui.Interface.Refresh()
  CALL wc_fglsvgcalendar.addSelectedDate(cid, l_date)
  CALL wc_fglsvgcalendar.display(cid, rec.curr_year, rec.curr_month)

END FUNCTION
--------------------------------------------------------------------------------
#+ The calendar subdialog input.
DIALOG calendar()

	INPUT BY NAME rec.* ATTRIBUTES(WITHOUT DEFAULTS, NAME="sd_calendar")
		ON CHANGE curr_year 
			CALL wc_fglsvgcalendar.display(cid, rec.curr_year, rec.curr_month)

		ON CHANGE curr_month
			IF rec.curr_month < 1 THEN
				LET rec.curr_year = rec.curr_year - 1
				LET rec.curr_month = 12
			END IF
			if rec.curr_month > 12 THEN
				LET rec.curr_year = rec.curr_year + 1
				LET rec.curr_month = 1
			END IF
			CALL wc_fglsvgcalendar.display(cid, rec.curr_year, rec.curr_month)
		--	CALL DIALOG.nextField("xxx")

		ON ACTION prevmonth
			DISPLAY "PrevMonth Current - Year: ", rec.curr_year, " Month:",rec.curr_month
			IF rec.curr_month = 1 THEN
				LET rec.curr_year = rec.curr_year - 1
				LET rec.curr_month = 12
			ELSE
				LET rec.curr_month = rec.curr_month - 1
			END IF
			CALL wc_fglsvgcalendar.display(cid, rec.curr_year, rec.curr_month)

		ON ACTION nextmonth
			DISPLAY "NextMonth Current - Year: ", rec.curr_year, " Month:",rec.curr_month
			IF rec.curr_month = 12 THEN
				LET rec.curr_year = rec.curr_year + 1
				LET rec.curr_month = 1
			ELSE
				LET rec.curr_month = rec.curr_month + 1
			END IF
			CALL wc_fglsvgcalendar.display(cid, rec.curr_year, rec.curr_month)

		ON ACTION calendar_selection
			LET selected_date = wc_fglsvgcalendar.getSelectedDateFromValue(cid, rec.calendar)
			MESSAGE "Selected: ",selected_date
			IF selected_date != curdate THEN
				CALL wc_fglsvgcalendar.removeSelectedDate(cid, curdate)
				LET rec.curr_month = MONTH(selected_date)
				LET rec.curr_year = YEAR(selected_date)
				CALL wc_fglsvgcalendar.addSelectedDate(cid, selected_date)
				LET curdate = selected_date
				CALL wc_fglsvgcalendar.display(cid, rec.curr_year, rec.curr_month)
				IF cb_sdate IS NOT NULL THEN CALL cb_sdate(curdate) END IF
			END IF
	END INPUT

END DIALOG
--------------------------------------------------------------------------------
FUNCTION setTexts(dic dictionary of string)
  CALL wc_fglsvgcalendar.setText(dic)
END FUNCTION  
--------------------------------------------------------------------------------
FUNCTION finish()
	CALL wc_fglsvgcalendar.destroy(cid)
	CALL wc_fglsvgcalendar.finalize()
END FUNCTION  
--------------------------------------------------------------------------------
PRIVATE FUNCTION set_type(c_id SMALLINT, l_type SMALLINT)
	CALL wc_fglsvgcalendar.setViewType(c_id, l_type)
	CASE m_lang
		WHEN "IS"
			IF  l_type = FGLCALENDAR_TYPE_DEFAULT THEN
				CALL wc_fglsvgcalendar.setDayNames(cid, C_DAYS3_IS)
			ELSE
				CALL wc_fglsvgcalendar.setDayNames(cid, C_DAYS1_IS)
			END IF
			CALL wc_fglsvgcalendar.setMonthNames(cid, C_MONTHS_IS)
		WHEN "ES"
			IF  l_type = FGLCALENDAR_TYPE_DEFAULT THEN
				CALL wc_fglsvgcalendar.setDayNames(cid, C_DAYS3_ES)
			ELSE
				CALL wc_fglsvgcalendar.setDayNames(cid, C_DAYS1_ES)
			END IF
			CALL wc_fglsvgcalendar.setMonthNames(cid, C_MONTHS_ES)
		WHEN "PT"
			IF  l_type = FGLCALENDAR_TYPE_DEFAULT THEN
				CALL wc_fglsvgcalendar.setDayNames(cid, C_DAYS3_PT)
			ELSE
				CALL wc_fglsvgcalendar.setDayNames(cid, C_DAYS1_PT)
			END IF
			CALL wc_fglsvgcalendar.setMonthNames(cid, C_MONTHS_PT)
	END CASE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION isHoliday(l_dte DATE) RETURNS ( BOOLEAN, STRING )
	DEFINE l_txt STRING

	IF MONTH( l_dte ) = 12 AND DAY( l_dte ) = 25 THEN
		LET l_txt = "XMas"
	END IF

	IF l_txt IS NOT NULL THEN
		RETURN TRUE, l_txt
	ELSE
		RETURN FALSE, NULL
	END IF
END FUNCTION