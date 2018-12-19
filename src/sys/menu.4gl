-- A Simple demo program with a login and menu system.
IMPORT os
IMPORT FGL gl_lib
IMPORT FGL gl_about
IMPORT FGL gl_splash
IMPORT FGL gl_db
IMPORT FGL gl_gdcupd
IMPORT FGL lib_login
IMPORT FGL new_acct

&include "genero_lib.inc"
&include "schema.inc"
&include "app.inc"

CONSTANT C_TITLE="NJM's Demos"
CONSTANT C_SPLASH="logo_dark"
CONSTANT C_ICON="njm_demo_icon"
CONSTANT PRGDESC = "NJM's Demos Menu System"
CONSTANT PRGAUTH = "Neil J.Martin"

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
MAIN
	CALL gl_lib.gl_setInfo(C_VER, C_SPLASH, C_ICON, NULL, PRGDESC, PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),NULL,FALSE)
	CALL ui.Interface.setText( gl_progdesc )

	CLOSE WINDOW SCREEN

	IF gl_lib.m_mdi = "M" THEN LET gl_lib.m_mdi = "C" END IF -- if MDI container set so child programs are children

	LET m_curMenu = 1
	LET m_menus[m_curMenu] = "main"
	IF do_dbconnect_and_login() THEN
		CALL gl_gdcupd.gl_gdcupd()
		CALL do_menu()
	END IF
	CALL gl_lib.gl_exitProgram(0,%"Program Finished")
END MAIN
--------------------------------------------------------------------------------
-- Connect to the database to do the login process
FUNCTION do_dbconnect_and_login() RETURNS BOOLEAN

	IF gl_fe_typ != "GBC" AND gl_lib.m_mdi = "S" THEN
		LET gl_splashImage = C_SPLASH
		CALL gl_splash( 0 ) -- open splash
	END IF

	CALL gl_db.gldb_connect( NULL )

	IF gl_fe_typ != "GBC" AND gl_lib.m_mdi = "S" THEN
		SLEEP 2
		CALL gl_splash( -1 ) -- close splash
	END IF

	LET lib_login.m_logo_image = C_SPLASH
	LET lib_login.m_new_acc_func = FUNCTION new_acct.new_acct

-- For quick testing only
	IF ARG_VAL(1) = "test@test.com" THEN
		LET m_user = ARG_VAL(1)
	ELSE
		LET m_user = lib_login.login( C_TITLE, C_VER )
	END IF
	IF m_user = "Cancelled" THEN RETURN FALSE END IF

	SELECT user_key INTO m_user_id FROM sys_users WHERE email = m_user

	LET m_args = gl_lib.m_mdi," ", m_user_id

	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION quit() RETURNS BOOLEAN
	IF ARG_VAL(1) = "MDI" THEN
		IF ui.Interface.getChildCount() > 0 THEN
			CALL gl_lib.gl_warnPopup(%"Must close child windows first!")
			RETURN FALSE
		END IF
	END IF
	RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION do_menu()
	DEFINE l_dummy CHAR(1)

	OPEN WINDOW menu WITH FORM "menu"
