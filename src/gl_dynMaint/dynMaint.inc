
TYPE t_init_cb FUNCTION( l_cb ui.ComboBox )
TYPE t_inpt_func FUNCTION( l_new BOOLEAN )
TYPE t_bi_func FUNCTION( l_new BOOLEAN )

TYPE t_fields RECORD
		colname STRING,
		type STRING
	END RECORD
TYPE t_fld_props RECORD
		tabname STRING,
		colname STRING,
		label STRING,
		len SMALLINT,
		numeric BOOLEAN,
		formFieldNode om.DomNode,
		widget STRING,
		widget_props STRING,
		widget_callback t_init_cb
	END RECORD

CONSTANT SQL_FIRST = 0
CONSTANT SQL_PREV = -1
CONSTANT SQL_NEXT = -2
CONSTANT SQL_LAST = -3
