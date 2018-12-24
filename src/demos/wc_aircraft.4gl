IMPORT os
IMPORT FGL gl_lib
CONSTANT C_VER="3.1"
CONSTANT C_PRGDESC = "WC Aircraft Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT c_wc_images="../pics/webcomponents/aircraft/"
DEFINE l_breadcrumbs DYNAMIC ARRAY OF STRING
DEFINE m_bc SMALLINT
DEFINE m_panels DYNAMIC ARRAY OF BOOLEAN
DEFINE m_items DYNAMIC ARRAY OF RECORD
		item_txt STRING,
		item_cde STRING,
		item_img STRING
	END RECORD
DEFINE m_tray_items DYNAMIC ARRAY OF STRING
DEFINE m_tray DYNAMIC ARRAY OF STRING
DEFINE m_galley, m_pos STRING
DEFINE m_drag_source STRING
DEFINE m_dnd ui.DragDrop

MAIN
	DEFINE l_wc, l_data STRING
	DEFINE l_f ui.Form
	CALL gl_lib.gl_setInfo(C_VER, NULL, NULL, C_PRGDESC, C_PRGDESC, C_PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),NULL,TRUE)
	LET gl_lib.gl_noToolBar = TRUE

	OPEN FORM f FROM "wc_aircraft"
	DISPLAY FORM f

	CALL setDemoItems()

	LET m_panels[1] = FALSE
	CALL setItem( "x_b777", 1, FALSE )

	DIALOG  ATTRIBUTES(UNBUFFERED)
		INPUT BY NAME l_wc, l_data
		END INPUT
		DISPLAY ARRAY m_items TO arr.*
			ON ACTION ACCEPT
				DISPLAY "DoubleClick:",m_items[ arr_curr() ].item_cde
				CALL setItem( m_items[ arr_curr() ].item_cde, m_bc + 1, TRUE )
		END DISPLAY

		BEFORE DIALOG
			LET l_f = DIALOG.getForm()

		ON ACTION plane
			CALL setItem( "x_b777", 1, FALSE )

		ON ACTION selobj
			LET l_data = l_wc
			CALL setItem( l_wc, m_bc + 1, FALSE )

		ON ACTION back
			IF m_bc > 1 THEN
				CALL setItem( l_breadcrumbs[ m_bc - 1 ], m_bc - 1, FALSE )
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
FUNCTION setItem( l_itemCode STRING, l_bc SMALLINT, l_arrsel BOOLEAN )
	DEFINE l_img, l_type, l_type_prefix STRING
	DISPLAY "setITme:", l_itemCode," BC:",l_bc, " arrsel:",l_arrsel

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
				LET l_type = "Galley "||m_galley||" Position "||m_pos||" "||l_itemCode.subString(4+m_pos.getLength(), l_itemCode.getLength())
				DISPLAY l_type TO l_info
		END CASE
	ELSE
		LET l_img = "fa-square-o"
		DISPLAY "Plane "||l_itemCode.subString(3, l_itemCode.getLength()) TO l_info
		LET l_type = "Galley"
		LET l_type_prefix = 5
	END IF

	IF l_bc = 4 THEN -- select draw update
		IF l_arrsel THEN 
			CALL updateDraw( l_itemCode, l_type )
			RETURN
		END IF
	END IF

	IF os.path.exists(c_wc_images||l_itemCode.trim()||".svg") THEN
		LET m_bc = l_bc
		CALL setSVG( l_itemCode )
		LET l_breadcrumbs[ m_bc ] = l_itemCode
		CALL setItemsSVG( l_itemCode, l_type, l_type_prefix, l_img )
	ELSE
		CALL setItemsOther( l_itemCode, l_img )
	END IF

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION  setItemsOther( l_itemCode STRING,l_img STRING )

	DISPLAY "  setItemsOther:", l_itemCode
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
	DISPLAY "  setItemsSVG cmd:",l_line
	LET c = base.Channel.create()
	CALL c.openPipe( l_line, "r")
	CALL m_items.clear()

	WHILE NOT c.isEof()
		LET l_line = c.readLine()
		IF l_line.getLength() > 1 THEN
			DISPLAY "  setItemsSVG line:",l_line
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
--------------------------------------------------------------------------------
FUNCTION setDemoItems()
	DEFINE x SMALLINT
	FOR x = 1 TO 20
		LET m_tray_items[ m_tray_items.getLength() + 1 ] = "Item ",x
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION  updateDraw( l_itemCode STRING, l_type STRING )
	DEFINE x SMALLINT
	DEFINE l_okay BOOLEAN
	DISPLAY "    updateDraw:",l_itemCode," type:",l_type
	OPEN WINDOW ud WITH FORM "wc_aircraft_ud"
	DISPLAY l_type TO titl
	LET l_okay = FALSE
	FOR x = 1 TO m_items.getLength()
		LET m_tray[x] = m_items[x].item_txt
	END FOR
	DIALOG ATTRIBUTES(UNBUFFERED)

		DISPLAY ARRAY m_tray_items TO arr1.*
			ON ACTION select
				LET m_tray[ m_tray.getLength() + 1 ] = m_tray_items[ arr_curr() ]
			ON DRAG_START(m_dnd) LET m_drag_source = "left"
		END DISPLAY

		DISPLAY ARRAY m_tray TO arr2.*
			ON ACTION remove
				CALL m_tray.deleteElement( arr_curr() )
			ON DRAG_ENTER(m_dnd) CALL drop_validate("left")
			ON DROP(m_dnd) LET m_tray[ m_tray.getLength() + 1 ] = m_tray_items[ arr_curr() ]
			ON DRAG_FINISHED(m_dnd) INITIALIZE m_drag_source TO NULL
		END DISPLAY

		ON ACTION accept LET l_okay = TRUE EXIT DIALOG
		ON ACTION cancel EXIT DIALOG
		ON ACTION close EXIT DIALOG
	END DIALOG
	CLOSE WINDOW ud
	IF l_okay THEN
		CALL m_items.clear()
		FOR x = 1 TO m_tray.getLength()
			LET m_items[x].item_txt = m_tray[x]
			LET m_items[x].item_img = "fa-cutlery"
		END FOR
	END IF

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION drop_validate(l_target STRING)
	IF m_drag_source = l_target THEN
		CALL m_dnd.setOperation("move")
		CALL m_dnd.setFeedback("insert")
	ELSE
		CALL m_dnd.setOperation(NULL)
	END IF
END FUNCTION