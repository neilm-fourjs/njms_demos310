IMPORT os
CONSTANT c_wc_images="../pics/webcomponents/aircraft/"
DEFINE l_breadcrumbs DYNAMIC ARRAY OF STRING
DEFINE m_bc SMALLINT
DEFINE m_panels DYNAMIC ARRAY OF BOOLEAN
DEFINE m_items DYNAMIC ARRAY OF RECORD
		item_txt STRING,
		item_cde STRING,
		item_img STRING
	END RECORD
DEFINE m_galley, m_pos STRING
MAIN
	DEFINE l_wc, l_data STRING
	DEFINE l_f ui.Form

	OPEN FORM f FROM "wc_aircraft"
	DISPLAY FORM f

	LET m_panels[1] = FALSE
	CALL setItem( "x_b777", 1 )

	DIALOG  ATTRIBUTES(UNBUFFERED)
		INPUT BY NAME l_wc, l_data
		END INPUT
		DISPLAY ARRAY m_items TO arr.*
			ON ACTION ACCEPT
				CALL setItem( m_items[ arr_curr() ].item_cde, m_bc + 1 )
		END DISPLAY

		BEFORE DIALOG
			LET l_f = DIALOG.getForm()

		ON ACTION plane
			CALL setItem( "x_b777", 1 )

		ON ACTION selobj 
			LET l_data = l_wc
			CALL setItem( l_wc, m_bc + 1 )

		ON ACTION back
			IF m_bc > 1 THEN
				CALL setItem( l_breadcrumbs[ m_bc - 1 ], m_bc - 1 )
			END IF

		ON ACTION b_panela CALL showPanel(l_f, "panela",1)
		ON ACTION quit EXIT DIALOG
		ON ACTION close EXIT DIALOG
	END DIALOG
END MAIN
--------------------------------------------------------------------------------
#+ Set a Property in the AUI
FUNCTION wc_setProp(l_propName STRING, l_value STRING)
	DEFINE w ui.Window
	DEFINE n om.domNode
	LET w = ui.Window.getCurrent()
	LET n = w.findNode("Property",l_propName)
	IF n IS NULL THEN
		DISPLAY "can't find property:",l_propName
		RETURN
	END IF
	CALL n.setAttribute("value",l_value)
END FUNCTION
--------------------------------------------------------------------------------
#+ Set the svg image into the component.
FUNCTION setSVG( l_nam STRING )
	DISPLAY "setSVG:",l_nam
  CALL wc_setProp("design", "xx"||l_nam) -- force a refresh
  CALL wc_setProp("design", l_nam)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION setItem( l_itemCode STRING, l_bc SMALLINT )
	DEFINE l_img, l_type, l_type_prefix STRING
	DISPLAY "setITmes:", l_itemCode," BC:",l_bc

	IF l_bc > 1 THEN
		CASE l_itemCode.subString(3,4)
			WHEN "g_"
				LET l_img = "fa-archive"
				LET m_galley= l_itemCode.subString(5, l_itemCode.getLength())
				LET l_type_prefix = 7
				LET l_type = "Position"
				DISPLAY "Galley "||m_galley TO l_info
			WHEN "po"
				LET l_img = "fa-hdd-o"
				LET m_pos = l_itemCode.subString(7, l_itemCode.getLength())
				LET l_type = "Cubby"
				LET l_type_prefix = 4+m_pos.getLength()
				DISPLAY "Galley "||m_galley||" Position "||m_pos TO l_info
			OTHERWISE
				LET l_img = "fa-cutlery"
				LET l_type_prefix = 1
				LET l_type = "item"
				DISPLAY "Galley "||m_galley||" Position "||m_pos||" "||l_itemCode.subString(4+m_pos.getLength(), l_itemCode.getLength()) TO l_info
		END CASE
	ELSE
		LET l_img = "fa-square-o"
		DISPLAY "Plane "||l_itemCode.subString(3, l_itemCode.getLength()) TO l_info
		LET l_type = "Galley"
		LET l_type_prefix = 5
	END IF

	IF os.path.exists(c_wc_images||l_itemCode.trim()||".svg") THEN
		CALL setSVG( l_itemCode )
		LET m_bc = l_bc
		LET l_breadcrumbs[ m_bc ] = l_itemCode
		CALL setItemsSVG( l_itemCode, l_type, l_type_prefix, l_img )
	ELSE
		CALL setItemsOther( l_itemCode, l_img )
	END IF

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION  setItemsOther( l_itemCode STRING,l_img STRING )
	CALL m_items.clear()
	CASE 
		WHEN l_itemCode MATCHES "x_f109_draw*"
			LET m_items[1].item_txt = "Draw Item #1"
			LET m_items[2].item_txt = "Draw Item #2"
		WHEN l_itemCode MATCHES "x_f109_tray*"
			LET m_items[1].item_txt = "Tray Item #1"
			LET m_items[2].item_txt = "Tray Item #2"
	END CASE
	LET m_items[1].item_img = l_img
	LET m_items[2].item_img = l_img
	LET m_items[1].item_cde = l_itemCode
	LET m_items[2].item_cde = l_itemCode

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION  setItemsSVG( l_itemCode STRING, l_type STRING, l_type_prefix SMALLINT , l_img STRING )
	DEFINE c base.Channel
	DEFINE l_line STRING

	LET l_line = "grep \"id=\\\"x_\" "||c_wc_images||"/"||l_itemCode||".svg | cut -d'\"' -f2"
	DISPLAY "setItems cmd:",l_line
	LET c = base.Channel.create()
	CALL c.openPipe( l_line, "r")
	CALL m_items.clear()

	WHILE NOT c.isEof()
		LET l_line = c.readLine()
		IF l_line.getLength() > 1 THEN
			DISPLAY "setItems line:",l_line
			LET m_items[ m_items.getLength() + 1 ].item_txt = l_type," ",l_line.subString(l_type_prefix,l_line.getLength())
			LET m_items[ m_items.getLength() ].item_cde = l_line
			LET m_items[ m_items.getLength() ].item_img = l_img
		END IF
	END WHILE
	CALL c.close()

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION showPanel( l_f ui.Form, l_panel STRING, l_pno SMALLINT )
	CALL l_f.setElementHidden( l_panel, m_panels[l_pno] )
	IF NOT m_panels[l_pno] THEN
		CALL l_f.setElementImage("b_"||l_panel,"fa-chevron-right")
	ELSE
		CALL l_f.setElementImage("b_"||l_panel,"fa-chevron-left")
	END IF
	LET m_panels[l_pno] = NOT m_panels[l_pno]
END FUNCTION