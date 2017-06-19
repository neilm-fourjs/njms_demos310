-- A Simple demo program with a login and menu system.
IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL lib_login
IMPORT FGL new_acct

&include "schema.inc"

CONSTANT C_VER="1.0"
CONSTANT C_TITLE="NJM's Demos"
CONSTANT C_SPLASH="njm_demo_logo_256"

DEFINE m_user STRING
DEFINE m_menu DYNAMIC ARRAY OF RECORD LIKE sys_menus.*
DEFINE m_menus DYNAMIC ARRAY OF VARCHAR(6)
DEFINE m_curMenu SMALLINT
MAIN

	CALL gl_lib.gl_init("C",NULL,FALSE)

	OPEN FORM menu FROM "menu"
	DISPLAY FORM menu

	LET m_user = do_dbconnect_and_login()
	IF m_user IS NOT NULL THEN
		CALL do_menu()
	END IF

END MAIN
--------------------------------------------------------------------------------
-- Connect to the database to do the login process.
FUNCTION do_dbconnect_and_login()
	LET gl_lib.gl_splash = C_SPLASH
	IF gl_lib.gl_fe_typ != "GBC" THEN
		CALL gl_lib.gl_splash( 0 ) -- open splash
	END IF

	CALL gl_db.gldb_connect( NULL )

	IF gl_lib.gl_fe_typ != "GBC" THEN
		SLEEP 2
		CALL gl_lib.gl_splash( -1 ) -- close splash
	END IF

	LET lib_login.m_logo_image = C_SPLASH
	LET lib_login.m_new_acc_func = FUNCTION new_acct.new_acct
	RETURN lib_login.login( C_TITLE, C_VER )
END FUNCTION
--------------------------------------------------------------------------------
-- 
FUNCTION do_menu()

	IF NOT populate_menu(m_menus[m_curMenu]) THEN -- should not happen!
--		CALL logIt("'main' menu not found!")
		CALL exit_Program()
	END IF

	IF m_user IS NOT NULL THEN CALL gl_titleWin(m_user) END IF
	DISPLAY BY NAME m_user
	DISPLAY TODAY TO dte
	DISPLAY ARRAY m_menu TO menu.* ATTRIBUTE(UNBUFFERED)
		BEFORE DISPLAY	

		ON ACTION back
			IF m_curMenu > 1 THEN
				IF populate_menu(m_menus[m_curMenu - 1]) THEN
					LET m_curMenu = m_curMenu - 1
				END IF
			END IF
		ON ACTION accept
			CALL progArgs( m_menu[ arr_curr() ].m_item ) RETURNING l_prog, l_args
			DISPLAY "Menu line accepted:",m_menu[ arr_curr() ].m_type||"-"||m_menu[ arr_curr() ].m_text
			CASE m_menu[ arr_curr() ].m_type 
				WHEN "C"
					CASE m_menu[ arr_curr() ].m_item 
						WHEN "quit"
							EXIT DISPLAY
						WHEN "back" 
							--DISPLAY "back:",m_curMenu
							IF m_curMenu > 1 AND populate_menu(m_menus[m_curMenu - 1]) THEN
								LET m_curMenu = m_curMenu - 1
							END IF
							--DISPLAY "back:",m_curMenu
							CALL DIALOG.setCurrentRow("menu",1)
					END CASE

				WHEN "F" 
					CALL logIt("RUN:fglrun "||l_prog||" "||m_args||" "||l_args)
					DISPLAY "m_args:",m_args, " l_args:",l_args
					DISPLAY "Run: fglrun "||l_prog||" "||m_args||" "||l_args
					RUN "fglrun "||l_prog||" "||m_args||" "||l_args WITHOUT WAITING

				WHEN "P" 
					CALL logIt("RUN:"||l_prog||" "||l_args)
					DISPLAY "Run: "||l_prog||" "||l_args
					RUN l_prog||" "||l_args WITHOUT WAITING

				WHEN "O" 
					CALL logIt("OSRUN:"||m_menu[ arr_curr() ].m_item)
					DISPLAY "exec: "||m_menu[ arr_curr() ].m_item
					RUN m_menu[ arr_curr() ].m_item WITHOUT WAITING

				WHEN "M"
					LET m_menus[m_curMenu + 1] = m_menu[ arr_curr() ].m_item
					IF populate_menu(m_menus[m_curMenu + 1]) THEN
						LET m_curMenu = m_curMenu + 1
					END IF
					CALL DIALOG.setCurrentRow("menu",1)
			END CASE

		ON ACTION about
			CALL gl_about( )

		ON ACTION exit 
			IF ARG_VAL(1) = "MDI" THEN
				IF ui.Interface.getChildCount() > 0 THEN
					CALL fgl_winMessage("Warning","Must close child windows first!","exclamation")
					CONTINUE DISPLAY
				END IF
			END IF
			EXIT DISPLAY

		ON ACTION close 
			IF ARG_VAL(1) = "MDI" THEN
				IF ui.Interface.getChildCount() > 0 THEN
					CALL fgl_winMessage("Warning","Must close child windows first!","exclamation")
					CONTINUE DISPLAY
				END IF
			END IF
			EXIT DISPLAY
	END DISPLAY

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION populate_menu(l_mname)
	DEFINE l_mname LIKE sys_menus.m_id
	DEFINE l_role_name LIKE sys_roles.role_name
	DEFINE l_prev_key LIKE sys_menus.menu_key

--	DISPLAY "menu:",mname," n:",m_curMenu
	SELECT m_text INTO m_titl FROM sys_menus 
		WHERE m_id = l_mname AND m_type = "T"
	IF STATUS = NOTFOUND THEN 
--		DISPLAY "Menu:"||mname||" not found!"
		RETURN FALSE
	END IF
	DISPLAY BY NAME m_titl;

	CALL m_menu.clear()
	DECLARE cur CURSOR FOR SELECT sys_menus.*,sys_roles.role_name 
		FROM sys_menus 		--OUTER(sys_menu_roles,sys_roles)
		LEFT OUTER JOIN sys_menu_roles
		ON sys_menu_roles.menu_key = sys_menus.menu_key
		LEFT OUTER JOIN sys_roles
		ON sys_menu_roles.role_key = sys_roles.role_key
		WHERE m_id = l_mname 
		AND m_type != "T" 
		ORDER BY sys_menus.menu_key

	LET l_prev_key  = -1
	FOREACH cur INTO m_menu[ m_menu.getLength() + 1 ].*, l_role_name
		IF l_role_name IS NOT NULL THEN
			DISPLAY "Role:",l_role_name
			IF NOT checkUserRoles(m_user_key,l_role_name,FALSE) THEN
				CALL m_menu.deleteElement( m_menu.getLength() )
				CONTINUE FOREACH
			END IF
			IF m_menu[ m_menu.getLength() ].menu_key = l_prev_key THEN
				CALL m_menu.deleteElement( m_menu.getLength() )
				CONTINUE FOREACH
			END IF
			LET l_prev_key = m_menu[ m_menu.getLength() ].menu_key 
		END IF
	END FOREACH
	LET m_menu[m_menu.getLength()].m_type = "C"
	LET m_menu[m_menu.getLength()].m_text = "Back"
	LET m_menu[m_menu.getLength()].m_item = "back"
	IF m_menu[m_menu.getLength() - 1].m_pid IS NULL THEN
		LET m_menu[m_menu.getLength()].m_text = "Quit"
		LET m_menu[m_menu.getLength()].m_item = "quit"
	END IF
	RETURN TRUE

END FUNCTION
--------------------------------------------------------------------------------
