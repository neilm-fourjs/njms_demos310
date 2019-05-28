-- A Basic dynamic maintenance program.
-- Does: find, update, insert, delete
-- To Do: locking, sample, listing report

-- Command Args:
-- 1: MDI / SDI
-- 2: Database name
-- 3: Table name
-- 4: Primary Key name
-- 5: Allowed actions: Y/N > Find / Update / Insert / Delete / Sample / List  -- eg: YNNNNN = enquiry only.

IMPORT FGL g2_lib
IMPORT FGL g2_appInfo
IMPORT FGL g2_about
IMPORT FGL g2_db
IMPORT FGL app_lib

IMPORT FGL glm_mkForm
IMPORT FGL glm_sql
IMPORT FGL glm_ui
&include "dynMaint.inc"

&include "schema.inc"
&include "app.inc"

CONSTANT C_PRGVER = "3.1"
CONSTANT C_PRGDESC = "Dynamic Maintenance Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_PRGICON = "logo_dark"

CONSTANT C_FIELDS_PER_PAGE = 10
DEFINE m_dbname STRING
DEFINE m_allowedActions CHAR(6)
DEFINE m_appInfo g2_appInfo.appInfo
DEFINE m_db g2_db.dbInfo
MAIN

  CALL m_appInfo.progInfo(C_PRGDESC, C_PRGAUTH, C_PRGVER, C_PRGICON)
  CALL g2_lib.g2_init(ARG_VAL(1), "default")

  CALL init_args()

-- setup and connect to DB
  CALL m_db.g2_connect(m_dbname)

-- setup SQL
  LET glm_sql.m_key_fld = 0
  LET glm_sql.m_row_cur = 0
  LET glm_sql.m_row_count = 0
  CALL glm_sql.glm_mkSQL("*", "1=2") -- not fetching any data.

-- create Form
  CALL glm_mkForm.init_form(
      m_dbname,
      glm_sql.m_tab,
      glm_sql.m_key_fld,
      C_FIELDS_PER_PAGE,
      glm_sql.m_fields,
      "main2") -- 10 fields by folder page
  CALL ui.window.getCurrent().setText(C_PRGDESC)
	CALL g2_lib.g2_loadToolBar( "dynmaint" )
	CALL g2_lib.g2_loadTopMenu( "dynmaint" )
-- start UI
  CALL glm_ui.glm_menu(m_allowedActions, m_appInfo)

  CALL g2_lib.g2_exitProgram(0, % "Program Finished")
END MAIN
--------------------------------------------------------------------------------
FUNCTION init_args()
  DEFINE l_user SMALLINT
  LET l_user = arg_val(2)
  LET m_dbname = arg_val(3)
  LET glm_sql.m_tab = arg_val(4)
  LET glm_sql.m_key_nam = arg_val(5)
  LET m_allowedActions = arg_val(6)
  IF m_dbname IS NULL THEN
    CALL g2_lib.g2_errPopup(SFMT(% "Invalid Database Name '%1'!", m_dbname))
    CALL g2_lib.g2_exitProgram(1, % "invalid Database")
  END IF
  IF glm_sql.m_tab IS NULL THEN
    CALL g2_lib.g2_errPopup(SFMT(% "Invalid Table '%1'!", glm_sql.m_tab))
    CALL g2_lib.g2_exitProgram(1, % "invalid table")
  END IF
  IF glm_sql.m_key_nam IS NULL THEN
    CALL g2_lib.g2_errPopup(SFMT(% "Invalid Key Name '%1'!", glm_sql.m_key_nam))
    CALL g2_lib.g2_exitProgram(1, % "invalid key name")
  END IF
  IF m_allowedActions IS NULL THEN
    LET m_allowedActions = "YYYYYY"
  END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION custom_form_init()
END FUNCTION
