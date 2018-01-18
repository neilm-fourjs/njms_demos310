
TYPE t_init_cb FUNCTION( l_cb ui.ComboBox )
TYPE t_inpt_func FUNCTION( l_new BOOLEAN )
TYPE t_before_inp_func FUNCTION( l_new BOOLEAN, l_d ui.Dialog )
TYPE t_after_inp_func FUNCTION( l_new BOOLEAN, l_d ui.Dialog ) RETURNS BOOLEAN

TYPE t_fields RECORD
		colname STRING,
		type STRING
	END RECORD
TYPE t_fld_props RECORD
		name STRING,
		tabname STRING,
		colname STRING,
		label STRING,
		len SMALLINT,
		iskey BOOLEAN,
		numeric BOOLEAN,
		hidden BOOLEAN,
		noentry BOOLEAN,
		value STRING,
		formFieldNode om.DomNode,
		widget STRING,
		widget_prop1 STRING,
		widget_prop2 STRING,
		widget_prop3 STRING,
		widget_callback t_init_cb
	END RECORD

CONSTANT SQL_FIRST = 0
CONSTANT SQL_PREV = -1
CONSTANT SQL_NEXT = -2
CONSTANT SQL_LAST = -3
