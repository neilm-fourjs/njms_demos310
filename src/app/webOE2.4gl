
#+ Web Order Entry Demo - by N.J.Martin neilm@4js.com
#+

IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL oe_lib
IMPORT FGL oeweb_lib

CONSTANT PRGDESC = "Web Ordering Demo #2"
CONSTANT PRGAUTH = "Neil J.Martin"
CONSTANT C_VER="3.1"

&include "genero_lib.inc" -- Contains GL_DBGMSG & g_dbgLev
&include "app.inc"
&include "ordent.inc"

DEFINE m_dbtyp STRING
DEFINE m_arg1 STRING
DEFINE m_stock_cats DYNAMIC ARRAY OF RECORD
		id LIKE stock_cat.catid,
		desc LIKE stock_cat.cat_name
	END RECORD
DEFINE m_items DYNAMIC ARRAY OF RECORD
		stock_code1 STRING,
		img1 STRING,
		desc1 STRING,
		qty1 INTEGER
	END RECORD

DEFINE m_vbox, m_grid_cats om.DomNode
DEFINE m_dialog ui.Dialog
DEFINE m_fields DYNAMIC ARRAY OF RECORD
		name STRING,
		type STRING
	END RECORD
	DEFINE m_form ui.Form
	DEFINE m_csslayout BOOLEAN
MAIN
	DEFINE l_cookie STRING
	DEFINE l_cc LIKE customer.customer_code
	DEFINE l_win ui.Window
	DEFINE l_cat SMALLINT

	CALL gl_lib.gl_setInfo(C_VER, APP_SPLASH, APP_ICON, NULL, PRGDESC, PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),"weboe2",TRUE)
GL_MODULE_ERROR_HANDLER

	CALL gl_db.gldb_connect(NULL)

	LET m_arg1 = ARG_VAL(1)
	IF m_arg1 IS NULL OR m_arg1 = " " THEN LET m_arg1 = "SDI" END IF

	LET m_dbtyp = gldb_getDBType()
	CALL ui.Interface.setText( gl_progdesc )

	LET m_csslayout = FALSE
	IF fgl_getEnv("GBC_CUSTOM") = "csslayout" THEN LET m_csslayout = TRUE END IF
	DISPLAY "GBC_CUSTOM:",fgl_getEnv("GBC_CUSTOM") 

	OPEN FORM weboe FROM "webOE2"
	DISPLAY FORM weboe

	LET l_win = ui.Window.getCurrent()
	LET m_form = l_win.getForm()
	LET m_vbox = m_form.findNode("VBox","main_vbox")

	CALL oeweb_lib.initAll()
	CALL oeweb_lib.logaccess( FALSE ,g_cust.email )
	DISPLAY "Customer:",g_custname
	DISPLAY g_custname TO custname

	CALL oeweb_lib.build_sqls()
	DECLARE stkcur CURSOR FROM "SELECT * FROM stock WHERE stock_cat = ?"
	DECLARE sc_cur CURSOR FOR SELECT UNIQUE stock_cat.* FROM stock_cat, stock 
		WHERE stock.stock_cat = stock_cat.catid {AND stock_cat.catid != "ARMS"}
   ORDER BY stock_cat.cat_name
	FOREACH sc_cur INTO m_stock_cats[ m_stock_cats.getLength() + 1 ].*
	END FOREACH
	CALL m_stock_cats.deleteElement( m_stock_cats.getLength() )

	CALL build_cats()

	LET l_cat = 3
	WHILE l_cat > 0
		CALL getItems( m_stock_cats[ l_cat ].id )
		LET l_cat = dynDiag()
	END WHILE
{
	INPUT ARRAY m_items FROM items.* ATTRIBUTES(WITHOUT DEFAULTS,
			DELETE ROW=FALSE,INSERT ROW=FALSE,APPEND ROW=FALSE)
		ON CHANGE qty1
			CALL detLine(m_items[DIALOG.getCurrentRow("items")].stock_code1,m_items[DIALOG.getCurrentRow("items")].qty1)

		ON ACTION add1
				CALL detLine(m_items[DIALOG.getCurrentRow("items")].stock_code1,m_items[DIALOG.getCurrentRow("items")].qty1+1)
				CALL recalcOrder()
		ON ACTION detlnk1 CALL detLnk( m_items[DIALOG.getCurrentRow("items")].stock_code1,
																	 m_items[DIALOG.getCurrentRow("items")].desc1,
																	 m_items[DIALOG.getCurrentRow("items")].img1,
																	 m_items[DIALOG.getCurrentRow("items")].qty1 )
	END INPUT
}
END MAIN
--------------------------------------------------------------------------------
FUNCTION getItems( sc )
	DEFINE sc LiKE stock_cat.catid
	DEFINE l_stk RECORD LIKE stock.*
	DEFINE rec SMALLINT
	DEFINE img STRING

	CALL m_items.clear()
	LET rec = 1
	FOREACH stkcur USING sc INTO l_stk.*
		LET img = "products/"||(l_stk.img_url CLIPPED)
		LET m_items[ m_items.getLength() + 1 ].stock_code1 = l_stk.stock_code
		LET m_items[ m_items.getLength() ].img1 = img.trim()
		LET m_items[ m_items.getLength() ].desc1 = mkDesc( l_stk.*)
		LET m_items[ m_items.getLength() ].qty1 = 0
	END FOREACH

