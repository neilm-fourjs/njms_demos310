
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
		formFieldNode om.DomNode
	END RECORD
