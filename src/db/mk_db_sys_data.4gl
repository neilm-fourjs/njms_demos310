
IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL lib_secure
&include "schema.inc"
&include "app.inc"

DEFINE m_mkey, m_ukey, m_rkey INTEGER
--------------------------------------------------------------------------------
FUNCTION insert_system_data()
	DEFINE l_db STRING

	LET l_db = fgl_getEnv("DBNAME")

	CALL mkdb_progress( "Loading system users / menus ..." )

	LET m_ukey = 1
	CALL mk_demo_account()

	LET m_rkey = 1
	CALL addRole("S","Login")
	CALL addRole("S","Operator")
	CALL addRole("M","System Admin")
	CALL addRole("M","Order Entry")
	CALL addRole("M","Order Edit")
	CALL addRole("S","Invoice Printing")
	CALL addRole("M","Enquiries")
	CALL addRole("M","Customer Management")
	CALL addRole("M","Stock Management")
	CALL addRole("M","System Admin Update")
	CALL addRole("M","Delete")

	INSERT INTO sys_user_roles VALUES(1,1,"Y")
	INSERT INTO sys_user_roles VALUES(1,2,"Y")
	INSERT INTO sys_user_roles VALUES(1,3,"Y")
	INSERT INTO sys_user_roles VALUES(1,4,"Y")
	INSERT INTO sys_user_roles VALUES(1,5,"Y")
	INSERT INTO sys_user_roles VALUES(1,6,"Y")
	INSERT INTO sys_user_roles VALUES(1,10,"Y")

	LET m_mkey = 1
	CALL addMenu("main","","T","Four J's Demos Menu", "","")
	CALL addMenu("main","","M","Demos Programs", "demo","")
	CALL addMenu("main","","M","Enquiry Programs", "enq","")
	CALL addMenu("main","","M","Maintenance Programs", "mnt","")
	CALL addMenu("main","","M","Order Entry", "oe","")
	CALL addMenu("main","","M","System Maintenance", "sys","")
	CALL addMenu("main","","M","Utilities", "util","")

	CALL addMenu("demo","main","T","UI Demo Programs", "","")
	CALL addMenu("demo","main","F","Widgets Demo", "widgets.42r","")
	CALL addMenu("demo","main","F","ipodTree Demo", "ipodTree.42r","")
	CALL addMenu("demo","main","F","picFlow Demo", "picFlow.42r ../pics","")
	CALL addMenu("demo","main","F","Display Array Demo", "dispArr.42r","")
	CALL addMenu("demo","main","F","Multi Cell Select","multi_cell_sel.42r","")
	CALL addMenu("demo","main","F","Table - List View", "listView.42r","")
	CALL addMenu("demo","main","M","Wizard - Dialog Demos", "wizard","")
	CALL addMenu("demo","main","M","Web Component Demos", "wcdemo","")

	CALL addMenu("wizard","demo","T","Wizard - Dialog Demos", "","")
	CALL addMenu("wizard","demo","F","Wizard SD","wizard1_sd.42r","")
	CALL addMenu("wizard","demo","F","Wizard MD","wizard2_md.42r","")
	CALL addMenu("wizard","demo","F","Wizard MRS","wizard3_mrs.42r","")
	CALL addMenu("wizard","demo","F","Wizard DnD","wizard4_dnd.42r","")

	CALL addMenu("wcdemo","demo","T","Web Component Demos", "","")
	CALL addMenu("wcdemo","demo","F","GoogleMaps Demo", "wc_googleMaps.42r","")
	CALL addMenu("wcdemo","demo","F","AmCharts Demo", "wc_amCharts.42r","")
	CALL addMenu("wcdemo","demo","F","D3Charts Demo", "wc_d3charts_demo.42r","")
	CALL addMenu("wcdemo","demo","F","Kite Demo", "wc_kite.42r","")
	CALL addMenu("wcdemo","demo","F","Aircraft Demo", "wc_aircraft.42r","")
	CALL addMenu("wcdemo","demo","F","Remote Music Player Demo", "wc_music.42r","")
	CALL addMenu("wcdemo","demo","F","Calendar Demo", "wc_calendar_demo.42r","")
	CALL addMenu("wcdemo","demo","F","Richtext Demo", "wc_richtext.42r","")

	CALL addMenu("sys","main","T","System Maintenance", "","")
	CALL addMenu("sys","main","F","User/Role Maintenance", "user_mnt.42r","")
	CALL addMenu("sys","main","F","Menu/Role Maintenance", "menu_mnt.42r","")
	CALL addMenu("sys","main","F","View Login History", "login_hist.42r","")

	CALL addMenu("enq","main","T","Enquiry Programs", "","")
	CALL addMenu("enq","main","F","Customer Enquiry", "cust_mnt.42r YYNNNN","")
	CALL addMenu("enq","main","F","Stock Enquiry", "dynMaint.42r "||l_db||" stock stock_code YYNNNN","")
	CALL addMenu("enq","main","F","Supplier Enquiry", "dynMaint.42r "||l_db||" supplier supp_code YYNNNN","")

	CALL addMenu("mnt","main","T","Maintenance Programs", "","")
	CALL addMenu("mnt","main","F","Customer Maintenance", "cust_mnt.42r","")
	CALL addMenu("mnt","main","F","Stock Maintenance", "dm_stock.42r","")
	CALL addMenu("mnt","main","F","Stock Cat Maintenance", "dynMaint.42r "||l_db||" stock_cat catid","")
	CALL addMenu("mnt","main","F","Supplier Maintenance", "dynMaint.42r "||l_db||" supplier supp_code","")

	CALL addMenu("oe","main","T","Order Entry", "","")
	CALL addMenu("oe","main","F","Order Entry", "orderEntry.42r ","")
	CALL addMenu("oe","main","F","Web Order Entry #1", "webOE.42r ","")
	CALL addMenu("oe","main","F","Web Order Entry #2", "webOE2.42r ","")
	CALL addMenu("oe","main","M","Invoicing Reports", "oeprn","")
	CALL addMenu("oeprn","oe","T","Invoicing Reports", "","")
	CALL addMenu("oeprn","oe","F","Print Invoices", "printInvoices.42r 0 ordent.4rp","")
	CALL addMenu("oeprn","oe","F","Print Picking Notes", "printInvoices.42r picklist.4rp","")

	CALL addMenu("util","main","T","Utilities", "","")
	CALL addMenu("util","main","F","Material Design Test", "materialDesignTest.42r","")
	CALL addMenu("util","main","F","FontAwesome", "fontAwesome.42r","")
	CALL addMenu("util","main","P","FontAwesome Default", "../utils/fontAwesome.sh","")
	CALL addMenu("util","main","S","GRE Test 4RP", "gre_test4rp.42r","")
	CALL addMenu("util","main","S","Reset Database", "mk_db.42r","")
	CALL mkdb_progress( "Done." )

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION mk_demo_account()
	DEFINE l_hash_type, l_login_pass, l_salt, l_pass_hash, l_email VARCHAR(128)
	DEFINE l_dte DATE

	CALL mkdb_progress( SFMT("Creating test account: %1 / %2", C_DEF_USER_EMAIL,C_DEF_USER_PASSWD))
	LET l_email = C_DEF_USER_EMAIL
	SELECT * FROM sys_users WHERE email = l_email
	IF STATUS = 0 THEN RETURN END IF

	LET l_login_pass = C_DEF_USER_PASSWD
	LET l_hash_type = lib_secure.glsec_getHashType()
	LET l_salt = lib_secure.glsec_genSalt(l_hash_type)
	LET l_pass_hash = lib_secure.glsec_genPasswordHash( l_login_pass, l_salt, l_hash_type )
	LET l_dte = TODAY+365
	TRY
		IF gl_db.m_dbtyp = "pgs" OR gl_db.m_dbtyp = "snc" THEN
			INSERT INTO sys_users 
					( salutation ,
						forenames  ,
						surname    ,
						position   ,
						email      ,
						comment    ,
						acct_type  ,
						active     ,
						forcepwchg ,
						hash_type	,
						login_pass ,
						salt       ,
						pass_hash  ,
						pass_expire,
						gbc_theme,
						photo_uri)
				VALUES("Mr","Test","Testing","Tester",l_email,"A test account",0,1,"N",	
								l_hash_type, "not stored", l_salt, l_pass_hash, l_dte, NULL, NULL)
		ELSE
			INSERT INTO sys_users 
				VALUES(1,"Mr","Test","Testing","Tester",l_email,"A test account",0,1,"N",	l_hash_type, "not stored", l_salt, l_pass_hash, l_dte, NULL, NULL)
		END IF
