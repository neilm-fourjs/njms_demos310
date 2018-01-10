
&include "dynMaint.inc"

# Build a form based on an array of field names and an array of properties.
#+ @param l_db Database name
#+ @param l_tab Table name
#+ @param l_fld_per_page Fields per page ( folder tabs )
#+ @param l_fields Array of field names / types
#+ @param l_fld_props Array of field properties.
PUBLIC DEFINE m_fld_props DYNAMIC ARRAY OF t_fld_props
PUBLIC DEFINE m_formName STRING
PUBLIC DEFINE m_w ui.Window
PUBLIC DEFINE m_f ui.Form
--------------------------------------------------------------------------------
FUNCTION init_form(
	l_db STRING,
	l_tab STRING, 
	l_fld_per_page SMALLINT, 
	l_fields DYNAMIC ARRAY OF t_fields
	)
	DEFINE l_n om.DomNode
	DEFINE l_nl om.NodeList
	DEFINE x, y SMALLINT
	LET m_w = ui.Window.getCurrent()
	LET m_formName = "dm_"||l_db.trim().toLowerCase()||"_"||l_tab.trim().toLowerCase()
	TRY
		OPEN FORM dynMaint FROM m_formName
	CATCH
		CALL mk_form(l_tab, l_fld_per_page, l_fields )
		RETURN
	END TRY
	DISPLAY FORM dynMaint 
	LET m_f = m_w.getForm()
	LET l_n = m_f.getNode()
	LET l_nl = l_n.selectByTagName("FormField")
	FOR x = 1 TO l_fields.getLength()
		CALL setProperties(x, l_tab, l_fields, m_fld_props)
		FOR y = 1 TO l_nl.getLength()
			LET l_n = l_nl.item(y)
			IF l_n.getAttribute("name") = m_fld_props[x].tabname||"."||l_fields[x].colname THEN
				LET m_fld_props[x].formFieldNode = l_n
			END IF
		END FOR
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION mk_form(l_tab STRING,	l_fld_per_page SMALLINT, 	l_fields DYNAMIC ARRAY OF t_fields)
	DEFINE l_n_form, l_n_grid,l_n_formfield, l_n_widget, l_folder, l_container om.DomNode
	DEFINE x, y, l_first_fld, l_last_fld, l_maxlablen SMALLINT
	DEFINE l_pages DECIMAL(3,1)

	LET l_n_form = m_w.getNode()
	CALL l_n_form.setAttribute("style","main2")
	LET m_f = m_w.createForm(m_formName)
	LET l_n_form = m_f.getNode()
	CALL l_n_form.setAttribute("windowStyle","main2")

	LET l_pages =  l_fields.getLength() / l_fld_per_page
	IF l_pages > 1 THEN -- Folder Tabs
		LET l_folder = l_n_form.createChild("Folder")
	ELSE
		LET l_container = l_n_form.createChild("VBox")
		LET l_last_fld = l_fields.getLength()
	END IF
	LET l_first_fld = 1
	DISPLAY "Fields:",l_fields.getLength()," Pages:",l_pages

	FOR y = 1 TO (l_pages+1)
		IF l_pages > 1 THEN
			LET l_container = l_folder.createChild("Page")
			CALL l_container.setAttribute("text","Page "||y)
			LET l_last_fld = l_last_fld + l_fld_per_page
			IF l_last_fld > l_fields.getLength() THEN LET l_last_fld = l_fields.getLength() END IF
		END IF

		LET l_n_grid = l_container.createChild("Grid")
		CALL m_w.setText(SFMT(%"Dynamic Maintenance for %1",l_tab))

		FOR x = l_first_fld TO l_last_fld
			CALL setProperties(x, l_tab, l_fields, m_fld_props)
			LET l_n_formfield = l_n_grid.createChild("Label")
			CALL l_n_formfield.setAttribute("text", m_fld_props[x].label )
			CALL l_n_formfield.setAttribute("posY", x )
			CALL l_n_formfield.setAttribute("posX", "1" )
			CALL l_n_formfield.setAttribute("gridWidth", m_fld_props[x].label.getLength() )
			IF m_fld_props[x].label.getLength() > l_maxlablen THEN LET l_maxlablen = m_fld_props[x].label.getLength() END IF
		END FOR
		FOR x = l_first_fld TO l_last_fld
			LET l_n_formfield = l_n_grid.createChild("FormField")
			LET m_fld_props[x].formFieldNode = l_n_formfield
			CALL l_n_formfield.setAttribute("colName", l_fields[x].colname )
			CALL l_n_formfield.setAttribute("name", m_fld_props[x].tabname||"."||l_fields[x].colname )
			CALL l_n_formfield.setAttribute("numAlign", m_fld_props[x].numeric)

			IF l_fields[x].type = "DATE" THEN
				LET l_n_widget = l_n_formField.createChild("DateEdit")
			ELSE
				LET l_n_widget = l_n_formField.createChild("Edit")
			END IF
			CALL l_n_widget.setAttribute("posY", x )
			CALL l_n_widget.setAttribute("posX", l_maxlablen+1 )
			CALL l_n_widget.setAttribute("gridWidth", m_fld_props[x].len )
			CALL l_n_widget.setAttribute("width", m_fld_props[x].len)
			CALL l_n_widget.setAttribute("comment", "Type:"||l_fields[x].type )
			IF m_fld_props[x].numeric THEN
				CALL l_n_widget.setAttribute("justify", "right")
			END IF
		END FOR
		LET l_first_fld = l_first_fld + l_fld_per_page
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
-- set the screen field nodes value to the values from the db
FUNCTION update_form_value(l_sql_handle base.SqlHandle)
	DEFINE x SMALLINT
	FOR x = 1 TO m_fld_props.getLength()
		IF  m_fld_props[x].formFieldNode IS NOT NULL THEN
			CALL m_fld_props[x].formFieldNode.setAttribute("value", l_sql_handle.getResultValue(x))
		END IF
	END FOR
	CALL ui.Interface.refresh()
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION setProperties(
	l_fldno SMALLINT,
	l_tab STRING,
	l_fields DYNAMIC ARRAY OF t_fields,
	l_fld_props DYNAMIC ARRAY OF t_fld_props
 )
	DEFINE l_typ, l_typ2 STRING
	DEFINE l_len SMALLINT
	DEFINE x, y SMALLINT
	DEFINE l_num BOOLEAN

	LET l_num = TRUE
	LET l_typ =  l_fields[l_fldno].type
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
	LET l_fld_props[l_fldno].tabname = l_tab
	LET l_fld_props[l_fldno].colname = l_fields[l_fldno].colname
	LET l_fld_props[l_fldno].label = pretty_lab(l_fields[l_fldno].colname)
	LET l_fld_props[l_fldno].len = l_len
	LET l_fld_props[l_fldno].numeric = l_num
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