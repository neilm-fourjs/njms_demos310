
IMPORT util
IMPORT FGL gl_lib
&include "genero_lib.inc"

IMPORT FGL glm_sql
IMPORT FGL glm_mkForm
&include "dynMaint.inc"

DEFINE m_dialog ui.Dialog
PUBLIC DEFINE m_before_inp_func t_before_inp_func -- callback function
PUBLIC DEFINE m_after_inp_func t_after_inp_func -- callback function
PUBLIC DEFINE m_inpt_func t_inpt_func -- input callback function
--------------------------------------------------------------------------------
FUNCTION glm_menu(l_allowedActions STRING )
	IF m_inpt_func IS NULL THEN LET m_inpt_func = FUNCTION glm_inpt END IF
	MENU
		BEFORE MENU
			CALL setActions(glm_sql.m_row_cur, glm_sql.m_row_count, l_allowedActions)
		ON ACTION insert		CALL m_inpt_func(TRUE)
		ON ACTION update		CALL m_inpt_func(FALSE)
		ON ACTION delete		CALL glm_sql.glm_SQLdelete()
		ON ACTION find			CALL glm_constrct()
			CALL setActions(glm_sql.m_row_cur,glm_sql.m_row_count, l_allowedActions)
		ON ACTION firstrow	CALL glm_sql.glm_getRow(SQL_FIRST, TRUE)
			CALL setActions(glm_sql.m_row_cur,glm_sql.m_row_count, l_allowedActions)
		ON ACTION prevrow		CALL glm_sql.glm_getRow(SQL_PREV, TRUE)
			CALL setActions(glm_sql.m_row_cur,glm_sql.m_row_count, l_allowedActions)
		ON ACTION nextrow		CALL glm_sql.glm_getRow(SQL_NEXT, TRUE)
			CALL setActions(glm_sql.m_row_cur,glm_sql.m_row_count, l_allowedActions)
		ON ACTION lastrow		CALL glm_sql.glm_getRow(SQL_LAST, TRUE)
			CALL setActions(glm_sql.m_row_cur,glm_sql.m_row_count, l_allowedActions)
		ON ACTION quit			EXIT MENU
		ON ACTION close			EXIT MENU
		GL_ABOUT
	END MENU

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION glm_constrct()
	DEFINE m_dialog ui.Dialog
	DEFINE x SMALLINT
	DEFINE l_query, l_sql STRING

	LET m_dialog = ui.Dialog.createConstructByName(glm_sql.m_fields)

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

	FOR x = 1 TO glm_sql.m_fields.getLength()
		LET l_query = m_dialog.getQueryFromField(glm_sql.m_fields[x].colname)
		IF l_query.getLength() > 0 THEN
			IF l_sql IS NOT NULL THEN LET l_sql = l_sql.append(" AND ") END IF
			LET l_sql = l_sql.append(l_query)
		END IF
	END FOR

	CALL glm_sql.glm_mkSQL( glm_sql.m_cols, l_sql )
	CALL glm_sql.glm_getRow(SQL_FIRST, TRUE)

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION glm_inpt(l_new BOOLEAN)
	DEFINE x SMALLINT

	CALL ui.Dialog.setDefaultUnbuffered(TRUE)
	LET m_dialog = ui.Dialog.createInputByName(glm_sql.m_fields)

	IF l_new THEN
	ELSE
		IF glm_sql.m_row_cur = 0 THEN RETURN END IF
		FOR x = 1 TO m_fields.getLength()
