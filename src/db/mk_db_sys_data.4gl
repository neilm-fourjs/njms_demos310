
IMPORT FGL gl_lib
IMPORT FGL lib_secure
&include "schema.inc"

DEFINE m_dbtyp CHAR(3)
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
	CALL addMenu("demo","main","M","Web Component Demos", "wcdemo","")

	CALL addMenu("wcdemo","demo","T","Web Component Demos", "","")
	CALL addMenu("wcdemo","demo","F","GoogleMaps WC Demo", "wc_googleMaps.42r","")
	CALL addMenu("wcdemo","demo","F","AmCharts WC Demo", "wc_amCharts.42r","")
	CALL addMenu("wcdemo","demo","F","Kite WC Demo", "wc_kite.42r","")
	CALL addMenu("wcdemo","demo","F","Aircraft WC Demo", "wc_aircraft.42r","")
	CALL addMenu("wcdemo","demo","F","Music WC Demo", "wc_music.42r","")

	CALL addMenu("sys","main","T","System Maintenance", "","")
	CALL addMenu("sys","main","F","User/Role Maintenance", "user_mnt.42r","")
	CALL addMenu("sys","main","F","Menu/Role Maintenance", "menu_mnt.42r","")

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
	CALL addMenu("util","main","F","fontAwesome", "fontAwesome.42r","")
	CALL mkdb_progress( "Done." )

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION mk_demo_account()
	DEFINE l_hash_type, l_login_pass, l_salt, l_pass_hash, l_email VARCHAR(128)
	DEFINE l_dte DATE
	CALL mkdb_progress( "Creating test account." )
	LET l_email = "test@test.com"
	SELECT * FROM sys_users WHERE email = l_email
	IF STATUS = 0 THEN RETURN END IF

	LET l_login_pass = "12test"
	LET l_hash_type = lib_secure.glsec_getHashType()
	LET l_salt = lib_secure.glsec_genSalt(l_hash_type)
	LET l_pass_hash = lib_secure.glsec_genPasswordHash( l_login_pass, l_salt, l_hash_type )
	LET l_dte = TODAY+365
	TRY
		INSERT INTO sys_users VALUES(1,"Mr","Test","Testing","Tester",l_email,"A test account",0,1,"N",
			l_hash_type, "not stored", l_salt, l_pass_hash, l_dte)
-- NOTE: we don't store the clear text password
		CALL mkdb_progress( "Test Account Inserted: "||l_email||" / "||l_login_pass||" with "||l_hash_type||" hash." )
	CATCH
		CALL mkdb_progress( "Insert test account failed!\n"||STATUS||":"||SQLERRMESSAGE )
	END TRY
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION addRole(l_type CHAR,l_name VARCHAR(30))

	IF m_dbtyp = "pgs" THEN
		INSERT INTO sys_roles VALUES(nextval('sys_roles_role_key_seq'),l_type,l_name,"Y")
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

	IF m_dbtyp = "pgs" THEN
		INSERT INTO sys_menus VALUES(nextval('sys_menus_menu_key_seq'),l_id,l_pid,l_type,l_text,l_item,l_passw)
	ELSE
		INSERT INTO sys_menus VALUES(m_mkey,l_id,l_pid,l_type,l_text,l_item,l_passw)
	END IF
	LET m_mkey = m_mkey + 1
END FUNCTION