
IMPORT FGL gl_lib
IMPORT FGL glm_mkForm
&include "dynMaint.inc"

PUBLIC DEFINE m_where, m_cols STRING
PUBLIC DEFINE m_tab STRING
PUBLIC DEFINE m_key_nam STRING
PUBLIC DEFINE m_sql_handle base.SqlHandle
PUBLIC DEFINE m_fields DYNAMIC ARRAY OF t_fields
PUBLIC DEFINE m_row_count, m_row_cur INTEGER
PUBLIC DEFINE m_key_fld SMALLINT
--------------------------------------------------------------------------------
FUNCTION glm_mkSQL(l_cols STRING, l_where STRING)
	DEFINE l_sql STRING
	DEFINE x SMALLINT
	IF l_where.getLength() < 1 THEN LET l_where = "1=1" END IF
	LET m_where = l_where
	LET m_cols = l_cols

	LET l_sql = "select "||l_cols||" from "||m_tab||" where "||l_where
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
--	MESSAGE "Rows "||m_row_cur||" of "||m_row_count
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION glm_getRow(l_row INTEGER, l_msg BOOLEAN)
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
		CALL glm_mkForm.update_form_value( m_sql_handle )
		IF l_msg THEN	MESSAGE SFMT(%"Rows %1 of %2",m_row_cur,m_row_count) END IF
	END IF
END FUNCTION
--------------------------------------------------------------------------------
-- NOTE: Need to find an alternative way to handle the SQL to stop sql-injection
FUNCTION glm_SQLupdate(l_dialog ui.Dialog)
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
			IF glm_mkForm.m_fld_props[x].numeric THEN
				LET l_val = NVL(l_dialog.getFieldValue(glm_mkForm.m_fld_props[x].name) ,"NULL")
			ELSE
				LET l_val = NVL("'"||l_dialog.getFieldValue(glm_mkForm.m_fld_props[x].name)||"'" ,"NULL")
			END IF
			LET l_sql = l_sql.append( l_val )
			IF x != m_fields.getLength() THEN
				LET l_sql = l_sql.append(",")
			END IF
		ELSE
			LET l_key = l_dialog.getFieldValue(glm_mkForm.m_fld_props[x].name)
		END IF
	END FOR
	LET l_sql = l_sql.append(") where "||m_key_nam||" = ?")
	TRY
		PREPARE upd_stmt FROM l_sql
		EXECUTE upd_stmt USING l_key
		MESSAGE "Record Updated."
	CATCH
		ERROR "Update Failed!"
	END TRY
	IF SQLCA.sqlcode = 0 THEN -- refresh the cursor so it shows the updated row.
		CALL glm_mkSQL(m_cols, m_where)
		CALL glm_getRow(m_row_cur, FALSE)
	ELSE
		CALL gl_lib.gl_errPopup(SFMT(%"Failed to update record!\n%1!",SQLERRMESSAGE))
	END IF
END FUNCTION
--------------------------------------------------------------------------------
-- NOTE: Need to find an alternative way to handle the SQL to stop sql-injection
FUNCTION glm_SQLinsert(l_dialog ui.Dialog)
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
		LET l_val = NVL("'"||l_dialog.getFieldValue(glm_mkForm.m_fld_props[x].name)||"'" ,"NULL")
		LET l_sql = l_sql.append( l_val )
		IF x != m_fields.getLength() THEN
			LET l_sql = l_sql.append(",")
		END IF
	END FOR
	LET l_sql = l_sql.append(")")
	TRY
		PREPARE ins_stmt FROM l_sql
		EXECUTE ins_stmt
		MESSAGE "Record Inserted."
	CATCH
		ERROR "Insert Failed!"
	END TRY
	IF SQLCA.sqlcode = 0 THEN
		CALL glm_mkSQL(m_cols, m_where)
		CALL glm_getRow(SQL_LAST, FALSE)
	ELSE
		CALL gl_lib.gl_errPopup(SFMT(%"Failed to insert record!\n%1!",SQLERRMESSAGE))
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION glm_SQLdelete()
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
			CALL glm_getRow(m_row_cur, FALSE)
		ELSE
			CALL gl_lib.gl_errPopup(SFMT(%"Failed to delete record!\n%1!",SQLERRMESSAGE))
		END IF
	ELSE
		MESSAGE %"Delete aborted."
	END IF
END FUNCTION