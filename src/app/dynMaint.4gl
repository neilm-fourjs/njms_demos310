
-- A Basic dynamic maintenance program.
-- Does do:
--	find, update, insert, delete
--
-- Doesn't do:
--	locking
--	folder tab forms for 'long' tables

-- Command Args:
-- 1: MDI / SDI 
-- 2: User Account Id
-- 3: Table name
-- 4: Primary Key name
-- 5: Allowed actions

IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL app_lib
&include "genero_lib.inc"
&include "app.inc"

CONSTANT PRGDESC = "Dynamic Maintenance Demo"
CONSTANT PRGAUTH = "Neil J.Martin"
CONSTANT C_VER="3.1"

CONSTANT SQL_FIRST = 0
CONSTANT SQL_PREV = -1
CONSTANT SQL_NEXT = -2
CONSTANT SQL_LAST = -3

DEFINE m_tab STRING
DEFINE m_key_nam STRING
DEFINE m_fields DYNAMIC ARRAY OF RECORD
		name STRING,
		type STRING
	END RECORD
DEFINE m_fld_props DYNAMIC ARRAY OF RECORD
		label STRING,
		len SMALLINT,
		numeric BOOLEAN,
		formFieldNode om.DomNode
	END RECORD
DEFINE m_where STRING
DEFINE m_key_fld SMALLINT
DEFINE m_sql_handle base.SqlHandle
DEFINE m_dialog ui.Dialog
DEFINE m_row_count, m_row_cur INTEGER
DEFINE m_user_key INTEGER
DEFINE m_allowedActions CHAR(6) --Y/N for Find / List / Update / Insert / Delete / Sample
                              -- NNYNNN = Only update allowed.
