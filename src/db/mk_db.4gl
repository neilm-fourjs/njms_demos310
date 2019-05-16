IMPORT FGL g2_lib
IMPORT FGL g2_db
IMPORT FGL mk_db_sys_data
IMPORT FGL mk_db_sys_ifx
IMPORT FGL mk_db_app_data
IMPORT FGL mk_db_app_ifx
&include "schema.inc"
DEFINE m_stat STRING

MAIN
  DEFINE l_arg STRING
	DEFINE l_db g2_db.dbInfo

  OPEN FORM f FROM "mk_db"
  DISPLAY FORM f

  LET m_stat = SFMT("mk_db.42r running, arg:%1", l_arg)
  DISPLAY BY NAME m_stat
  CALL ui.Interface.refresh()

  LET l_arg = arg_val(1)
  IF l_arg IS NULL OR l_arg = " " THEN
    LET l_arg = "ALL"
  END IF

  LET l_db.create_db = TRUE
  CALL l_db.g2_connect(NULL)
  CALL mkdb_progress(SFMT(% "Connected to %1 db '%2' okay", l_db.type, l_db.name))

  IF g2_lib.g2_winQuestion(
              "Confirm",
              "This will delete and recreate all the database tables!\n\nAre you sure you want to do this?",
              "No",
              "Yes|No",
              "question")
          != "Yes"
      THEN
    EXIT PROGRAM
  END IF

  CALL mkdb_progress(
      SFMT("typ:%1 nam:%2 des:%3 src:%4 drv:%5 dir:%6 con:%7",
          l_db.type,
          l_db.name,
          l_db.desc,
          l_db.source,
          l_db.driver,
          l_db.dir,
          l_db.connection))

  IF l_arg = "SYS" OR l_arg = "ALL" THEN
    CALL drop_sys()
    CALL mk_db_sys_ifx.ifx_create_system_tables()
    CALL mk_db_sys_data.insert_system_data()
  END IF

  IF l_arg = "APP" OR l_arg = "ALL" THEN
    CALL drop_app()
    CALL mk_db_app_ifx.ifx_create_app_tables(l_db)
    CALL mk_db_app_data.insert_app_data()
  END IF

  CALL g2_lib.g2_winMessage("Info", SFMT("mk_db program finished Arg:%1", l_arg), "information")

END MAIN
--------------------------------------------------------------------------------
FUNCTION drop_sys()
  CALL mkdb_progress("Dropping system tables...")
  WHENEVER ERROR CONTINUE
  DROP TABLE sys_users
  DROP TABLE sys_user_roles
  DROP TABLE sys_roles
  DROP TABLE sys_menus
  DROP TABLE sys_menu_roles
  DROP TABLE sys_login_hist
  WHENEVER ERROR STOP
  CALL mkdb_progress("Done.")
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION drop_app()
  CALL mkdb_progress("Dropping data tables...")
  WHENEVER ERROR CONTINUE
	DROP TABLE quote_detail
	DROP TABLE quotes
  DROP TABLE customer
  DROP TABLE addresses
  DROP TABLE countries
  DROP TABLE stock
  DROP TABLE pack_items
  DROP TABLE stock_cat
  DROP TABLE supplier
  DROP TABLE ord_detail
  DROP TABLE ord_head
  DROP TABLE ord_payment
  DROP TABLE disc
	DROP TABLE colours
  WHENEVER ERROR STOP
  CALL mkdb_progress("Done.")
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION mkdb_progress(l_mess STRING)
  LET l_mess = CURRENT, ":", NVL(l_mess, "NULL!")
  LET m_stat = m_stat.append(l_mess || "\n")
  DISPLAY l_mess
  DISPLAY BY NAME m_stat
  CALL ui.Interface.refresh()
END FUNCTION
