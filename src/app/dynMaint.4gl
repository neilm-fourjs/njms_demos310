
-- A Basic dynamic maintenance program.
-- Does: find, update, insert, delete
-- To Do: locking, sample, listing report

-- Command Args:
-- 1: MDI / SDI 
-- 2: Database name
-- 3: Table name
-- 4: Primary Key name
-- 5: Allowed actions: Y/N > Find / Update / Insert / Delete / Sample / List  -- eg: YNNNNN = enquiry only.

IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL app_lib
IMPORT FGL mk_form

&include "genero_lib.inc"
&include "dynMaint.inc"

CONSTANT C_VER="3.1"
CONSTANT C_PRGDESC = "Dynamic Maintenance Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_APP_SPLASH = "njm_demo_logo_256"
CONSTANT C_APP_ICON = "njm_demo_icon"

CONSTANT SQL_FIRST = 0
CONSTANT SQL_PREV = -1
CONSTANT SQL_NEXT = -2
CONSTANT SQL_LAST = -3

DEFINE m_tab STRING
DEFINE m_key_nam STRING
DEFINE m_fields DYNAMIC ARRAY OF t_fields
DEFINE m_where STRING
DEFINE m_key_fld SMALLINT
DEFINE m_sql_handle base.SqlHandle
DEFINE m_dialog ui.Dialog
DEFINE m_row_count, m_row_cur INTEGER
DEFINE m_dbname STRING
DEFINE m_allowedActions CHAR(6)
MAIN
	CALL gl_lib.gl_setInfo(C_VER, C_APP_SPLASH, C_APP_ICON, NULL, C_PRGDESC, C_PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),"default",TRUE)
	LET gl_lib.gl_toolBar = "dynmaint"
	LET gl_lib.gl_topMenu = "dynmaint"

	CALL init_args()

	LET m_key_fld = 0
	LET m_row_cur = 0
	LET m_row_count = 0
	CALL mk_sql( "1=2" ) -- not fetching any data.
	CALL mk_form.init_form(m_dbname, m_tab, 10, m_fields) -- 10 fields by folder page
	CALL gl_lib.gl_titleWin(NULL)
	CALL ui.Interface.setText( gl_lib.gl_progdesc )
	MENU
		BEFORE MENU
			CALL app_lib.setActions(m_row_cur, m_row_count, m_allowedActions)
		ON ACTION insert		CALL inpt(1)
		ON ACTION update		IF m_row_cur > 0 THEN CALL inpt(0) END IF
		ON ACTION delete		IF m_row_cur > 0 THEN CALL sql_del() END IF
		ON ACTION find			CALL constrct()
			CALL app_lib.setActions(m_row_cur,m_row_count, m_allowedActions)
		ON ACTION firstrow	CALL get_row(SQL_FIRST)
			CALL app_lib.setActions(m_row_cur,m_row_count, m_allowedActions)
		ON ACTION prevrow		CALL get_row(SQL_PREV)
			CALL app_lib.setActions(m_row_cur,m_row_count, m_allowedActions)
		ON ACTION nextrow		CALL get_row(SQL_NEXT)
			CALL app_lib.setActions(m_row_cur,m_row_count, m_allowedActions)
		ON ACTION lastrow		CALL get_row(SQL_LAST)
			CALL app_lib.setActions(m_row_cur,m_row_count, m_allowedActions)
		ON ACTION quit			EXIT MENU
		ON ACTION close			EXIT MENU
		GL_ABOUT
	END MENU
	CALL gl_lib.gl_exitProgram(0,%"Program Finished")