--			CALL m_dialog.setFieldValue(glm_mkForm.m_fld_props[x].name, glm_sql.m_sql_handle.getResultValue(x))
			CALL m_dialog.setFieldValue(glm_mkForm.m_fld_props[x].name, glm_mkForm.m_fld_props[x].value )
			DISPLAY glm_mkForm.m_fld_props[x].colname," = \"",glm_mkForm.m_fld_props[x].value,"\" AUI Value = \"",m_dialog.getFieldValue(glm_mkForm.m_fld_props[x].name),"\""
			IF x = glm_sql.m_key_fld THEN
				CALL m_dialog.setFieldActive(glm_sql.m_fields[x].colname, FALSE )
			END IF
		END FOR
	END IF

	CALL m_dialog.addTrigger("ON ACTION close")
	CALL m_dialog.addTrigger("ON ACTION cancel")
	CALL m_dialog.addTrigger("ON ACTION accept")
	LET int_flag = FALSE
	WHILE TRUE
		CASE m_dialog.nextEvent()
			WHEN "BEFORE INPUT"
				IF m_before_inp_func IS NOT NULL THEN CALL m_before_inp_func(l_new, m_dialog) END IF
			WHEN "AFTER INPUT"
				CALL glm_updateJsonRec()
				IF m_after_inp_func IS NOT NULL THEN 
					IF m_after_inp_func(l_new, m_dialog) THEN
						EXIT WHILE
					END IF
				ELSE
					EXIT WHILE
				END IF
			WHEN "ON ACTION close"
				LET int_flag = TRUE
				EXIT WHILE
			WHEN "ON ACTION accept"
				CALL m_dialog.accept()
			WHEN "ON ACTION cancel"
				CALL m_dialog.cancel()
				EXIT WHILE
		END CASE
	END WHILE
	IF NOT int_flag THEN
		IF l_new THEN 
			CALL glm_sql.glm_SQLinsert(m_dialog)
		ELSE
			CALL glm_sql.glm_SQLupdate(m_dialog)
		END IF
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION glm_updateJsonRec()
	DEFINE x SMALLINT
	LET glm_mkForm.m_json_rec = util.JSONObject.create()
	FOR x = 1 TO m_fld_props.getLength()
		IF  m_fld_props[x].formFieldNode IS NOT NULL THEN
			LET glm_mkForm.m_fld_props[x].value = m_dialog.getFieldValue(glm_mkForm.m_fld_props[x].name)
		END IF
		CALL m_json_rec.put(glm_mkForm.m_fld_props[x].colname, glm_mkForm.m_fld_props[x].value)
	END FOR
	DISPLAY m_json_rec.toString()

END FUNCTION
--------------------------------------------------------------------------------
-- Setup actions based on a allowed actions
PRIVATE FUNCTION setActions(l_row INT, l_max INT,l_allowedActions CHAR(6))
	DEFINE d ui.Dialog
&define ACT_FIND l_allowedActions[1]
&define ACT_UPD l_allowedActions[2]
&define ACT_INS l_allowedActions[3]
&define ACT_DEL l_allowedActions[4]
&define ACT_SAM l_allowedActions[5]
&define ACT_LIST l_allowedActions[6]
	LET d = ui.Dialog.getCurrent()
	CALL d.setActionActive("update",FALSE)
	CALL d.setActionActive("delete",FALSE)
	CALL d.setActionActive("lastrow",FALSE)
	CALL d.setActionActive("nextrow",FALSE)
	CALL d.setActionActive("prevrow",FALSE)
	CALL d.setActionActive("firstrow",FALSE)
	IF ACT_FIND = "N" THEN CALL d.setActionActive("find",FALSE) END IF
--	IF ACT_LIST = "N" THEN CALL d.setActionActive("list",FALSE) END IF
	IF ACT_INS = "N" THEN CALL d.setActionActive("insert",FALSE) END IF
	IF l_row > 0 THEN
		IF ACT_UPD = "Y" THEN CALL d.setActionActive("update",TRUE) END IF
		IF ACT_DEL = "Y" THEN CALL d.setActionActive("delete",TRUE) END IF
	END IF
	IF l_row > 0 AND l_row < l_max THEN
		CALL d.setActionActive("nextrow",TRUE)
		CALL d.setActionActive("lastrow",TRUE)
	END IF
	IF l_row > 1 THEN
		CALL d.setActionActive("prevrow",TRUE)
		CALL d.setActionActive("firstrow",TRUE)
	END IF 
END FUNCTION
--------------------------------------------------------------------------------