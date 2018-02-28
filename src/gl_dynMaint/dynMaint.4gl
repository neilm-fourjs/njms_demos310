
-- A Basic dynamic maintenance program.
-- Does: find, update, insert, delete
-- To Do: locking, sample, listing report

-- Command Args:
-- 1: MDI / SDI 
-- 2: Database name
-- 3: Table name
-- 4: Primary Key name
-- 5: Allowed actions: Y/N > Find / Update / Insert / Delete / Sample / List  -- eg: YNNNNN = enquiry only.

IMPORT FGL gl_lib
IMPORT FGL gl_db
&include "genero_lib.inc"

IMPORT FGL glm_mkForm
IMPORT FGL glm_sql
IMPORT FGL glm_ui
&include "dynMaint.inc"

CONSTANT C_VER="3.1"
CONSTANT C_PRGDESC = "Dynamic Maintenance Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_APP_SPLASH = "njm_demo_logo_256"
CONSTANT C_APP_ICON = "njm_demo_icon"
CONSTANT C_FIELDS_PER_PAGE = 15
DEFINE m_dbname STRING
DEFINE m_allowedActions CHAR(6)
MAIN
	CALL gl_lib.gl_setInfo(C_VER, C_APP_SPLASH, C_APP_ICON, NULL, C_PRGDESC, C_PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),"default",TRUE)
	LET gl_lib.gl_toolBar = "dynmaint"
	LET gl_lib.gl_topMenu = "dynmaint"

	CALL init_args()

-- setup and connect to DB
	CALL gl_db.gldb_connect( m_dbname )

-- setup SQL
	LET glm_sql.m_key_fld = 0
	LET glm_sql.m_row_cur = 0
	LET glm_sql.m_row_count = 0
	CALL glm_sql.glm_mkSQL("*","1=2") -- not fetching any data.

-- create Form
	CALL glm_mkForm.init_form(m_dbname, m_tab, glm_sql.m_key_fld, C_FIELDS_PER_PAGE, glm_sql.m_fields) -- 10 fields by folder page
	CALL gl_lib.gl_titleWin(NULL)
	CALL ui.Interface.setText( gl_lib.gl_progdesc )

-- start UI
	CALL glm_ui.glm_menu(m_allowedActions)

	CALL gl_lib.gl_exitProgram(0,%"Program Finished")
END MAIN
--------------------------------------------------------------------------------
FUNCTION init_args()
	DEFINE l_user SMALLINT
	LET l_user = ARG_VAL(2)
	LET m_dbname = ARG_VAL(3)
	LET glm_sql.m_tab = ARG_VAL(4)
	LET glm_sql.m_key_nam = ARG_VAL(5)
	LET m_allowedActions = ARG_VAL(6)
	IF m_dbname IS NULL THEN
		CALL gl_lib.gl_errPopup(SFMT(%"Invalid Database Name '%1'!",m_dbname))
		CALL gl_lib.gl_exitProgram(1,%"invalid Database")
	END IF
	IF m_tab IS NULL THEN 
		CALL gl_lib.gl_errPopup(SFMT(%"Invalid Table '%1'!",m_tab))
		CALL gl_lib.gl_exitProgram(1,%"invalid table")
	END IF
	IF m_key_nam IS NULL THEN 
		CALL gl_lib.gl_errPopup(SFMT(%"Invalid Key Name '%1'!",m_key_nam))
		CALL gl_lib.gl_exitProgram(1,%"invalid key name")
	END IF
	IF m_allowedActions IS NULL THEN LET m_allowedActions = "YYYYYY" END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION custom_form_init()
END FUNCTION