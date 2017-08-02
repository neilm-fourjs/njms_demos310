
#+ User Maintenance Demo - by N.J.Martin neilm@4js.com

IMPORT FGL app_lib
IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL lib_secure

&include "genero_lib.inc"
&include "app.inc"
CONSTANT C_VER="3.1"
CONSTANT C_PRGDESC = "User Maintenance Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"

DEFINE m_user DYNAMIC ARRAY OF RECORD LIKE sys_users.*
DEFINE m_roles DYNAMIC ARRAY OF RECORD LIKE sys_roles.*
DEFINE m_uroles DYNAMIC ARRAY OF RECORD 
				user_key LIKE sys_user_roles.user_key,
				role_key LIKE sys_user_roles.role_key,
				role_name LIKE sys_roles.role_name,
				active LIKE sys_user_roles.active
		END RECORD
DEFINE m_user_rec RECORD LIKE sys_users.*
DEFINE m_fullname DYNAMIC ARRAY OF STRING
DEFINE m_drag_source STRING
DEFINE m_save, m_saveUser, m_saveRoles BOOLEAN
DEFINE m_user_key, m_this_user_key LIKE sys_users.user_key
MAIN
	DEFINE dnd ui.DragDrop

	LET gl_lib.gl_topMenu = "dynmaint"
	CALL gl_lib.gl_setInfo(C_VER, C_APP_SPLASH, C_APP_ICON, NULL, C_PRGDESC, C_PRGAUTH)
	CALL gl_lib.gl_init(ARG_VAL(1),NULL,TRUE)
	WHENEVER ANY ERROR CALL gl_error
	LET m_this_user_key = ARG_VAL(2)

	LET m_saveUser = FALSE
	OPEN FORM um FROM "user_mnt"
	DISPLAY FORM um

	CALL gl_db.gldb_connect(NULL)

	IF NOT app_lib.checkUserRoles(m_this_user_key,"System Admin",TRUE) THEN
		EXIT PROGRAM
	END IF

	DECLARE u_cur CURSOR FOR SELECT * FROM sys_users
	FOREACH u_cur INTO m_user[m_user.getLength()+1].*
		LET m_fullname[ m_user.getLength() ] = 			app_lib.getFullName(
					 m_user[m_user.getLength()].salutation,
					 m_user[m_user.getLength()].forenames, 
					 m_user[m_user.getLength()].surname )
	END FOREACH
	LET m_fullname[ m_user.getLength() ]  = "Click here for new User"

	DECLARE r_cur CURSOR FOR SELECT * FROM sys_roles
	FOREACH r_cur INTO m_roles[m_roles.getLength()+1].*
	END FOREACH
	CALL m_roles.deleteElement( m_roles.getLength() )

	PREPARE ur_pre FROM 
		"SELECT ur.user_key, ur.role_key, r.role_name, ur.active"||
		" FROM sys_user_roles ur,sys_roles r WHERE user_key = ? AND r.role_key = ur.role_key"
	DECLARE ur_cur CURSOR FOR ur_pre

	LET m_save = FALSE
	DIALOG ATTRIBUTES(UNBUFFERED)
		DISPLAY ARRAY m_fullname TO u_arr.*
			BEFORE DISPLAY
				IF m_save THEN
					IF gl_lib.gl_winQuestion("Confirm","Save these changes?","No","Yes|No","question") = "Yes" THEN
						CALL saveRoles_user()
					ELSE
						CALL setSave_user(FALSE)
					END IF
				END IF
			BEFORE ROW
				MESSAGE "DA User:",DIALOG.getCurrentRow("u_arr")," of ",m_fullname.getLength()," ",m_user[ DIALOG.getCurrentRow("u_arr") ].surname
				LET m_user_rec.* = m_user[ DIALOG.getCurrentRow("u_arr") ].*
				LET m_user_key = m_user[ DIALOG.getCurrentRow("u_arr") ].user_key
				CALL m_uroles.clear()
				FOREACH ur_cur USING m_user_key INTO m_uroles[m_uroles.getLength()+1].*
				END FOREACH
				CALL  m_uroles.deleteElement(m_uroles.getLength())
				IF m_user_rec.user_key IS NULL THEN
					NEXT FIELD salutation
				END IF
			ON DRAG_START(dnd)
				LET m_drag_source = "users"
			ON DRAG_ENTER(dnd)
				CALL dnd.setOperation(NULL)
			ON ACTION delete
				CALL del_user(arr_curr())
		END DISPLAY

		DISPLAY ARRAY m_uroles TO ur_arr.*
			ON ACTION dblclick
				IF gl_lib.gl_winQuestion("Confirm","Toggle activate state for users role?","No","Yes|No","question") = "Yes" THEN
					LET m_uroles[ ARR_CURR() ].active = toggle(m_uroles[ ARR_CURR() ].active)
					CALL setSave_user(TRUE)
				END IF
			ON ACTION removeRoles
				CALL removeRoles_user(DIALOG)
			ON DRAG_ENTER(dnd)
				IF m_drag_source = "roles" THEN
					CALL dnd.setOperation("copy")
				ELSE
					CALL dnd.setOperation(NULL)
				END IF
			ON DROP(dnd)
				CALL addRoles_user(DIALOG)
			ON DRAG_FINISHED(dnd)
				LET m_drag_source = NULL
		END DISPLAY
		DISPLAY ARRAY m_roles TO r_arr.*
			ON ACTION dblclick
				IF gl_lib.gl_winQuestion("Confirm","Toggle activate state for this role?","No","Yes|No","question") = "Yes" THEN
					LET m_roles[ ARR_CURR() ].active = toggle(m_roles[ ARR_CURR() ].active)
				END IF
			ON DRAG_START(dnd)
				LET m_drag_source = "roles"
			ON ACTION addRoles
				CALL addRoles_user(DIALOG)
		END DISPLAY

		INPUT m_user_rec.* FROM sys_users.* ATTRIBUTE(WITHOUT DEFAULTS)
			ON ACTION dialogTouched
				CALL DIALOG.setActionActive("dialogtouched",FALSE)
				LET m_saveUser = TRUE
				CALL setSave_user(TRUE)
				DISPLAY "Touched!"
			BEFORE INPUT
				CALL DIALOG.setactionActive("save",FALSE)
				IF m_user_rec.user_key IS NULL THEN
					LET m_user_rec.active = TRUE
					LET m_user_rec.forcepwchg = "N"
					LET m_user_rec.hash_type = lib_secure.glsec_getHashType()
					LET m_user_rec.salt = lib_secure.glsec_genSalt(m_user_rec.hash_type) -- NOTE: for Genero 3.10 we don't need to store this
					LET m_user_rec.pass_expire = (TODAY + 6 UNITS MONTH)
				END IF
				LEt m_saveUser = FALSE
				MESSAGE "IN User:",DIALOG.getCurrentRow("u_arr")," of ",m_fullname.getLength()," ",m_user[ DIALOG.getCurrentRow("u_arr") ].surname
				CALL checkSave()
			ON ACTION save
				IF DIALOG.validate("sys_users.*") < 0 THEN
					CONTINUE DIALOG
				ELSE
					LET m_user_rec.pass_hash = lib_secure.glsec_genPasswordHash(m_user_rec.login_pass ,m_user_rec.salt,m_user_rec.hash_type)
					LET m_user_rec.login_pass = "PasswordEncrypted!" -- we don't store their clear text password!
					CALL checkSave()
					CALL setSave_user(FALSE)
				END IF
			ON ACTION cancel
				CALL setSave_user(FALSE)
				LET m_user_rec.* = m_user[ 1 ].*
				CALL DIALOG.setCurrentRow("u_arr",1)
				NEXT FIELD u_arr.fullname
			AFTER INPUT
				CALL DIALOG.setActionActive("dialogtouched",TRUE)
		END INPUT
		BEFORE DIALOG
			CALL DIALOG.setSelectionMode( "r_arr", TRUE )
			CALL DIALOG.setSelectionMode( "ur_arr", TRUE )
			CALL DIALOG.setactionActive("save",m_save)
		ON ACTION save
			CALL checkSave()
		ON ACTION quit
			CALL checkSave()
			EXIT DIALOG
		ON ACTION close
			EXIT DIALOG
		GL_ABOUT
	END DIALOG
	CALL gl_lib.gl_exitProgram(0,"Program Finished")