--	OPEN FORM menu FROM "menu"
--	DISPLAY FORM menu

	DISPLAY C_SPLASH TO logo
	CALL ui.Interface.setText( gl_progdesc )

	IF NOT populate_menu(m_menus[m_curMenu]) THEN -- should not happen!
		CALL gl_lib.gl_exitProgram(0,"'main' menu not found!")
	END IF

	IF m_user IS NOT NULL THEN CALL gl_titleWin(m_user) END IF
	DISPLAY BY NAME m_user

	WHILE NOT int_flag
		DISPLAY CURRENT,":Dialog Started."
		DIALOG ATTRIBUTE(UNBUFFERED)
			INPUT BY NAME l_dummy
				BEFORE FIELD l_dummy
				--	DISPLAY "BF Dummy"
			END INPUT

			DISPLAY ARRAY m_menu TO menu.* 
				BEFORE ROW
					EXIT DIALOG

				ON ACTION accept
					EXIT DIALOG
			END DISPLAY

			BEFORE DIALOG
				IF m_curMenu > 1 THEN
					CALL DIALOG.setActionActive("back",TRUE)
				ELSE
					CALL DIALOG.setActionActive("back",FALSE)
				END IF

			GL_ABOUT

			ON ACTION logout
				CALL lib_login.logout( )
				IF quit() THEN LET int_flag = TRUE EXIT DIALOG END IF

			ON ACTION exit 
				IF quit() THEN LET int_flag = TRUE EXIT DIALOG END IF

			ON ACTION close 
				IF quit() THEN LET int_flag = TRUE EXIT DIALOG END IF

			ON ACTION back
				DISPLAY CURRENT,":BACK m_curMenu:",m_curMenu
				IF m_curMenu > 1 THEN
					IF populate_menu(m_menus[m_curMenu - 1]) THEN
						LET m_curMenu = m_curMenu - 1
					END IF
					IF m_curMenu = 1 THEN
						CALL DIALOG.setActionActive("back",FALSE)
					END IF
					NEXT FIELD l_dummy
				END IF

		END DIALOG
		IF NOT int_flag THEN CALL process_menu_item( arr_curr() ) END IF
	END WHILE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION process_menu_item( x SMALLINT )
	DEFINE l_prog, l_args STRING

	DISPLAY CURRENT,":Process_menu_item:"||x||":",m_menu[x].m_type||"-"||m_menu[x].m_text

	CASE m_menu[ x ].m_type 
		WHEN "C"
			CASE m_menu[ x ].m_item 
				WHEN "quit"
					IF quit() THEN LET int_flag = TRUE RETURN END IF

				WHEN "back" 
					IF m_curMenu > 1 AND populate_menu(m_menus[m_curMenu - 1]) THEN
						LET m_curMenu = m_curMenu - 1
					END IF
			END CASE

		WHEN "F" -- Run a standard 42r - with defaults args
			CALL progArgs( m_menu[ x ].m_item ) RETURNING l_prog, l_args
			CALL gl_logit("RUN:fglrun "||l_prog||" "||m_args||" "||l_args)
			--DISPLAY "l_prog:",l_prog," m_args:",m_args, " l_args:",l_args
			--DISPLAY "Run: fglrun "||l_prog||" "||m_args||" "||l_args
			IF NOT os.path.exists( l_prog ) THEN
				CALL gl_lib.gl_errPopup(SFMT(%"This program '%1' appears to not be installed!",l_prog))
			END IF
			RUN "fglrun "||l_prog||" "||m_args||" "||l_args WITHOUT WAITING

		WHEN "S" -- Run a simple 42r - no args
			CALL gl_logit("RUN:fglrun "||m_menu[ x ].m_item)
			IF NOT os.path.exists( m_menu[ x ].m_item ) THEN
				CALL gl_lib.gl_errPopup(SFMT(%"This program '%1' appears to not be installed!", m_menu[ x ].m_item))
			END IF
			RUN "fglrun "||m_menu[ x ].m_item WITHOUT WAITING

		WHEN "P"
			CALL progArgs( m_menu[ x ].m_item ) RETURNING l_prog, l_args
			CALL gl_logit("RUN:"||l_prog||" "||l_args)
			DISPLAY "Run: "||l_prog||" "||l_args
			RUN l_prog||" "||l_args WITHOUT WAITING

		WHEN "O" 
			CALL gl_logit("OSRUN:"||m_menu[ x ].m_item)
			DISPLAY "exec: "||m_menu[ x ].m_item
			RUN m_menu[ arr_curr() ].m_item WITHOUT WAITING

		WHEN "M"
			LET m_menus[m_curMenu + 1] = m_menu[ x ].m_item
			IF populate_menu(m_menus[m_curMenu + 1]) THEN
				LET m_curMenu = m_curMenu + 1
			END IF
	END CASE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION populate_menu(l_mname LIKE sys_menus.m_id ) RETURNS BOOLEAN
	DEFINE l_role_name LIKE sys_roles.role_name
	DEFINE l_prev_key LIKE sys_menus.menu_key
	DEFINE l_titl LIKE sys_menus.m_text

	DISPLAY CURRENT,": Menu:",l_mname," m_curMenu:",m_curMenu
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
		--DISPLAY "Got Menu:", m_menu[ m_menu.getLength() ].m_text
		IF l_role_name IS NOT NULL THEN
			{DISPLAY "Role:",l_role_name
			IF NOT checkUserRoles(m_user_id ,l_role_name, FALSE) THEN
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
			WHEN "P" LET m_menu[ m_menu.getLength() ].m_img = "fa-cog"
			WHEN "F" LET m_menu[ m_menu.getLength() ].m_img = "fa-cog"
			WHEN "S" LET m_menu[ m_menu.getLength() ].m_img = "fa-cog"
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
-- split program and args to two variables
FUNCTION progArgs( l_prog STRING ) RETURNS (STRING,STRING)
  DEFINE l_args STRING
  DEFINE y SMALLINT
  LET y = l_prog.getIndexOf(" ",1)
  LET l_args = " "
  IF y > 0 THEN
    LET l_args = l_prog.subString(y,l_prog.getLength())
    LET l_prog = l_prog.subString(1,y-1)
  END IF
  IF l_args IS NULL THEN LET l_args = " " END IF
  DISPLAY "l_prog:",l_prog," l_args:",l_args
  RETURN l_prog, l_args
END FUNCTION
--------------------------------------------------------------------------------