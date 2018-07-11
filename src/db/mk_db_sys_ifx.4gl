
#+ Create the system database tables: Informix

--------------------------------------------------------------------------------
FUNCTION ifx_create_system_tables()
	CALL mkdb_progress( "Creating system tables..." )

	CREATE TABLE sys_users (
		user_key    SERIAL NOT NULL,
		salutation  VARCHAR(60),
		forenames   VARCHAR(60) NOT NULL,
		surname     VARCHAR(60) NOT NULL,
		position    VARCHAR(60),
		email       VARCHAR(60) NOT NULL,
		comment     VARCHAR(60),
		acct_type   SMALLINT,
		active      SMALLINT NOT NULL,
		forcepwchg  CHAR(1),
		hash_type		VARCHAR(12) NOT NULL, -- type of hash used.
		login_pass  VARCHAR(16), -- not actually used.
		salt        VARCHAR(64), -- for Genero 3.10 using bcrypt we don't need this
		pass_hash   VARCHAR(128) NOT NULL,
		pass_expire DATE
	);

	CREATE TABLE sys_user_roles (
		user_key INTEGER,
		role_key INTEGER,
		active CHAR(1),
			PRIMARY KEY (user_key, role_key)
	);

	CREATE TABLE sys_roles (
		role_key  SERIAL,
		role_type CHAR(1),
		role_name VARCHAR(30),
		active    CHAR(1)
	);

	CREATE TABLE sys_menus (
		menu_key	SERIAL,
		m_id      VARCHAR(6),
		m_pid     VARCHAR(6),
		m_type    CHAR(1),
		m_text    VARCHAR(40),
		m_item    VARCHAR(80),
		m_passw   VARCHAR(8)
	);

	CREATE TABLE sys_menu_roles (
		menu_key INTEGER,
		role_key INTEGER,
		active   CHAR(1),
			PRIMARY KEY (menu_key, role_key)
	);

	CALL mkdb_progress( "Done" )
END FUNCTION