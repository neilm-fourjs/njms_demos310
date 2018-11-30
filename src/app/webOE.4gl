
#+ Web Order Entry Demo - by N.J.Martin neilm@4js.com
#+

IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL oe_lib
IMPORT FGL oeweb_lib

&include "genero_lib.inc" -- Contains GL_DBGMSG & g_dbgLev
&include "app.inc"
&include "ordent.inc"
CONSTANT C_PRGDESC = "Web Ordering Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"

DEFINE m_vbox om.DomNode
DEFINE m_dialog ui.Dialog
DEFINE m_fields DYNAMIC ARRAY OF RECORD
		name STRING,
		type STRING
	END RECORD
DEFINE m_csslayout BOOLEAN
MAIN
	DEFINE l_win ui.Window
	DEFINE l_form ui.Form
	DEFINE l_cat SMALLINT

	CALL gl_lib.gl_setInfo(C_VER, C_APP_SPLASH, C_APP_ICON, NULL, C_PRGDESC, C_PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),"weboe",TRUE)
GL_MODULE_ERROR_HANDLER

	CALL gl_db.gldb_connect(NULL)

	CALL ui.Interface.setText( gl_progdesc )

	LET m_csslayout = FALSE
	IF fgl_getEnv("GBC_CUSTOM") = "csslayout" THEN LET m_csslayout = TRUE END IF
	DISPLAY "GBC_CUSTOM:",fgl_getEnv("GBC_CUSTOM") 

	OPEN FORM weboe FROM "webOE"
	DISPLAY FORM weboe

	LET l_win = ui.Window.getCurrent()
	LET l_form = l_win.getForm()
	LET m_vbox = l_form.findNode("VBox","main_vbox")

	CALL oeweb_lib.initAll()
	CALL oeweb_lib.logaccess( FALSE ,g_cust.email )
	DISPLAY "Customer:",g_custname
	DISPLAY g_custname TO custname

	CALL oeweb_lib.build_sqls()
	CALL oeweb_lib.get_categories()
	CALL oeweb_lib.build_cats(l_form)

	LET l_cat = 1
	WHILE l_cat > 0
		CALL oeweb_lib.getItems( m_stock_cats[ l_cat ].id )
		CALL build_grids()
		LET l_cat = dynDiag()
	END WHILE

