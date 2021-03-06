
IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL mk_db_sys_data
IMPORT FGL mk_db_app_data

&include "schema.inc"
DEFINE m_stat STRING
MAIN
	DEFINE l_arg STRING
	
	OPEN FORM f FROM "mk_db"
	DISPLAY FORM f

	LET m_stat = SFMT( "mk_db.42r running, arg:%1",l_arg )
	DISPLAY BY NAME m_stat
	CALL ui.Interface.refresh()

	LET l_arg = ARG_VAL(1)
	IF l_arg IS NULL OR l_arg = " " THEN LET l_arg = "ALL" END IF

	LET gl_db.m_cre_db = TRUE
	CALL gl_db.gldb_connect(NULL)
	CALL mkdb_progress( SFMT(%"Connected to %1 db '%2' okay",gl_db.m_dbtyp,gl_db.m_dbnam) )

	IF gl_winQuestion("Confirm",
		"This will delete and recreate all the database tables!\n\nAre you sure you want to do this?",
		"No","Yes|No","question") != "Yes" THEN
		EXIT PROGRAM
	END IF

	CALL mkdb_progress( SFMT("typ:%1 nam:%2 des:%3 src:%4 drv:%5 dir:%6 con:%7",
							gl_db.m_dbtyp,
							gl_db.m_dbnam,
							gl_db.m_dbdes,
							gl_db.m_dbsrc,
							gl_db.m_dbdrv,
							gl_db.m_dbdir,
							gl_db.m_dbcon) )

	IF l_arg = "SYS" OR l_arg = "ALL" THEN
		CALL drop_sys()
		CALL ifx_create_system_tables()
		CALL insert_system_data()
	END IF

	IF l_arg = "APP" OR l_arg = "ALL" THEN
		CALL drop_app()
		CALL ifx_create_app_tables()
		CALL insert_app_data()
	END IF

	CALL gl_lib.gl_winMessage("Info",SFMT("mk_db program finished Arg:%1",l_arg),"information")

END MAIN
--------------------------------------------------------------------------------
FUNCTION drop_sys()
	CALL mkdb_progress( "Dropping system tables...")
	WHENEVER ERROR CONTINUE
	DROP TABLE sys_users
	DROP TABLE sys_user_roles
	DROP TABLE sys_roles
	DROP TABLE sys_menus
	DROP TABLE sys_menu_roles
	DROP TABLE sys_login_hist
	WHENEVER ERROR STOP
	CALL mkdb_progress( "Done." )
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION drop_app()
	CALL mkdb_progress( "Dropping data tables..." )
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
	CALL mkdb_progress( "Done." )
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION mkdb_progress(l_mess STRING)
	LET l_mess = CURRENT,":", NVL(l_mess,"NULL!")
	LET m_stat = m_stat.append(l_mess||"\n" )
	DISPLAY l_mess
	DISPLAY BY NAME m_stat
	CALL ui.Interface.refresh()
END FUNCTION