MAIN
	LET gl_lib.gl_toolbar = "dynmaint"
	LET gl_lib.gl_topMenu = "dynmaint"
	CALL gl_lib.gl_setInfo(C_VER, APP_SPLASH, APP_ICON, NULL, PRGDESC, PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),"default",TRUE)

	LET m_user_key = ARG_VAL(2)
	LET m_tab = ARG_VAL(3)
	LET m_key_nam = ARG_VAL(4)
	LET m_allowedActions  = ARG_VAL(5)

	CALL gl_db.gldb_connect(NULL)

	SELECT * FROM sys_users WHERE user_key = m_user_key
	IF STATUS != 0 THEN 
		CALL gl_lib.gl_errPopup(SFMT(%"Invalid Account '%1'!",m_user_key))
		CALL gl_lib.gl_exitProgram(1,%"invalid account")
	END IF

	IF m_tab IS NULL THEN 
		CALL gl_lib.gl_errPopup(SFMT(%"Invalid Table '%1'!",m_tab))
		CALL gl_lib.gl_exitProgram(1,%"invalid table")
	END IF

	IF m_key_nam IS NULL THEN 
		CALL gl_lib.gl_errPopup(SFMT(%"Invalid Key Name '%1'!",m_key_nam))
		CALL gl_lib.gl_exitProgram(1,%"invalid key name")
	END IF

	LET m_key_fld = 0
	LET m_row_cur = 0
	LET m_row_count = 0

	CALL mk_sql( "1=2" ) -- not fetching any data.
	CALL mk_form()
	CALL gl_lib.gl_titleWin(NULL)
 	CALL ui.Interface.setText( gl_lib.gl_progdesc )
	MENU
		BEFORE MENU
			CALL app_lib.setActions(m_row_cur,m_row_count, m_allowedActions)
		ON ACTION insert		CALL inpt(1)
		ON ACTION update		CALL inpt(0)
		ON ACTION delete		CALL sql_del()
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
		LET m_fields[x].name = m_sql_handle.getResultName(x)
		LET m_fields[x].type = m_sql_handle.getResultType(x)
		IF m_fields[x].name.trim() = m_key_nam.trim() THEN
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
FUNCTION mk_form()
	DEFINE l_w ui.Window
	DEFINE l_f ui.Form
	DEFINE l_n_form, l_n_tb, l_n_grid,l_n_formfield, l_n_widget  om.DomNode
	DEFINE x, l_maxlablen SMALLINT

	LET l_w = ui.Window.getCurrent()
	LET l_n_form = l_w.getNode()
	CALL l_n_form.setAttribute("style","main2")

	LET l_f = l_w.createForm("dyn_"||m_tab)
	LET l_n_form = l_f.getNode()
	CALL l_n_form.setAttribute("windowStyle","main2")
	LET l_n_tb = l_n_form.createChild("ToolBar")
	CALL add_toolbarItem(l_n_tb, "quit","Quit","quit")
	CALL add_toolbarItem(l_n_tb, "accept","Accept","accept")
	CALL add_toolbarItem(l_n_tb, "cancel","Cancel","cancel")
	CALL add_toolbarItem(l_n_tb, "find","Find","find")
	CALL add_toolbarItem(l_n_tb, "insert","Insert","new")
	CALL add_toolbarItem(l_n_tb, "update","Update","pen")
	CALL add_toolbarItem(l_n_tb, "delete","Delete","delete")
	CALL add_toolbarItem(l_n_tb, "firstrow","","")
	CALL add_toolbarItem(l_n_tb, "prevrow","","")
	CALL add_toolbarItem(l_n_tb, "nextrow","","")
	CALL add_toolbarItem(l_n_tb, "lastrow","","")

	LET l_n_grid = l_n_form.createChild("Grid")
	CALL l_w.setText(SFMT(%"Dynamic Maintenance for %1",m_tab))
	FOR x = 1 TO m_fields.getLength()
		CALL setProperties(x)
		LET l_n_formfield = l_n_grid.createChild("Label")
		CALL l_n_formfield.setAttribute("text", m_fld_props[x].label )
		CALL l_n_formfield.setAttribute("posY", x )
		CALL l_n_formfield.setAttribute("posX", "1" )
		CALL l_n_formfield.setAttribute("gridWidth", m_fld_props[x].label.getLength() )
		IF m_fld_props[x].label.getLength() > l_maxlablen THEN LET l_maxlablen = m_fld_props[x].label.getLength() END IF
	END FOR
	FOR x = 1 TO m_fields.getLength()
		LET l_n_formfield = l_n_grid.createChild("FormField")
		LET m_fld_props[x].formFieldNode = l_n_formfield
		CALL l_n_formfield.setAttribute("colName", m_fields[x].name )
		CALL l_n_formfield.setAttribute("name", m_tab||"."||m_fields[x].name )
		IF m_fields[x].type = "DATE" THEN
			LET l_n_widget = l_n_formField.createChild("DateEdit")
		ELSE
			LET l_n_widget = l_n_formField.createChild("Edit")
		END IF
		CALL l_n_widget.setAttribute("posY", x )
		CALL l_n_widget.setAttribute("posX", l_maxlablen+1 )
		CALL l_n_widget.setAttribute("gridWidth", m_fld_props[x].len )
		CALL l_n_widget.setAttribute("width", m_fld_props[x].len)
		CALL l_n_widget.setAttribute("comment", "Type:"||m_fields[x].type )
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION get_row(l_row)
	DEFINE l_row INTEGER
	DEFINE x SMALLINT
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
		FOR x = 1 TO m_fields.getLength()
			CALL m_fld_props[x].formFieldNode.setAttribute("value", m_sql_handle.getResultValue(x))
		END FOR
		CALL ui.Interface.refresh()
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
	IF int_flag THEN
		LET int_flag = FALSE
		RETURN 
	END IF

	FOR x = 1 TO m_fields.getLength()
		LET l_query = m_dialog.getQueryFromField(m_fields[x].name)
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
			--DISPLAY "Field:",m_fields[x].name,":",m_fields[x].type
			CALL m_dialog.setFieldValue(m_tab||"."||m_fields[x].name, m_sql_handle.getResultValue(x))
			IF x = m_key_fld THEN
				CALL m_dialog.setFieldActive(m_fields[x].name, FALSE )
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
	IF int_flag THEN LET int_flag = FALSE END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION setProperties( l_fldno SMALLINT )
	DEFINE l_typ, l_typ2 STRING
	DEFINE l_len SMALLINT
	DEFINE x, y SMALLINT
	DEFINE l_num BOOLEAN

	LET l_num = TRUE
	LET l_typ =  m_fields[l_fldno].type
	IF l_typ = "SMALLINT" THEN LET l_len = 5 END IF
	IF l_typ = "INTEGER" OR l_typ = "SERIAL" THEN LET l_len = 10 END IF
	IF l_typ = "DATE" THEN LET l_len = 10 END IF
	LET l_typ2 = l_typ

	LET x = l_typ.getIndexOf("(",1)
	IF x > 0 THEN
		LET l_typ2 = l_typ.subString(1, x-1 )
		LET y = l_typ.getIndexOf(",",x)
		IF y = 0 THEN
			LET y = l_typ.getIndexOf(")",x)
		END IF
		LET l_len = l_typ.subString(x+1,y-1)
	END IF

	IF l_typ2 = "CHAR" OR l_typ2 = "VARCHAR" OR l_typ2 = "DATE" THEN
		LET l_num = FALSE
	END IF
	LET m_fld_props[l_fldno].label = pretty_lab(m_fields[l_fldno].name)
	LET m_fld_props[l_fldno].len = l_len
	LET m_fld_props[l_fldno].numeric = l_num