END FUNCTION
--------------------------------------------------------------------------------
#+ This build my categories list of buttons
#+ @param none
#+ @returns none
FUNCTION build_cats()
	DEFINE n om.DomNode
	DEFINE x,len SMALLINT

	LET m_grid_cats = m_form.findNode("Group","cats")
	DISPLAY "Build cats"
	LET len = 5
	FOR x = 1 TO m_stock_cats.getLength()
		IF LENGTH( m_stock_cats[x].desc ) > len THEN LET len = LENGTH( m_stock_cats[x].desc ) END IF
	END FOR
	FOR x = 1 TO m_stock_cats.getLength()
		LET n = m_grid_cats.createChild("Button")
		CALL n.setAttribute("name", "cat"||x)
		CALL n.setAttribute("text", "  "||m_stock_cats[x].desc CLIPPED||"  " )
		CALL n.setAttribute("image", "products/cat_"||DOWNSHIFT( m_stock_cats[x].id ) CLIPPED )
		CALL n.setAttribute("sizePolicy","fixed")
		CALL n.setAttribute("gridWidth", len)
		CALL n.setAttribute("width", len)
		CALL n.setAttribute("gridHeight", "1")
		CALL n.setAttribute("posY",x+1)
		CALL n.setAttribute("posX","1")
		CALL n.setAttribute("style", "big")
	END FOR
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION dynDiag()
	DEFINE x SMALLINT
	DEFINE l_evt STRING

	CALL recalcOrder()

	CALL m_fields.clear()
	LET m_fields[m_fields.getLength()+1].name = "img1"
	LET m_fields[m_fields.getLength()].type = "STRING"
	LET m_fields[m_fields.getLength()+1].name = "det1"
	LET m_fields[m_fields.getLength()].type = "STRING"
	LET m_fields[m_fields.getLength()+1].name = "qty1"
	LET m_fields[m_fields.getLength()].type = "INTEGER"

	CALL ui.Dialog.setDefaultUnbuffered(TRUE)
	LET m_dialog = ui.Dialog.createInputArrayFrom( m_fields, "items")

	CALL m_dialog.addTrigger("ON ACTION close")
	CALL m_dialog.addTrigger("ON ACTION add1")
	CALL m_dialog.addTrigger("ON ACTION viewb")
	CALL m_dialog.addTrigger("ON ACTION signin")
	CALL m_dialog.addTrigger("ON ACTION gotoco")
	CALL m_dialog.addTrigger("ON ACTION about")
	CALL m_dialog.addTrigger("ON ACTION cancel")	
	CALL m_dialog.addTrigger("ON ACTION detlnk1")

	FOR x = 1 TO m_items.getLength()
		CALL m_dialog.setCurrentRow("items",x)
		--CALL m_dialog.addTrigger("ON ACTION detlnk"||x)
		CALL m_dialog.setFieldValue("items.qty1", m_items[x].qty1)
		CALL m_dialog.setFieldValue("items.img1", m_items[x].img1)
		CALL m_dialog.setFieldValue("items.det1", m_items[x].desc1)
		CALL m_dialog.setFieldValue("items.det1", m_items[x].stock_code1)
	END FOR
	CALL m_dialog.setCurrentRow("items",1)
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
		LET x = m_dialog.getCurrentRow("items")
		DISPLAY "Event:",l_evt, " Row:",x

		IF l_evt MATCHES "ON ACTION cat*" THEN
			CALL m_dialog.accept()
			RETURN l_evt.subString(14, l_evt.getLength())
		END IF

		IF l_evt MATCHES "ON ACTION detlnk1" THEN
			CALL detLnk( m_items[x].stock_code1,
					m_items[x].desc1,
					m_items[x].img1,
					m_items[x].qty1 )
		END IF

		IF l_evt MATCHES "ON CHANGE qty*" OR l_evt MATCHES "AFTER FIELD qty*" THEN
			CALL detLine(m_items[x].stock_code1,  m_dialog.getFieldValue("qty1"))
		END IF

		CASE l_evt
			WHEN "ON ACTION add1"
				LET m_items[x].qty1 = m_items[x].qty1 + 1
				CALL detLine(m_items[x].stock_code1,m_items[x].qty1)
				CALL m_dialog.setFieldValue("qty1", m_items[x].qty1)

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
			WHEN "ON ACTION about" CALL gl_lib.gl_about( C_VER )
		END CASE
	END WHILE
	IF int_flag THEN LET int_flag = FALSE END IF
	RETURN 0
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION recalcOrder()
	DEFINE x,y SMALLINT
	FOR x = 1 TO m_items.getLength()
		LET m_items[x].qty1 = 0
		FOR y = 1 TO g_detailArray.getLength()
			IF m_items[x].stock_code1 = g_detailArray[y].stock_code THEN
				LET m_items[x].qty1 = g_detailArray[y].quantity
			END IF
		END FOR
	END FOR
	CALL oe_uiUpdate()
END FUNCTION