END MAIN
--------------------------------------------------------------------------------
FUNCTION init_args()
	DEFINE l_user INTEGER
	LET l_user = ARG_VAL(2)
	LET m_dbname = ARG_VAL(3)
	LET m_tab = ARG_VAL(4)
	LET m_key_nam = ARG_VAL(5)
	LET m_allowedActions = ARG_VAL(6)
	IF m_dbname IS NOT NULL THEN
		CALL gl_db.gldb_connect( m_dbname )
	ELSE 
		CALL gl_lib.gl_errPopup(SFMT(%"Invalid Database Name '%1'!",m_dbname))
		CALL gl_lib.gl_exitProgram(1,%"invalid Database")
	END IF
	IF m_tab IS NULL THEN 
		CALL gl_lib.gl_errPopup(SFMT(%"Invalid Table '%1'!",m_tab))
		CALL gl_lib.gl_exitProgram(1,%"invalid table")
	END IF
	IF m_key_nam IS NULL THEN 
		CALL gl_lib.gl_errPopup(SFMT(%"Invalid Key Name '%1'!",m_key_nam))
		CALL gl_lib.gl_exitProgram(1,%"invalid key name")
	END IF
	IF m_allowedActions IS NULL THEN LET m_allowedActions = "YYYYYY" END IF
	DISPLAY "DB:",m_dbname," Tab:",m_tab," Key:",m_key_nam
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION mk_sql(l_where STRING)
	DEFINE l_sql STRING
	DEFINE x SMALLINT
	IF l_where.getLength() < 1 THEN LET l_where = "1=1" END IF
	LET m_where = l_where
	LET l_sql = "select * from "||m_tab||" where "||l_where
	LET m_sql_handle = base.SqlHandle.create()
	TRY
		CALL m_sql_handle.prepare( l_sql )
	CATCH
		CALL gl_lib.gl_errPopup(SFMT(%"Failed to doing prepare for select from '%1'\n%2!",m_tab,SQLERRMESSAGE))
		EXIT PROGRAM
	END TRY
	CALL m_sql_handle.openScrollCursor()
	CALL m_fields.clear()
	FOR x = 1 TO m_sql_handle.getResultCount()
		LET m_fields[x].colname = m_sql_handle.getResultName(x)
		LET m_fields[x].type = m_sql_handle.getResultType(x)
		IF m_fields[x].colname.trim() = m_key_nam.trim() THEN
			LET m_key_fld = x
		END IF
	END FOR
	IF m_key_fld = 0 THEN
		CALL gl_lib.gl_errPopup(SFMT(%"The key field '%1' doesn't appear to be in the table!",m_key_nam.trim()))
		EXIT PROGRAM
	END IF
	IF l_where != "1=2" THEN
		PREPARE count_pre FROM "SELECT COUNT(*) FROM "||m_tab||" WHERE "||l_where
		DECLARE count_cur CURSOR FOR count_pre
		OPEN count_cur
		FETCH count_cur INTO m_row_count
		CLOSE count_cur
		LET m_row_cur = 1
	ELSE
		LET m_row_count = 0
		LET m_row_cur = 0
	END IF
	MESSAGE "Rows "||m_row_cur||" of "||m_row_count
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION get_row(l_row INTEGER)
	IF l_row > m_row_count THEN LET l_row = m_row_count END IF
	CASE l_row
		WHEN SQL_FIRST
			CALL m_sql_handle.fetchFirst()
			LET m_row_cur = 1
		WHEN SQL_PREV
			IF m_row_cur > 1 THEN
				CALL m_sql_handle.fetchPrevious()
				LET m_row_cur = m_row_cur - 1
			END IF
		WHEN SQL_NEXT
			IF m_row_cur < m_row_count THEN
				CALL m_sql_handle.fetch()
				LET m_row_cur = m_row_cur + 1
			END IF
		WHEN SQL_LAST
			CALL m_sql_handle.fetchLast()
			LET m_row_cur = m_row_count
		OTHERWISE
			CALL m_sql_handle.fetchAbsolute(l_row)
			LET m_row_cur = l_row
	END CASE
	IF STATUS = 0 THEN
		CALL mk_form.update_form_value( m_sql_handle )
		MESSAGE SFMT(%"Rows %1 of %2",m_row_cur,m_row_count)
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION constrct()
	DEFINE m_dialog ui.Dialog
	DEFINE x SMALLINT
	DEFINE l_query, l_sql STRING
	LET m_dialog = ui.Dialog.createConstructByName(m_fields)

	CALL m_dialog.addTrigger("ON ACTION close")
	CALL m_dialog.addTrigger("ON ACTION cancel")
	CALL m_dialog.addTrigger("ON ACTION accept")
	LET int_flag = FALSE
	WHILE TRUE
		CASE m_dialog.nextEvent()
			WHEN "ON ACTION close"
				LET int_flag = TRUE
				EXIT WHILE
			WHEN "ON ACTION accept"
				EXIT WHILE
			WHEN "ON ACTION cancel"
				LET int_flag = TRUE
				EXIT WHILE
		END CASE
	END WHILE
	IF int_flag THEN RETURN END IF

	FOR x = 1 TO m_fields.getLength()
		LET l_query = m_dialog.getQueryFromField(m_fields[x].colname)
		IF l_query.getLength() > 0 THEN
			IF l_sql IS NOT NULL THEN LET l_sql = l_sql.append(" AND ") END IF
			LET l_sql = l_sql.append(l_query)
		END IF
	END FOR
	CALL mk_sql( l_sql )
	CALL get_row(0)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION inpt(l_new BOOLEAN)
	DEFINE x SMALLINT

	CALL ui.Dialog.setDefaultUnbuffered(TRUE)
	LET m_dialog = ui.Dialog.createInputByName(m_fields)

	IF l_new THEN
	ELSE
		IF m_row_cur = 0 THEN RETURN END IF
		FOR x = 1 TO m_fields.getLength()
			CALL m_dialog.setFieldValue(mk_form.m_fld_props[x].tabname||"."||m_fields[x].colname, m_sql_handle.getResultValue(x))
			IF x = m_key_fld THEN
				CALL m_dialog.setFieldActive(m_fields[x].colname, FALSE )
			END IF
		END FOR
	END IF

	CALL m_dialog.addTrigger("ON ACTION close")
	CALL m_dialog.addTrigger("ON ACTION cancel")
	CALL m_dialog.addTrigger("ON ACTION accept")
	LET int_flag = FALSE
	WHILE TRUE
		CASE m_dialog.nextEvent()
			WHEN "ON ACTION close"
				LET int_flag = TRUE
				EXIT WHILE
			WHEN "ON ACTION accept"
				IF l_new THEN 
					CALL sql_insert()
				ELSE
					CALL sql_update()
				END IF
				EXIT WHILE
			WHEN "ON ACTION cancel"
				LET int_flag = TRUE
				EXIT WHILE
		END CASE
	END WHILE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION sql_update()
	DEFINE l_sql, l_val, l_key STRING
	DEFINE x SMALLINT
	LET l_sql = "update "||m_tab||" SET ("
	FOR x = 1 TO m_fields.getLength()
		IF x != m_key_fld THEN
			LET l_sql = l_sql.append( m_fields[x].colname )
			IF x != m_fields.getLength() THEN
				LET l_sql = l_sql.append(",")
			END IF
		END IF
	END FOR
	LET l_sql = l_sql.append(") = (")
	FOR x = 1 TO m_fields.getLength()
		IF x != m_key_fld THEN
			IF mk_form.m_fld_props[x].numeric THEN
				LET l_val = NVL(m_dialog.getFieldValue(mk_form.m_fld_props[x].tabname||"."||m_fields[x].colname) ,"NULL")
			ELSE
				LET l_val = NVL("'"||m_dialog.getFieldValue(mk_form.m_fld_props[x].tabname||"."||m_fields[x].colname)||"'" ,"NULL")
			END IF
			LET l_sql = l_sql.append( l_val )
			IF x != m_fields.getLength() THEN
				LET l_sql = l_sql.append(",")
			END IF
		ELSE
			LET l_key = m_dialog.getFieldValue(mk_form.m_fld_props[x].tabname||"."||m_fields[x].colname)
		END IF
	END FOR
	LET l_sql = l_sql.append(") where "||m_key_nam||" = ?")
	TRY
		PREPARE upd_stmt FROM l_sql
		EXECUTE upd_stmt USING l_key
	CATCH
	END TRY
	IF SQLCA.sqlcode = 0 THEN
		CALL mk_sql( m_where )
		CALL get_row(m_row_cur)
	ELSE
		CALL gl_lib.gl_errPopup(SFMT(%"Failed to update record!\n%1!",SQLERRMESSAGE))
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION sql_insert()
	DEFINE l_sql, l_val STRING
	DEFINE x SMALLINT
	LET l_sql = "insert into "||m_tab||" ("
	FOR x = 1 TO m_fields.getLength()
		LET l_sql = l_sql.append( m_fields[x].colname )
		IF x != m_fields.getLength() THEN
			LET l_sql = l_sql.append(",")
		END IF
	END FOR
	LET l_sql = l_sql.append(") values(")
	FOR x = 1 TO m_fields.getLength()
		LET l_val = NVL("'"||m_dialog.getFieldValue(mk_form.m_fld_props[x].tabname||"."||m_fields[x].colname)||"'" ,"NULL")
		LET l_sql = l_sql.append( l_val )
		IF x != m_fields.getLength() THEN
			LET l_sql = l_sql.append(",")
		END IF
	END FOR
	LET l_sql = l_sql.append(")")
	TRY
		PREPARE ins_stmt FROM l_sql
		EXECUTE ins_stmt
	CATCH
	END TRY
	IF SQLCA.sqlcode = 0 THEN
		CALL mk_sql( m_where )
		CALL get_row(SQL_LAST)
	ELSE
		CALL gl_lib.gl_errPopup(SFMT(%"Failed to insert record!\n%1!",SQLERRMESSAGE))
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION sql_del()
	DEFINE l_sql, l_val STRING
	LET l_val = m_sql_handle.getResultValue(m_key_fld)
	LET l_sql = "DELETE FROM "||m_tab||" WHERE "||m_key_nam||" = ?"
	IF gl_lib.gl_winQuestion(%"Confirm",
			SFMT(%"Are you sure you want to delete this record?\n\n%1\nKey = %2",l_sql,l_val),
				%"No",%"Yes|No","question") = %"Yes" THEN
		TRY
			PREPARE del_stmt FROM l_sql
			EXECUTE del_stmt USING l_val
		CATCH
		END TRY
		IF SQLCA.sqlcode = 0 THEN
			LET m_row_count = m_row_count - 1
			CALL get_row(m_row_cur)
		ELSE
			CALL gl_lib.gl_errPopup(SFMT(%"Failed to delete record!\n%1!",SQLERRMESSAGE))
		END IF
	ELSE
		MESSAGE %"Delete aborted."
	END IF
END FUNCTION