-- NOTE: we don't store the clear text password
		CALL mkdb_progress( SFMT("Test Account Inserted: %1 / %2 with %3 hash.",l_email,l_login_pass,l_hash_type ) )
	CATCH
		CALL mkdb_progress( "Insert test account failed!\n"||STATUS||":"||SQLERRMESSAGE )
		EXIT PROGRAM
	END TRY
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION addRole(l_type CHAR,l_name VARCHAR(30))

	IF gl_db.m_dbtyp = "pgs" OR gl_db.m_dbtyp = "snc" THEN
		INSERT INTO sys_roles ( role_type, role_name, active) VALUES(l_type,l_name,"Y")
	ELSE
		INSERT INTO sys_roles VALUES(m_rkey,l_type,l_name,"Y")
	END IF
	LET m_rkey = m_rkey + 1
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION addMenu(
		l_id      VARCHAR(6),
		l_pid     VARCHAR(6),
		l_type    CHAR(1),
		l_text    VARCHAR(40),
		l_item    VARCHAR(80),
		l_passw   VARCHAR(8) )

	IF gl_db.m_dbtyp = "pgs" OR gl_db.m_dbtyp = "snc" THEN
		INSERT INTO sys_menus (m_id, m_pid, m_type, m_text, m_item, m_passw) VALUES(l_id,l_pid,l_type,l_text,l_item,l_passw)
	ELSE
		INSERT INTO sys_menus VALUES(m_mkey,l_id,l_pid,l_type,l_text,l_item,l_passw)
	END IF
	LET m_mkey = m_mkey + 1
END FUNCTION
