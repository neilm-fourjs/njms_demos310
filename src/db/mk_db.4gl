

IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL mk_db_sys_data
IMPORT FGL mk_db_app_data

&include "schema.inc"

MAIN
	DEFINE l_arg STRING

	LET l_arg = ARG_VAL(1)
	IF l_arg IS NULL OR l_arg = " " THEN LET l_arg = "ALL" END IF

	LET gl_db.m_cre_db = TRUE
	CALL gl_db.gldb_connect(NULL)

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
END MAIN
--------------------------------------------------------------------------------
FUNCTION drop_sys()
	DISPLAY "Dropping system tables..."
	WHENEVER ERROR CONTINUE
	DROP TABLE sys_users
	DROP TABLE sys_user_roles
	DROP TABLE sys_roles
	DROP TABLE sys_menus
	DROP TABLE sys_menu_roles
	WHENEVER ERROR STOP
	DISPLAY "Done."
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION drop_app()
	DISPLAY "Dropping data tables..."
	WHENEVER ERROR CONTINUE
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
	WHENEVER ERROR STOP
	DISPLAY "Done."
END FUNCTION