
-- A Basic dynamic stock maintenance program.
-- Does: find, update, insert, delete
-- To Do: locking, sample, listing report

IMPORT util
IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL glm_mkForm
IMPORT FGL glm_sql
IMPORT FGL glm_ui

&include "genero_lib.inc"
&include "dynMaint.inc"

SCHEMA njm_demo310

CONSTANT C_VER="3.1"
CONSTANT C_PRGDESC = "Dynamic Stock Maintenance Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_APP_SPLASH = "njm_demo_logo_256"
CONSTANT C_APP_ICON = "njm_demo_icon"

DEFINE m_dbname STRING
DEFINE m_allowedActions CHAR(6)
MAIN
	DEFINE l_style STRING
	CALL gl_lib.gl_setInfo(C_VER, C_APP_SPLASH, C_APP_ICON, NULL, C_PRGDESC, C_PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),"default",TRUE)
	LET gl_toolBar = "dynmaint"
	LET gl_topMenu = "dynmaint"

	CALL init_args()

-- setup DB
	LET m_dbname = "njm_demo310"
	CALL gl_db.gldb_connect( m_dbname )

-- setup SQL
	LET glm_sql.m_key_fld = 0
	LET glm_sql.m_row_cur = 0
	LET glm_sql.m_row_count = 0
	LET glm_sql.m_tab = "stock"
	LET glm_sql.m_key_nam = "stock_code"
--	CALL glm_sql.glm_mkSQL("stock_code, stock_cat, supp_code, description, price, cost","1=2") -- not fetching any data.
	CALL glm_sql.glm_mkSQL("*","1=2") -- not fetching any data.

-- create Form
	LET l_style = "main2"
	IF fgl_getEnv("WINDOWCENTER") = "TRUE" THEN LET l_style = "centered" END IF
	CALL glm_mkForm.init_form(m_dbname, m_tab, glm_sql.m_key_fld, 20, glm_sql.m_fields,l_style) -- 10 fields by folder page
	CALL gl_lib.gl_titleWin( gl_progdesc )
	CALL ui.Interface.setText( gl_progdesc )

-- start UI
	LET glm_ui.m_before_inp_func = FUNCTION my_before_inp
--	LET glm_ui.m_inpt_func = FUNCTION my_input
	LET glm_ui.m_after_inp_func = FUNCTION my_after_inp
	CALL glm_ui.glm_menu(m_allowedActions)

	CALL gl_lib.gl_exitProgram(0,%"Program Finished")
END MAIN
--------------------------------------------------------------------------------
FUNCTION init_args()
	LET m_allowedActions = NULL
	IF m_allowedActions IS NULL THEN LET m_allowedActions = "YYYYYY" END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION custom_form_init()
	DEFINE f_init_cb t_init_cb
	LET f_init_cb = FUNCTION init_cb
	CALL glm_mkForm.setComboBox("stock_cat", f_init_cb)
	CALL glm_mkForm.setComboBox("supp_code", f_init_cb)
	CALL glm_mkForm.setComboBox("disc_code", f_init_cb)
	CALL glm_mkForm.setWidgetProps("pack_flag","CheckBox","P","","")
	CALL glm_mkForm.setWidgetProps("long_desc","TextEdit","2","40","both")
	CALL glm_mkForm.hideField("cost")
	CALL glm_mkForm.noEntryField("free_stock")
	CALL glm_mkForm.noEntryField("physical_stock")
	CALL glm_mkForm.noEntryField("allocated_stock")
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION init_cb( l_cb ui.ComboBox )
	DEFINE l_sql, l_key, l_desc STRING
	IF l_cb IS NULL THEN
		DISPLAY "init_cb passed NULL!"
		RETURN
	END IF
	CASE l_cb.getColumnName()
		WHEN "stock_cat"
			LET l_sql = "SELECT catid, cat_name FROM stock_cat ORDER BY cat_name"
		WHEN "supp_code"
			LET l_sql = "SELECT supp_code, supp_name FROM supplier ORDER BY supp_name"
		WHEN "disc_code"
			LET l_sql = "SELECT UNIQUE stock_disc FROM disc ORDER BY stock_disc"
	END CASE
	IF l_sql IS NOT NULL THEN
		DISPLAY "Loading ComboBox for: ",l_cb.getColumnName()
		DECLARE cb_cur CURSOR FROM l_sql
		FOREACH cb_cur INTO l_key, l_desc
			IF l_key.trim().getLength() > 1 THEN
				--DISPLAY "Key:",l_key.trim()," Desc:",l_desc.trim()
				CALL l_cb.addItem( l_key.trim(), l_desc.trim() )
			END IF
		END FOREACH
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION my_before_inp(l_new BOOLEAN, l_d ui.Dialog)
	DISPLAY "BEFORE INPUT : ",l_new
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION my_after_inp(l_new BOOLEAN, l_d ui.Dialog) RETURNS BOOLEAN
	DEFINE  l_stk RECORD LIKE stock.*
	DISPLAY "AFTER INPUT : ",l_new
	CALL util.JSON.parse( glm_mkForm.m_json_rec.toString(), l_stk)
	IF l_stk.price < 0.10 THEN
		ERROR "Stock price can't be less than 0.10!"
		CALL l_d.nextField("price")
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION my_input(l_new BOOLEAN)
	DISPLAY "MY INPUT : ",l_new
END FUNCTION