

IMPORT FGL gl_lib
IMPORT FGL gl_db

&include "schema.inc"

MAIN

	CALL gl_db.gldb_connect(NULL)

	CALL drops()

	CALL ifx_create_system_tables()

	CALL insert_system_data()

	CALL ifx_create_app_tables()

	CALL insert_app_data()

END MAIN
--------------------------------------------------------------------------------
FUNCTION drops()
	DISPLAY "Dropping tables..."
	WHENEVER ERROR CONTINUE

	DROP TABLE accounts
	DROP TABLE sys_acct_roles
	DROP TABLE sys_roles
	DROP TABLE sys_menus
	DROP TABLE sys_menu_roles

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