END FUNCTION
--------------------------------------------------------------------------------
-- Upshift 1st letter : replace _ with space : split capitalised names
FUNCTION pretty_lab( l_lab VARCHAR(60) ) RETURNS STRING
	DEFINE x,l_len SMALLINT
	LET l_len = LENGTH( l_lab )
	FOR x = 2 TO l_len
		IF l_lab[x] >= "A" AND l_lab[x] <= "Z" THEN 
			LET l_lab = l_lab[1,x-1]||" "||l_lab[x,60]
			LET l_len = l_len + 1
			LET x = x + 1
		END IF
		IF l_lab[x] = "_" THEN LET l_lab[x] = " " END IF
	END FOR
	LET l_lab[1] = UPSHIFT(l_lab[1])
	RETURN (l_lab CLIPPED)||":"
END FUNCTION
--------------------------------------------------------------------------------
-- add a toolbar item
FUNCTION add_toolbarItem( l_n, l_nam, l_txt, l_img )
	DEFINE l_n om.DomNode
	DEFINE l_nam, l_txt, l_img STRING
	LET l_n = l_n.createChild("ToolBarItem")
	CALL l_n.setAttribute("name", l_nam )
	IF l_txt IS NOT NULL THEN
		CALL l_n.setAttribute("text", l_txt )
	END IF
	IF l_img IS NOT NULL THEN
		CALL l_n.setAttribute("image", l_img )
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION sql_update()
	DEFINE l_sql, l_val, l_key STRING
	DEFINE x SMALLINT

	LET l_sql = "update "||m_tab||" SET ("
	FOR x = 1 TO m_fields.getLength()
		IF x != m_key_fld THEN
			LET l_sql = l_sql.append( m_fields[x].name )
			IF x != m_fields.getLength() THEN
				LET l_sql = l_sql.append(",")
			END IF
		END IF
	END FOR
	LET l_sql = l_sql.append(") = (")
	FOR x = 1 TO m_fields.getLength()
		IF x != m_key_fld THEN
			IF m_fld_props[x].numeric THEN
				LET l_val = NVL(m_dialog.getFieldValue(m_tab||"."||m_fields[x].name) ,"NULL")
			ELSE
				LET l_val = NVL("'"||m_dialog.getFieldValue(m_tab||"."||m_fields[x].name)||"'" ,"NULL")
			END IF
			LET l_sql = l_sql.append( l_val )
			IF x != m_fields.getLength() THEN
				LET l_sql = l_sql.append(",")
			END IF
		ELSE
			LET l_key = m_dialog.getFieldValue(m_tab||"."||m_fields[x].name)
		END IF
	END FOR
	LET l_sql = l_sql.append(") where "||m_key_nam||" = ?")
	TRY
		PREPARE upd_stmt FROM l_sql
		EXECUTE upd_stmt USING l_key
	CATCH
	END TRY
	IF SQLCA.sqlcode = 0 THEN
		LET x = m_row_cur
		CALL mk_sql( m_where )
		CALL get_row(x)
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
		LET l_sql = l_sql.append( m_fields[x].name )
		IF x != m_fields.getLength() THEN
			LET l_sql = l_sql.append(",")
		END IF
	END FOR
	LET l_sql = l_sql.append(") values(")
	FOR x = 1 TO m_fields.getLength()
		LET l_val = NVL("'"||m_dialog.getFieldValue(m_tab||"."||m_fields[x].name)||"'" ,"NULL")
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
	IF m_row_cur = 0 THEN RETURN END IF
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
