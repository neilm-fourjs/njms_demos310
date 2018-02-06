IMPORT FGL gl_lib

&include "genero_lib.inc"
CONSTANT C_VER="3.1"
CONSTANT C_PRGDESC = "OnFocus Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"

TYPE t_matrix4 RECORD
		s1 STRING,
		c1 STRING,
		s2 STRING,
		c2 STRING,
		s3 STRING,
		c3 STRING,
		s4 STRING,
		c4 STRING
	END RECORD
CONSTANT C_UNCHECKED = "fa-square-o"
CONSTANT C_CHECKED = "fa-check-square-o"
CONSTANT C_HIGHLIGHT = "bold reverse lightCyan"
DEFINE m_colours DYNAMIC ARRAY OF STRING -- list of colours available
DEFINE m_col_matrix DYNAMIC ARRAY OF t_matrix4 -- colours & checkbox
DEFINE m_attr_matrix DYNAMIC ARRAY OF t_matrix4 -- colours attributes for highlighting
DEFINE m_sel_colours DYNAMIC ARRAY OF STRING -- selected colours
DEFINE m_like BOOLEAN
MAIN

	CALL gl_lib.gl_setInfo(C_VER, NULL, NULL, NULL, C_PRGDESC, C_PRGAUTH)
	CALL gl_lib.gl_init( ARG_VAL(1) ,NULL,TRUE)
	CALL ui.Interface.setText( gl_lib.gl_progdesc )

	OPEN FORM f FROM "multi_cell_sel"
	DISPLAY FORM f

	CALL pop_array("../etc/colours.txt", m_colours )
	CALL fill_matrix( m_colours, m_col_matrix )

	DIALOG ATTRIBUTES(UNBUFFERED)
		DISPLAY ARRAY m_col_matrix TO cols.* ATTRIBUTES(FOCUSONFIELD)
			BEFORE DISPLAY
				NEXT FIELD c1
			BEFORE FIELD s1 CALL upd_colr(DIALOG, "1")
			BEFORE FIELD s2 CALL upd_colr(DIALOG, "2")
			BEFORE FIELD s3 CALL upd_colr(DIALOG, "3")
			BEFORE FIELD s4 CALL upd_colr(DIALOG, "4")
		END DISPLAY

		DISPLAY ARRAY m_sel_colours TO selcols.*
		END DISPLAY

		ON ACTION like CALL like(DIALOG.getForm())
		ON ACTION close EXIT DIALOG
		ON ACTION quit EXIT DIALOG
	END DIALOG
END MAIN
--------------------------------------------------------------------------------
FUNCTION toggle(l_val)
	DEFINE l_val STRING
	IF l_val = C_UNCHECKED THEN
		LET l_val = C_CHECKED
	ELSE
		LET l_val = C_UNCHECKED
	END IF
	RETURN l_val
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION like(f)
	DEFINE f ui.form
	LET m_like = NOT m_like
	IF m_like THEN
		CALL f.setElementImage("like","fa-thumbs-up")
	ELSE
		CALL f.setElementImage("like","fa-thumbs-down")
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION upd_colr(d,l_fld)
	DEFINE d ui.Dialog
	DEFINE l_fld STRING
	DEFINE x SMALLINT
	CASE l_fld
		WHEN "1"
			LET m_col_matrix[ arr_curr() ].s1 = toggle(  m_col_matrix[ arr_curr() ].s1 )
		WHEN "2"
			LET m_col_matrix[ arr_curr() ].s2 = toggle(  m_col_matrix[ arr_curr() ].s2 )
		WHEN "3"
			LET m_col_matrix[ arr_curr() ].s3 = toggle(  m_col_matrix[ arr_curr() ].s3 )
		WHEN "4"
			LET m_col_matrix[ arr_curr() ].s4 = toggle(  m_col_matrix[ arr_curr() ].s4 )
	END CASE
	CALL m_sel_colours.clear()
	FOR x = 1 TO m_col_matrix.getLength()
		IF m_col_matrix[x].s1 = C_CHECKED THEN 
			LET m_sel_colours[m_sel_colours.getLength()+1] =  m_col_matrix[x].c1
			LET m_attr_matrix[x].c1 = C_HIGHLIGHT
			LET m_attr_matrix[x].s1 = C_HIGHLIGHT
		END IF
		IF m_col_matrix[x].s2 = C_CHECKED THEN
			LET m_sel_colours[m_sel_colours.getLength()+1] =  m_col_matrix[x].c2
			LET m_attr_matrix[x].c2 = C_HIGHLIGHT
			LET m_attr_matrix[x].s2 = C_HIGHLIGHT
		END IF
		IF m_col_matrix[x].s3 = C_CHECKED THEN
			LET m_sel_colours[m_sel_colours.getLength()+1] =  m_col_matrix[x].c3
			LET m_attr_matrix[x].c3 = C_HIGHLIGHT
			LET m_attr_matrix[x].s3 = C_HIGHLIGHT
		END IF
		IF m_col_matrix[x].s4 = C_CHECKED THEN
			LET m_sel_colours[m_sel_colours.getLength()+1] =  m_col_matrix[x].c4
			LET m_attr_matrix[x].c4 = C_HIGHLIGHT
			LET m_attr_matrix[x].s4 = C_HIGHLIGHT
		END IF
	END FOR
	CALL d.nextField("+NEXT") -- next field
	CALL d.setArrayAttributes("cols",m_attr_matrix)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION fill_matrix(l_arr, l_matrix )
	DEFINE l_arr DYNAMIC ARRAY OF STRING
	DEFINE l_matrix DYNAMIC ARRAY OF t_matrix4
	DEFINE x,y,z SMALLINT
	LET y = 0
	LET z = 1
	FOR x = 1 TO l_arr.getLength()
		LET y = y + 1
		CASE y
			WHEN 1 LET l_matrix[z].c1 = l_arr[x] LET l_matrix[z].s1 = C_UNCHECKED
			WHEN 2 LET l_matrix[z].c2 = l_arr[x] LET l_matrix[z].s2 = C_UNCHECKED
			WHEN 3 LET l_matrix[z].c3 = l_arr[x] LET l_matrix[z].s3 = C_UNCHECKED
			WHEN 4 LET l_matrix[z].c4 = l_arr[x] LET l_matrix[z].s4 = C_UNCHECKED
							LET z = z + 1
							LET y = 0
		END CASE
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION pop_array(l_file, l_arr)
	DEFINE l_file STRING
	DEFINE l_arr DYNAMIC ARRAY OF STRING
	DEFINE c base.channel
	LET c = base.Channel.create()
	CALL c.openFile(l_file,"r")
	WHILE NOT c.isEof()
		LET l_arr[ l_arr.getLength() + 1 ] = c.readLine()
	END WHILE
	CALL l_arr.deleteElement(l_arr.getLength())
	CALL c.close()
END FUNCTION