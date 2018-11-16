
IMPORT util

--------------------------------------------------------------------------------
-- MONTH FUNCTIONS
--------------------------------------------------------------------------------
--
FUNCTION month_fullName_int(m SMALLINT)
	RETURN month_fullName( MDY(m,1,2000) )
END FUNCTION
--------------------------------------------------------------------------------
--
FUNCTION month_shortName_int(m SMALLINT)
	RETURN month_shortName( MDY(m,1,2000) )
END FUNCTION
--------------------------------------------------------------------------------
--
FUNCTION month_fullName( dt DATETIME YEAR TO DAY )
	RETURN util.DateTime.format(dt,"%B")
END FUNCTION
--------------------------------------------------------------------------------
--
FUNCTION month_shortName( dt DATETIME YEAR TO DAY )
	RETURN util.DateTime.format(dt,"%b")
END FUNCTION
--------------------------------------------------------------------------------
-- DAY FUNCTIONS
--------------------------------------------------------------------------------
--
FUNCTION day_fullName( dt DATETIME YEAR TO DAY )
	RETURN util.DateTime.format(dt,"%A")
END FUNCTION
--------------------------------------------------------------------------------
--
FUNCTION day_shortName( dt DATETIME YEAR TO DAY )
	RETURN util.DateTime.format(dt,"%a")
END FUNCTION
--------------------------------------------------------------------------------
--
FUNCTION isWeekEnd(l_date DATE)
	RETURN WEEKDAY(l_date) = 0 or WEEKDAY(l_date) = 6
END FUNCTION
--------------------------------------------------------------------------------