END MAIN
--------------------------------------------------------------------------------
FUNCTION removeRoles_user(d)
	DEFINE d ui.Dialog
	DEFINE x SMALLINT
	FOR x = 1 TO m_roles.getLength()
		IF d.isRowSelected("ur_arr",x) THEN
			CALL m_uroles.deleteElement(x)
			LET m_saveRoles = TRUE
			LET m_save = TRUE
		END IF
	END FOR
	CALL d.setactionActive("save",m_save)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION addRoles_user(d)
	DEFINE d ui.Dialog
	DEFINE x,y SMALLINT
	FOR x = 1 TO m_roles.getLength()
		IF d.isRowSelected("r_arr",x) THEN
			FOR y = 1 TO m_uroles.getLength()
				IF m_roles[x].role_key = m_uroles[y].role_key THEN
					EXIT FOR
				END IF
			END FOR
			LET m_uroles[y].active = m_roles[x].active
			LET m_uroles[y].role_key = m_roles[x].role_key
			LET m_uroles[y].user_key = m_user_key
			LET m_uroles[y].role_name = m_roles[x].role_name
			LET m_save = TRUE
			LET m_saveRoles = TRUE
		END IF
	END FOR
	CALL d.setactionActive("save",m_save)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION setSave_user(tf)
	DEFINE tf BOOLEAN
	DEFINE d ui.Dialog
	DISPLAY "setSave:",tf
	LET m_save = tf
	LET d = ui.Dialog.getCurrent()
	CALL d.setactionActive("save",m_save)
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION checkSave()
	IF m_save THEN 
		IF gl_lib.gl_winQuestion("Confirm","Save these changes?","No","Yes|No","question") = "Yes" THEN
			IF m_saveUser THEN CALL saveUser() END IF	
			IF m_saveRoles THEN CALL saveRoles_user() END IF
		END IF
	END IF
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION saveUser()
	DEFINE x SMALLINT
	DEFINE d ui.Dialog
	DEFINE l_comment VARCHAR(20)
	LET l_comment = "User added:"||TODAY
	LET d = ui.Dialog.getCurrent()
	LET x = d.getCurrentRow("u_arr")
	IF m_user_rec.user_key IS NULL OR m_user_rec.user_key < 1 THEN
		LET m_user_rec.user_key = 0
		INSERT INTO sys_users VALUES( m_user_rec.* )
		LET m_user_key = SQLCA.sqlerrd[2]
		LET m_user_rec.user_key = m_user_key
		LET m_user[x].user_key = m_user_rec.user_key
		LET m_fullname[ m_user.getLength() + 1 ]  = "Click here for new User"
	ELSE
		UPDATE sys_users SET sys_users.* = m_user_rec.* 
			WHERE sys_users.user_key = m_user_rec.user_key
	END IF
	LET m_fullname[ x ] = app_lib.getFullName( m_user_rec.salutation, m_user_rec.forenames, m_user_rec.surname )
	LET m_user[ x ].* = m_user_rec.*
	LET m_save = FALSE
	LET m_saveUser = FALSE

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION saveRoles_user()
	DEFINE x SMALLINT

	IF NOT checkUserRoles(m_this_user_key,"System Admin Update",TRUE) THEN
		CALL setSave_user(FALSE)
		RETURN
	END IF

	BEGIN WORK
	DELETE FROM sys_user_roles WHERE user_key = m_user_key
	FOR x = 1 TO m_uroles.getLength()
		INSERT INTO sys_user_roles VALUES( m_user_key,m_uroles[x].role_key,m_uroles[x].active )
	END FOR
	COMMIT WORK
	CALL setSave_user(FALSE)
-- Need to actually update tables here!
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION del_user(x)
	DEFINE x SMALLINT

	IF m_user[x].user_key IS NULL THEN RETURN END IF
	IF gl_lib.gl_winQuestion("Confirm","Are you sure you want to delete this user?","No","Yes|No","question")
		= "Yes" THEN
		DELETE FROM sys_users WHERE user_key = m_user[x].user_key
		CALL m_user.deleteElement( x )
		CALL m_fullname.deleteElement( x )
	END IF
	MESSAGE "User Deleted"
END FUNCTION
--------------------------------------------------------------------------------