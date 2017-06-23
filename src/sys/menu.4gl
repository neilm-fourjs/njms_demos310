-- A Simple demo program with a login and menu system.
IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL lib_login
IMPORT FGL new_acct

&include "schema.inc"

CONSTANT C_VER="3.1"
CONSTANT C_TITLE="NJM's Demos"
CONSTANT C_SPLASH="njm_demo_logo_256"
DEFINE m_user STRING
DEFINE m_user_id INT
DEFINE m_menu DYNAMIC ARRAY OF RECORD 
    menu_key LIKE sys_menus.menu_key,
		m_id LIKE sys_menus.m_id,
		m_pid LIKE sys_menus.m_pid,
		m_type LIKE sys_menus.m_type,
		m_text LIKE sys_menus.m_text,
		m_item LIKE sys_menus.m_item,
		m_passw LIKE sys_menus.m_passw,
		m_img STRING
	END RECORD
DEFINE m_menus DYNAMIC ARRAY OF VARCHAR(6)
DEFINE m_curMenu SMALLINT
DEFINE m_args STRING
DEFINE m_mdi CHAR(1)
MAIN

	CALL gl_lib.gl_init(ARG_VAL(1),NULL,FALSE)
	LET m_mdi = gl_lib.m_mdi
	IF m_mdi = "M" THEN LET m_mdi = "C" END IF -- if MDI container set so child programs are children

	CLOSE WINDOW SCREEN

	LET m_curMenu = 1
  LET m_menus[m_curMenu] = "main"
	IF do_dbconnect_and_login() THEN
		CALL do_menu()
	END IF

	DISPLAY "End Main reached."

END MAIN
--------------------------------------------------------------------------------
-- Connect to the database to do the login process.
FUNCTION do_dbconnect_and_login() RETURNS BOOLEAN

	LET gl_lib.gl_splash = C_SPLASH
	CALL gl_lib.gl_splash( 0 ) -- open splash

	CALL gl_db.gldb_connect( NULL )

	IF gl_lib.gl_fe_typ != "GBC" THEN
		SLEEP 2
		CALL gl_lib.gl_splash( -1 ) -- close splash
	END IF

	LET lib_login.m_logo_image = C_SPLASH
	LET lib_login.m_new_acc_func = FUNCTION new_acct.new_acct

	LET m_user = lib_login.login( C_TITLE, C_VER )
	IF m_user = "Cancelled" THEN RETURN FALSE END IF

	SELECT user_key INTO m_user_id FROM sys_users WHERE email = m_user

	LET m_args = m_mdi," ", m_user_id

	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
-- 
FUNCTION do_menu()
	DEFINE l_prog, l_args STRING

	OPEN WINDOW menu WITH FORM "menu"
	DISPLAY C_SPLASH TO logo

	IF NOT populate_menu(m_menus[m_curMenu]) THEN -- should not happen!
		CALL gl_lib.gl_exitProgram(0,"'main' menu not found!")
	END IF

	IF m_user IS NOT NULL THEN CALL gl_titleWin(m_user) END IF
	DISPLAY BY NAME m_user

	DISPLAY ARRAY m_menu TO menu.* ATTRIBUTE(UNBUFFERED)	

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
					CALL gl_logit("RUN:fglrun "||l_prog||" "||m_args||" "||l_args)
					DISPLAY "m_args:",m_args, " l_args:",l_args
					DISPLAY "Run: fglrun "||l_prog||" "||m_args||" "||l_args
					RUN "fglrun "||l_prog||" "||m_args||" "||l_args WITHOUT WAITING

				WHEN "P" 
					CALL gl_logit("RUN:"||l_prog||" "||l_args)
					DISPLAY "Run: "||l_prog||" "||l_args
					RUN l_prog||" "||l_args WITHOUT WAITING

				WHEN "O" 
					CALL gl_logit("OSRUN:"||m_menu[ arr_curr() ].m_item)
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
			CALL gl_lib.gl_about( C_VER )

		ON ACTION exit 
			IF ARG_VAL(1) = "MDI" THEN
				IF ui.Interface.getChildCount() > 0 THEN
					CALL gl_lib.gl_winMessage("Warning","Must close child windows first!","exclamation")
					CONTINUE DISPLAY
				END IF
			END IF
			EXIT DISPLAY

		ON ACTION close 
			IF ARG_VAL(1) = "MDI" THEN
				IF ui.Interface.getChildCount() > 0 THEN
					CALL gl_lib.gl_winMessage("Warning","Must close child windows first!","exclamation")
					CONTINUE DISPLAY
				END IF
			END IF
			EXIT DISPLAY
	END DISPLAY

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION populate_menu(l_mname LIKE sys_menus.m_id ) RETURNS BOOLEAN
	DEFINE l_role_name LIKE sys_roles.role_name
	DEFINE l_prev_key LIKE sys_menus.menu_key
	DEFINE l_titl LIKE sys_menus.m_text

	DISPLAY "menu:",l_mname," n:",m_curMenu
	SELECT m_text INTO l_titl FROM sys_menus 
		WHERE m_id = l_mname AND m_type = "T"
	IF STATUS = NOTFOUND THEN 
		DISPLAY "Menu:"||l_mname||" not found!"
		RETURN FALSE
	END IF
	DISPLAY BY NAME l_titl;

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
			{IF NOT checkUserRoles(m_user_id ,l_role_name, FALSE) THEN
				CALL m_menu.deleteElement( m_menu.getLength() )
				CONTINUE FOREACH
			END IF}
			IF m_menu[ m_menu.getLength() ].menu_key = l_prev_key THEN
				CALL m_menu.deleteElement( m_menu.getLength() )
				CONTINUE FOREACH
			END IF
			LET l_prev_key = m_menu[ m_menu.getLength() ].menu_key 
		END IF
		CASE m_menu[ m_menu.getLength() ].m_type
			WHEN "C" LET m_menu[ m_menu.getLength() ].m_img = "quit"
			WHEN "M" LET m_menu[ m_menu.getLength() ].m_img = "fa-angle-double-right"
			WHEN "P" LET m_menu[ m_menu.getLength() ].m_img = "fa-gear"
			WHEN "F" LET m_menu[ m_menu.getLength() ].m_img = "fa-gear"
		END CASE
	END FOREACH
	LET m_menu[m_menu.getLength()].m_type = "C"
	LET m_menu[m_menu.getLength()].m_text = "Back"
	LET m_menu[m_menu.getLength()].m_item = "back"
	LET m_menu[m_menu.getLength()].m_img = "fa-angle-double-left"
	IF m_menu[m_menu.getLength() - 1].m_pid IS NULL THEN
		LET m_menu[m_menu.getLength()].m_text = "Quit"
		LET m_menu[m_menu.getLength()].m_item = "quit"
		LET m_menu[m_menu.getLength()].m_img = "quit"
	END IF
	RETURN TRUE

END FUNCTION
--------------------------------------------------------------------------------
-- split program and args to two variables.
FUNCTION progArgs( l_prog STRING )
  DEFINE l_args STRING
  DEFINE y SMALLINT
  DISPLAY "l_prog:",l_prog
  LET y = l_prog.getIndexOf(" ",1)
  LET l_args = " "
  IF y > 0 THEN
    LET l_args = l_prog.subString(y,l_prog.getLength())
    LET l_prog = l_prog.subString(1,y)
  END IF
  IF l_args IS NULL THEN LET l_args = " " END IF
  DISPLAY "l_prog:",l_prog," l_args:",l_args
  RETURN l_prog, l_args
END FUNCTION
--------------------------------------------------------------------------------
