GLOBALS "wizard_glob.inc"
--------------------------------------------------------------------------------
FUNCTION init_prog(l_form STRING, l_text STRING, l_title STRING)
	DISPLAY "FGLRESOURCEPATH:",fgl_getEnv("FGLRESOURCEPATH")
	CALL init_arrays()

	CALL ui.Interface.loadStyles("default_"||ui.Interface.getFrontEndName())

	OPEN FORM w FROM l_form
	DISPLAY FORM w
	CALL ui.Interface.setText(l_text)
	CALL fgl_settitle(l_title)

	LET currTable = 1
	CALL on_change_currTable()

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION left( d ) -- move row(s) to the left
	DEFINE d ui.Dialog
	DEFINE i, x SMALLINT	

-- NOTE: can't do this in one loop because the row numbers change when you delete!
-- 1st move the data from 1 array to the other
	LET x = 0
	FOR i = 1 TO rfields.getLength()
		IF d.isRowSelected("r", i) THEN
			LET lfields[lfields.getLength() + 1] = rfields[ i ]
			LET x = x + 1
		END IF
	END FOR
-- now delete from source array 
	FOR i = lfields.getLength() TO 1 STEP -1
		IF d.isRowSelected("r", i) THEN
			CALL rfields.deleteElement( i )
			IF x > 1 THEN
				CALL d.setSelectionRange("r", i, i, FALSE) -- deselect the row
			END IF
		END IF
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION right( d ) -- move row(s) to the right
	DEFINE d ui.Dialog
	DEFINE i, x SMALLINT	

-- NOTE: can't do this in one loop because the row numbers change when you delete!
-- 1st move the data from 1 array to the other
	LET x = 0
	FOR i = 1 TO lfields.getLength()
		IF d.isRowSelected("l", i) THEN
			LET rfields[rfields.getLength() + 1] = lfields[ i ]
			LET x = x + 1
		END IF
	END FOR
-- now delete from source array 
	FOR i = lfields.getLength() TO 1 STEP -1
		IF d.isRowSelected("l", i) THEN
			CALL lfields.deleteElement( i )
			IF x > 1 THEN
				CALL d.setSelectionRange("l", i, i, FALSE) -- deselect the row
			END IF
		END IF
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION left_md( d ) -- move row(s) to the left
	DEFINE d ui.Dialog
	DEFINE i SMALLINT	

	LET i = arr_curr()
	LET lfields[lfields.getLength() + 1] = rfields[ i ]
	CALL d.deleteRow("r", i)

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION right_md( d ) -- move row(s) to the right
	DEFINE d ui.Dialog
	DEFINE i SMALLINT	

	LET i = arr_curr()
	LET rfields[rfields.getLength() + 1] = lfields[ i ]
	CALL d.deleteRow("l", i)

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION allleft()
	DEFINE i SMALLINT
	FOR i = 1 TO rfields.getLength()
		LET lfields[lfields.getLength() + 1] = rfields[ i ]
	END FOR
	CALL rfields.clear()
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION allright()
	DEFINE i SMALLINT
	FOR i = 1 TO lfields.getLength()
		LET rfields[rfields.getLength() + 1] = lfields[ i ]
	END FOR
	CALL lfields.clear()
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION on_change_currTable()
	DEFINE i SMALLINT

	CALL lfields.clear()

	IF currTable IS NULL OR currTable > columns.getLength() THEN
		LET currTable = columns.getLength()
	END IF
	FOR i = 1 TO columns[currTable].colname.getLength()
		LET lfields[i] = columns[currTable].colname[i]
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION cb_init(cb)
	DEFINE cb ui.comboBox
	DEFINE i SMALLINT
	CALL cb.clear()
	FOR i = 1 TO tables.getLength()
		CALL cb.addItem(i,tables[i])
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION init_arrays()

	LET tables[ tables.getLength() + 1] = "customer"
	LET tables[ tables.getLength() + 1] = "orders"
	LET tables[ tables.getLength() + 1] = "stock"

	LET columns[1].tabno = 1
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "cust_no"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "cust_name"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "cust_address1"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "cust_address2"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "cust_address3"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "cust_address4"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "cust_address5"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "cust_postcode"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "office_tel_no"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "mobile_tel_no"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "fax_no"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "email_addr1"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "email_addr2"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "vat_no"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "credit_limit"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "balance"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "terms"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "prev_inv_amount"
	LET columns[1].colname[ columns[1].colname.getLength() + 1] = "prev_paid_amount"

	LET columns[2].tabno = 2
	LET columns[2].colname[ columns[2].colname.getLength() + 1] = "order_no"
	LET columns[2].colname[ columns[2].colname.getLength() + 1] = "order_date"
	LET columns[2].colname[ columns[2].colname.getLength() + 1] = "order_ref"
	LET columns[2].colname[ columns[2].colname.getLength() + 1] = "cust_no"

	LET columns[3].tabno = 3
	LET columns[3].colname[ columns[3].colname.getLength() + 1] = "stock_no"
	LET columns[3].colname[ columns[3].colname.getLength() + 1] = "desc"
	LET columns[3].colname[ columns[3].colname.getLength() + 1] = "manu_code"
	LET columns[3].colname[ columns[3].colname.getLength() + 1] = "unit_price"
	LET columns[3].colname[ columns[3].colname.getLength() + 1] = "unit_cost"
	LET columns[3].colname[ columns[3].colname.getLength() + 1] = "warehouse1"
	LET columns[3].colname[ columns[3].colname.getLength() + 1] = "warehouse2"
	LET columns[3].colname[ columns[3].colname.getLength() + 1] = "warehouse3"

END FUNCTION