
IMPORT FGL gl_lib
IMPORT FGL lib_secure
&include "schema.inc"

DEFINE m_dbtyp CHAR(3)
DEFINE m_mkey, m_ukey, m_rkey INTEGER
--------------------------------------------------------------------------------
FUNCTION insert_system_data()

	DISPLAY "Loading system users / menus ..."

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

	INSERT INTO sys_acct_roles VALUES(1,1,"Y")
	INSERT INTO sys_acct_roles VALUES(1,2,"Y")
	INSERT INTO sys_acct_roles VALUES(1,3,"Y")
	INSERT INTO sys_acct_roles VALUES(1,4,"Y")
	INSERT INTO sys_acct_roles VALUES(1,5,"Y")
	INSERT INTO sys_acct_roles VALUES(1,6,"Y")
	INSERT INTO sys_acct_roles VALUES(1,10,"Y")

	LET m_mkey = 1
	CALL addMenu("main","","T","Four J's Demos Menu", "","")
	--CALL addMenu("main","","M","Demos Programs", "demo","")
	CALL addMenu("main","","M","Enquiry Programs", "enq","")
	CALL addMenu("main","","M","Maintenance Programs", "mnt","")
	CALL addMenu("main","","M","Order Entry", "oe","")
	CALL addMenu("main","","M","System Maintenance", "sys","")

	CALL addMenu("demo","main","T","Demo Programs", "","")
	CALL addMenu("demo","main","P","Widgets Demo", "../scripts/rundemo widgets","")
	CALL addMenu("demo","main","P","ipodTree Demo", "../scripts/rundemo ipodTree","")
	CALL addMenu("demo","main","P","picFlow Demo", "../scripts/rundemo picFlow","")

	CALL addMenu("sys","main","T","System Maintenance", "","")
	CALL addMenu("sys","main","F","User/Role Maintenance", "user_mnt.42r","")
	CALL addMenu("sys","main","F","Menu/Role Maintenance", "menu_mnt.42r","")

	CALL addMenu("enq","main","T","Enquiry Programs", "","")
	CALL addMenu("enq","main","F","Customer Enquiry", "cust_mnt.42r YYNNNN","")
	CALL addMenu("enq","main","F","Stock Enquiry", "dynMaint.42r stock stock_code YYNNNN","")

	CALL addMenu("mnt","main","T","Maintenance Programs", "","")
	CALL addMenu("mnt","main","F","Customer Maintenance", "cust_mnt.42r","")
	CALL addMenu("mnt","main","F","Stock Maintenance", "dynMaint.42r stock stock_code","")
	CALL addMenu("mnt","main","F","Stock Cat Maintenance", "dynMaint.42r stock_cat catid","")
	CALL addMenu("mnt","main","F","Supplier Maintenance", "dynMaint.42r supplier supp_code","")

	CALL addMenu("oe","main","T","Order Entry", "","")
	CALL addMenu("oe","main","F","Order Entry", "orderEntry.42r ","")
	CALL addMenu("oe","main","F","Web Order Entry", "webOE.42r ","")
	CALL addMenu("oe","main","M","Invoicing Reports", "oeprn","")
	CALL addMenu("oeprn","oe","T","Invoicing Reports", "","")
	CALL addMenu("oeprn","oe","F","Print Invoices", "printInvoices.42r 0 ordent.4rp","")
	CALL addMenu("oeprn","oe","F","Print Picking Notes", "printInvoices.42r picklist.4rp","")

	DISPLAY "Done."

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION mk_demo_account()
	DEFINE l_hash_type, l_login_pass, l_salt, l_pass_hash, l_email VARCHAR(128)

	LET l_email = "test@test.com"
	SELECT * FROM accounts WHERE email = l_email
	IF STATUS = 0 THEN RETURN END IF

	LET l_login_pass = "T3st.T3st"
	LET l_hash_type = lib_secure.glsec_getHashType()
	LET l_salt = lib_secure.glsec_genSalt(l_hash_type)
	LET l_pass_hash = lib_secure.glsec_genPasswordHash( l_login_pass, l_salt, l_hash_type )

	TRY
		INSERT INTO accounts VALUES(1,"Mr","Test","Testing","Tester",l_email,"A test account",0,1,"N",
			l_hash_type, l_login_pass, l_salt, l_pass_hash, TODAY+365)
		DISPLAY "Test Account Inserted: "||l_email||" / "||l_login_pass||" with "||l_hash_type||" hash."
	CATCH
		DISPLAY "Insert test account failed!\n",STATUS,":",SQLERRMESSAGE
	END TRY
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION addRole(l_type,l_name)
	DEFINE l_type CHAR(1),
		l_name     VARCHAR(30)

	IF m_dbtyp = "pgs" THEN
		INSERT INTO sys_roles VALUES(nextval('sys_roles_role_key_seq'),l_type,l_name,"Y")
	ELSE
		INSERT INTO sys_roles VALUES(m_rkey,l_type,l_name,"Y")
	END IF
	LET m_rkey = m_rkey + 1
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION addMenu(l_id,l_pid,l_type,l_text,l_item,l_passw)
	DEFINE l_id      VARCHAR(6),
		l_pid     VARCHAR(6),
		l_type    CHAR(1),
		l_text    VARCHAR(40),
		l_item    VARCHAR(80),
		l_passw   VARCHAR(8)

	IF m_dbtyp = "pgs" THEN
		INSERT INTO sys_menus VALUES(nextval('sys_menus_menu_key_seq'),l_id,l_pid,l_type,l_text,l_item,l_passw)
	ELSE
		INSERT INTO sys_menus VALUES(m_mkey,l_id,l_pid,l_type,l_text,l_item,l_passw)
	END IF
	LET m_mkey = m_mkey + 1
END FUNCTION