END MAIN
--------------------------------------------------------------------------------
FUNCTION build_grids()
	DEFINE l_hbox, n,n1, ff om.DomNode
	DEFINE x,y, l_gw SMALLINT
	CONSTANT l_lab1_gwidth = 12
	CONSTANT l_lab2_gwidth = 4
	CONSTANT l_qty_gwidth = 6
	CONSTANT l_detbut_gwidth = 2

	LET l_gw = l_lab1_gwidth + 1
	DISPLAY "Build_grids, m_csslayout:",m_csslayout

	LET n = m_vbox.getParent()
	CALL n.removeChild( m_vbox )
	LET m_vbox = n.createChild("VBox")
	CALL m_vbox.setAttribute("name","main_vbox")
	CALL m_vbox.setAttribute("splitter","0")

	LET l_hbox = m_vbox.createChild("HBox")
	IF m_csslayout THEN
		CALL l_hbox.setAttribute("style","cssLayout")
	END IF

	LET y = m_items.getLength()
	IF NOT m_csslayout THEN
		IF y MOD 4 THEN -- make sure we generate 4 grids across
			LET y = y + (4 - ( y MOD 4  ))
		END IF
		IF y < 8 THEN LET y = 8 END IF -- make sure we have at least 12 total
	END IF
	FOR x = 1 TO y
		LET n = l_hbox.createChild("Group")
		IF x <= m_items.getLength() THEN
			CALL n.setAttribute("style", "griditemX")
		ELSE
			CALL n.setAttribute("style", "noborder")
		END IF
		LET n = n.createChild("Grid")
		CALL n.setAttribute("gridWidth", l_gw)
		CALL n.setAttribute("gridHeight", "14")
		IF x <= m_items.getLength() THEN
			CALL n.setAttribute("style", "griditem")
		END IF

		LET n1 = n.createChild("Image")
		IF x <= m_items.getLength() THEN
			CALL n1.setAttribute("image", m_items[x].img1)
			CALL n1.setAttribute("style", "bg_white noborder")
		ELSE
			CALL n1.setAttribute("style", "noborder")
		END IF
		CALL n1.setAttribute("sizePolicy","fixed")
		CALL n1.setAttribute("autoScale","1")
		CALL n1.setAttribute("gridWidth", l_gw-1)
		CALL n1.setAttribute("width", "150px")
		CALL n1.setAttribute("height", "150px")
		CALL n1.setAttribute("posY","1")
		CALL n1.setAttribute("posX","1")

		LET n1 = n.createChild("Label")
		IF x <= m_items.getLength() THEN
			CALL n1.setAttribute("text", m_items[x].desc1)
		ELSE
			CALL n1.setAttribute("text", "&nbsp;" )
		END IF
		CALL n1.setAttribute("gridWidth", l_lab1_gwidth)
		CALL n1.setAttribute("width", l_lab1_gwidth)
		CALL n1.setAttribute("gridHeight", "3")
		CALL n1.setAttribute("posY","5")
		CALL n1.setAttribute("posX","1")
		CALL n1.setAttribute("style", "html")
		CALL n1.setAttribute("sizePolicy","fixed")


		LET n1 = n.createChild("Label")
		IF x <= m_items.getLength() THEN
			CALL n1.setAttribute("text","QTY:")
		END IF
		CALL n1.setAttribute("style", "bold")
		CALL n1.setAttribute("gridWidth",l_lab2_gwidth)
		CALL n1.setAttribute("width","5")
		CALL n1.setAttribute("sizePolicy","fixed")
		CALL n1.setAttribute("posY","10")
		CALL n1.setAttribute("posX","1")

		IF x <= m_items.getLength() THEN
			LET ff = n.createChild("FormField")
			CALL ff.setAttribute("name","formonly.qty"||x)
			CALL ff.setAttribute("colName","qty"||x)
			LET n1 = ff.createChild("ButtonEdit")
			--LET n1 = ff.createChild("SpinEdit")
			CALL n1.setAttribute("gridWidth",l_qty_gwidth)
			CALL n1.setAttribute("width",l_qty_gwidth)
			CALL n1.setAttribute("action","add1")
			CALL n1.setAttribute("posY","10")
			CALL n1.setAttribute("posX",l_lab2_gwidth)
			CALL n1.setAttribute("style", "bold")

			LET n1 = n.createChild("Button")
			CALL n1.setAttribute("name","detlnk"||x)
			CALL n1.setAttribute("gridWidth",l_detbut_gwidth)
			CALL n1.setAttribute("width",l_detbut_gwidth)
			CALL n1.setAttribute("image", "fa-info-circle")
			CALL n1.setAttribute("text", "")
			CALL n1.setAttribute("posY","10")
			CALL n1.setAttribute("posX",l_lab2_gwidth+l_qty_gwidth)
		END IF

		--DISPLAY "Grid x:",x, " y:",y, " MOD4:",( x MOD 4 ), " len:",m_items.getLength()

		IF NOT m_csslayout THEN
			IF NOT x MOD 4 THEN
				LET l_hbox = m_vbox.createChild("HBox")
			END IF
		END IF

	END FOR

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION dynDiag()
	DEFINE x SMALLINT
	DEFINE l_field, l_evt STRING

	CALL recalcOrder()
	CALL m_fields.clear()
	FOR x = 1 TO m_items.getLength()
		LET m_fields[m_fields.getLength()+1].name = "qty"||x
		LET m_fields[m_fields.getLength()].type = "INTEGER"
	END FOR

	CALL ui.Dialog.setDefaultUnbuffered(TRUE)
	LET m_dialog = ui.Dialog.createInputByName(m_fields)

	CALL m_dialog.addTrigger("ON ACTION close")
	CALL m_dialog.addTrigger("ON ACTION add1")
	CALL m_dialog.addTrigger("ON ACTION viewb")
	CALL m_dialog.addTrigger("ON ACTION signin")
	CALL m_dialog.addTrigger("ON ACTION gotoco")
	CALL m_dialog.addTrigger("ON ACTION about")
	CALL m_dialog.addTrigger("ON ACTION cancel")	
	FOR x = 1 TO m_items.getLength()
		CALL m_dialog.addTrigger("ON ACTION detlnk"||x)
		CALL m_dialog.setFieldValue("qty"||x, m_items[x].qty1)
	END FOR
	FOR x = 1 TO m_stock_cats.getLength()
		CALL m_dialog.addTrigger("ON ACTION cat"||x)
	END FOR
	IF g_ordHead.total_qty > 1 THEN
		CALL m_dialog.setActionActive("viewb",TRUE)
		CALL m_dialog.setActionActive("gotoco",TRUE)
	ELSE
		CALL m_dialog.setActionActive("viewb",FALSE)
		CALL m_dialog.setActionActive("gotoco",FALSE)
	END IF
	CALL oeweb_lib.setSignInAction()
	LET int_flag = FALSE
	WHILE TRUE
		LET l_evt = m_dialog.nextEvent()

		IF l_evt MATCHES "ON ACTION cat*" THEN
			RETURN l_evt.subString(14, l_evt.getLength())
		END IF

		IF l_evt MATCHES "ON ACTION detlnk*" THEN
			LET x = l_evt.subString(17, l_evt.getLength())
			CALL detLnk( m_items[x].stock_code1,
					m_items[x].desc1,
					m_items[x].img1,
					m_items[x].qty1 )
		END IF

		IF l_evt MATCHES "ON CHANGE qty*" OR l_evt MATCHES "AFTER FIELD qty*" THEN
			LET l_field = m_dialog.getCurrentItem()
			LET x = l_field.subString(4, l_field.getLength())
			DISPLAY "Event:",l_evt, "  fld:",l_field," X:",x 
			CALL detLine(m_items[x].stock_code1,  m_dialog.getFieldValue("qty"||x))
			CALL m_dialog.setFieldValue("qty"||x, m_items[x].qty1)
		END IF

		CASE l_evt
			WHEN "ON ACTION add1"
				LET l_field = m_dialog.getCurrentItem()
				LET x = l_field.subString(4, l_field.getLength())
				LET m_items[x].qty1 = m_items[x].qty1 + 1
				CALL detLine(m_items[x].stock_code1,m_items[x].qty1)
				CALL m_dialog.setFieldValue("qty"||x, m_items[x].qty1)

			WHEN "ON ACTION close"
				LET int_flag = TRUE
				EXIT WHILE

			WHEN "ON ACTION cancel"
				LET int_flag = TRUE
				EXIT WHILE

			WHEN "ON ACTION signin" 
				CALL oeweb_lib.signin()

			WHEN "ON ACTION viewb" CALL oeweb_lib.viewb()
			WHEN "ON ACTION gotoco" CALL gotoco()
			WHEN "ON ACTION about" CALL gl_about( C_VER )
		END CASE
	END WHILE
	IF int_flag THEN LET int_flag = FALSE END IF
	RETURN 0
END FUNCTION
