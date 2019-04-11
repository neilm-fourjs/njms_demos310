-- Customer Maintenance

IMPORT FGL gl_lib
IMPORT FGL gl_db
IMPORT FGL app_lib
&include "schema.inc"
&include "genero_lib.inc"
&include "app.inc"
CONSTANT C_PRGDESC = "Customer Maintenance Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"
&define RECNAME customer.*
&define RECNAME2 addresses.*
&define TABNAMEQ "customer"
&define TABNAME customer
&define TABNAME2Q "addresses"
&define TABNAME2 addresses
&define KEYFLDQ "customer_code"
&define KEYFLD customer_code
&define LABFLD customer_name
&define LABFLDQ "customer_name"
&define RECKEY m_rec.KEYFLD
&define KEYFLD2Q "rec_key"
&define JOIN1 customer.del_addr = addresses.rec_key
&define JOIN1Q "customer.del_addr = addresses.rec_key"
&define JOIN2_M inv_addr
&define JOIN2_D rec_key

DEFINE m_rec RECORD LIKE RECNAME
DEFINE m_rec_o RECORD LIKE RECNAME
DEFINE m_rec2 RECORD LIKE RECNAME2
DEFINE m_rec2_o RECORD LIKE RECNAME2
DEFINE m_rec3 RECORD LIKE RECNAME2
DEFINE m_rec3_o RECORD LIKE RECNAME2
DEFINE m_recs DYNAMIC ARRAY OF RECORD
  key LIKE TABNAME.KEYFLD,
  desc LIKE TABNAME.LABFLD
END RECORD
DEFINE m_func CHAR
DEFINE m_row INTEGER
DEFINE m_wher STRING
DEFINE m_user_key LIKE sys_users.user_key
DEFINE m_allowedActions CHAR(6) --Y/N for Find / List / Update / Insert / Delete / Sample
-- NNYNNN = Only update allowed.
MAIN
  LET gl_toolbar = "dynmaint"
  LET gl_topMenu = "dynmaint"
  CALL gl_lib.gl_setInfo(C_VER, C_APP_SPLASH, C_APP_ICON, NULL, C_PRGDESC, C_PRGAUTH)
  CALL gl_lib.gl_init(arg_val(1), "default", TRUE)
  WHENEVER ANY ERROR CALL gl_lib.gl_error
  LET m_user_key = arg_val(2)
  LET m_allowedActions = arg_val(3)
  LET m_allowedActions = (m_allowedActions CLIPPED), "YYYYY"

  CALL gl_db.gldb_connect(NULL)

  OPEN FORM frm FROM "cust_mnt"
  DISPLAY FORM frm
  CALL ui.Interface.setText(gl_progdesc)

  TRY
    DECLARE fetch_row CURSOR FOR SELECT * FROM TABNAME, TABNAME2 WHERE KEYFLD = ? AND JOIN1
  CATCH
    EXIT PROGRAM
  END TRY

  DECLARE fetch_row2 CURSOR FOR SELECT * FROM TABNAME2 WHERE JOIN2_D = ?

  MENU
    BEFORE MENU
      CALL app_lib.setActions(m_row, m_recs.getLength(), m_allowedActions)

    ON ACTION quit
      EXIT MENU
    ON ACTION close
      EXIT MENU
    ON ACTION find
      LET m_func = "E"
      IF NOT query() THEN
        CONTINUE MENU
      END IF
      IF m_recs.getLength() > 0 THEN
        CALL showRow(1)
      END IF
      CALL app_lib.setActions(m_row, m_recs.getLength(), m_allowedActions)

    ON ACTION insert
      LET m_func = "N"
      IF NOT inp(TRUE) THEN
        MESSAGE % "Cancelled"
      END IF

    ON ACTION update
      LET m_func = "U"
      IF m_rec.KEYFLD IS NULL THEN
        IF NOT query() THEN
          CONTINUE MENU
        END IF
      END IF
      IF NOT inp(FALSE) THEN
        MESSAGE % "Cancelled"
      END IF

    ON ACTION delete
      LET m_func = "D"
      IF m_rec.KEYFLD IS NULL THEN
        IF NOT query() THEN
          CONTINUE MENU
        END IF
      END IF
      IF delete() THEN
        MESSAGE % "Row deleted"
      END IF

{	 	ON ACTION list
			LET RECKEY = app_lib.fldChoose( TABNAMEQ, base.typeInfo.create( m_rec ) )
			DISPLAY "key:",RECKEY
			LET m_wher = KEYFLDQ||"='"||RECKEY||"'"
			IF getRec() THEN CALL showRow(1) END IF}

    ON ACTION report
      CALL rpt1()

    ON ACTION sample
      -- not done yet.

    ON ACTION nextrow
      CALL showRow(m_row + 1)
      CALL app_lib.setActions(m_row, m_recs.getLength(), m_allowedActions)
    ON ACTION prevrow
      CALL showRow(m_row - 1)
      CALL app_lib.setActions(m_row, m_recs.getLength(), m_allowedActions)
    ON ACTION firstrow
      CALL showRow(1)
      CALL app_lib.setActions(m_row, m_recs.getLength(), m_allowedActions)
    ON ACTION lastrow
      CALL showRow(m_recs.getLength())
      CALL app_lib.setActions(m_row, m_recs.getLength(), m_allowedActions)
    GL_ABOUT
  END MENU
  CALL gl_lib.gl_exitProgram(0, % "Program Finished")
END MAIN
--------------------------------------------------------------------------------
FUNCTION query() RETURNS BOOLEAN
  LET int_flag = FALSE
  CONSTRUCT BY NAME m_wher ON RECNAME, RECNAME2
  IF int_flag THEN
    LET int_flag = FALSE
    RETURN FALSE
  END IF
  RETURN getRec()
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getRec() RETURNS BOOLEAN
  DEFINE stmt STRING
  LET stmt =
      "SELECT "
          || KEYFLDQ
          || ","
          || LABFLDQ
          || " FROM "
          || TABNAMEQ
          || ","
          || TABNAME2Q
          || " WHERE "
          || m_wher
          || " AND "
          || JOIN1Q
  IF stmt IS NULL THEN
    RETURN FALSE
  END IF
  DISPLAY stmt
  PREPARE q_pre FROM stmt
  DECLARE q_cur CURSOR FOR q_pre
  CALL m_recs.clear()
  FOREACH q_cur INTO m_recs[m_recs.getLength() + 1].*
  END FOREACH
  CALL m_recs.deleteElement(m_recs.getLength())
  IF m_recs.getLength() > 0 THEN
    MESSAGE SFMT(% "%1 Rows found.", m_recs.getLength())
  ELSE
    ERROR % "No rows found!"
    LET m_row = 0
    RETURN FALSE
  END IF
  LET m_row = 1
  RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION showRow(x INT)

  IF x > m_recs.getLength() THEN
    RETURN
  END IF
  IF x < 1 THEN
    RETURN
  END IF

  INITIALIZE m_rec.* TO NULL
  INITIALIZE m_rec2.* TO NULL
  INITIALIZE m_rec3.* TO NULL

  OPEN fetch_row USING m_recs[x].key
  FETCH fetch_row INTO m_rec.*, m_rec2.*
  CLOSE fetch_row
  DISPLAY BY NAME m_rec.*, m_rec2.*

  OPEN fetch_row2 USING m_rec.JOIN2_M
  FETCH fetch_row2 INTO m_rec3.*
  CLOSE fetch_row2
  DISPLAY m_rec3.* TO ff.*

  LET m_rec_o.* = m_rec.*
  LET m_rec2_o.* = m_rec2.*
  LET m_rec3_o.* = m_rec3.*
  LET m_row = x
END FUNCTION
--------------------------------------------------------------------------------
-- @param ins Insert True/False
FUNCTION inp(l_ins BOOLEAN) RETURNS BOOLEAN
  DEFINE l_ret BOOLEAN

  OPTIONS INPUT WRAP
  IF l_ins THEN
    INITIALIZE m_rec.* TO NULL
    INITIALIZE m_rec2.* TO NULL
    LET m_rec2.rec_key = 0 -- serial
    INITIALIZE m_rec3.* TO NULL
    LET m_rec3.rec_key = 0 -- serial
  END IF
  LET int_flag = FALSE
  DIALOG ATTRIBUTES(UNBUFFERED)
    INPUT BY NAME m_rec.*, m_rec2.* ATTRIBUTES(WITHOUT DEFAULTS) --=NOT ins)
      BEFORE INPUT
        IF NOT l_ins THEN
          CALL DIALOG.setFieldActive(TABNAMEQ || "." || KEYFLDQ, FALSE)
          MESSAGE % "Disable:", TABNAMEQ || "." || KEYFLDQ
          CALL DIALOG.setActionActive("sameaddr", FALSE)
        END IF
      ON ACTION sameaddr
        LET m_rec3.* = m_rec2.*
        LET m_rec3.rec_key = NULL
        CALL DIALOG.setFieldActive("ff.line1", FALSE)
        CALL DIALOG.setFieldActive("ff.line2", FALSE)
        CALL DIALOG.setFieldActive("ff.line3", FALSE)
        CALL DIALOG.setFieldActive("ff.line4", FALSE)
        CALL DIALOG.setFieldActive("ff.line5", FALSE)
        CALL DIALOG.setFieldActive("ff.postal_code", FALSE)
        CALL DIALOG.setFieldActive("ff.country_code", FALSE)
    END INPUT
    INPUT m_rec3.* FROM ff.* ATTRIBUTES(WITHOUT DEFAULTS)
      ON ACTION sameaddr
        LET m_rec3.* = m_rec2.*
        LET m_rec3.rec_key = NULL
        NEXT FIELD customer_name
    END INPUT
    ON ACTION accept
      EXIT DIALOG
    ON ACTION cancel
      LET int_flag = TRUE
      EXIT DIALOG
  END DIALOG

  LET l_ret = FALSE

  IF NOT int_flag THEN
    IF l_ins THEN
      LET l_ret = insert(FALSE)
    ELSE
      LET l_ret = update()
    END IF
  END IF
  RETURN l_ret

END FUNCTION
--------------------------------------------------------------------------------
#+ Confirm and delete the current row
FUNCTION delete() RETURNS BOOLEAN
  DEFINE l_stmt VARCHAR(100)

  IF NOT app_lib.checkUserRoles(m_user_key, "Delete", TRUE) THEN
    RETURN FALSE
  END IF

  LET l_stmt = "SELECT * FROM " || TABNAMEQ || " WHERE " || KEYFLDQ || " = '" || m_rec.KEYFLD || "'"
  LET m_rec_o.KEYFLD = m_rec.KEYFLD
  IF NOT gl_db.gldb_checkRec(TRUE, m_rec.KEYFLD, l_stmt) THEN
    RETURN FALSE
  END IF

  IF gl_lib.gl_winQuestion(
              % "Confirm",
              % "Are you sure you want to delete this customer?",
              "No",
              "Yes|No",
              "question")
          = "Yes"
      THEN
    LET l_stmt = "DELETE FROM " || TABNAMEQ || " WHERE " || KEYFLDQ || " = ?"
    PREPARE pre_del FROM l_stmt
    EXECUTE pre_del USING RECKEY
    MESSAGE % "Row deleted!"
    RETURN gl_db.gldb_sqlStatus(
        __LINE__,
        __FILE__,
        "DELETE FROM " || TABNAMEQ || " WHERE " || KEYFLDQ || " = '" || RECKEY || "'")
  END IF
  RETURN FALSE
END FUNCTION
--------------------------------------------------------------------------------
#+ Update a row in the database table.
#+
#+ @return True / False - fails / works.
FUNCTION update() RETURNS BOOLEAN
  DEFINE l_stmt VARCHAR(20000)
  DEFINE l_wher VARCHAR(100)

  IF m_rec_o.del_addr = 0 OR m_rec_o.inv_addr = 0 THEN
    LET m_rec2.rec_key = m_rec_o.del_addr
    LET m_rec3.rec_key = m_rec_o.inv_addr
    LET m_rec2_o.rec_key = m_rec_o.del_addr
    LET m_rec3_o.rec_key = m_rec_o.inv_addr
    IF insert(TRUE) THEN
    END IF
  END IF

  IF m_rec.* = m_rec_o.* AND m_rec2.* = m_rec2_o.* AND m_rec3.* = m_rec3_o.* THEN
--		DISPLAY "Nothing changed!"
    ERROR % "Nothing changed!"
    RETURN TRUE
  END IF

  LET l_stmt = "SELECT * FROM " || TABNAMEQ || " WHERE " || KEYFLDQ || " = '" || m_rec.KEYFLD || "'"
  LET m_rec_o.KEYFLD = m_rec.KEYFLD
  IF NOT gl_db.gldb_checkRec(TRUE, m_rec.KEYFLD, l_stmt) THEN
    RETURN FALSE
  END IF

  IF gl_lib.gl_winQuestion(% "Confirm", % "Update this customer?", "No", "Yes|No", "question")
          = "Yes"
      THEN
    RETURN FALSE
  END IF

  IF m_rec.* != m_rec_o.* THEN
    LET l_wher = KEYFLDQ || " = ?"
    LET l_stmt =
        gl_db.gldb_genUpdate(
            TABNAMEQ, l_wher, base.typeInfo.create(m_rec), base.typeInfo.create(m_rec_o), 0, TRUE)
    --	DISPLAY "Update:",l_stmt CLIPPED
    TRY
      PREPARE pre_upd FROM l_stmt CLIPPED
    CATCH
      RETURN gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt)
    END TRY
    TRY
      EXECUTE pre_upd USING m_rec_o.KEYFLD
      LET m_recs[m_row].key = m_rec.KEYFLD
      MESSAGE SFMT(% "Row %1 updated.", TABNAMEQ)
    CATCH
      RETURN gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt)
    END TRY
  END IF

  IF m_rec2.* != m_rec2_o.* THEN
    LET l_wher = KEYFLD2Q || " = ?"
    LET l_stmt =
        gl_db.gldb_genUpdate(
            TABNAME2Q,
            l_wher,
            base.typeInfo.create(m_rec2),
            base.typeInfo.create(m_rec2_o),
            0,
            TRUE)
    TRY
      PREPARE pre_upd2 FROM l_stmt CLIPPED
    CATCH
      RETURN gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt)
    END TRY
    TRY
      EXECUTE pre_upd2 USING m_rec2_o.JOIN2_D
      MESSAGE SFMT(% "Row %1 updated.", TABNAMEQ)
    CATCH
      RETURN gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt)
    END TRY
  END IF

  IF m_rec3.* = m_rec3_o.* THEN
    LET l_wher = KEYFLD2Q || " = ?"
    LET l_stmt =
        gl_db.gldb_genUpdate(
            TABNAME2Q,
            l_wher,
            base.typeInfo.create(m_rec3),
            base.typeInfo.create(m_rec3_o),
            0,
            TRUE)
    TRY
      PREPARE pre_upd3 FROM l_stmt CLIPPED
    CATCH
      RETURN gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt)
    END TRY
    TRY
      EXECUTE pre_upd3 USING m_rec3_o.JOIN2_D
      MESSAGE "Row " || TABNAME2Q || " updated!"
    CATCH
      RETURN gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt)
    END TRY
  END IF
  RETURN FALSE

END FUNCTION
--------------------------------------------------------------------------------
#+ Insert a new row into the database table.
#+
#+ @return True / False - fails / works.
FUNCTION insert(l_ad_only BOOLEAN) RETURNS BOOLEAN
  DEFINE l_stmt VARCHAR(4000)

  IF NOT l_ad_only THEN
    LET l_stmt =
        "SELECT * FROM " || TABNAMEQ || " WHERE " || KEYFLDQ || " = '" || m_rec.KEYFLD || "'"
    LET m_rec_o.KEYFLD = m_rec.KEYFLD
    IF NOT gl_db.gldb_checkRec(FALSE, m_rec.KEYFLD, l_stmt) THEN
      RETURN FALSE
    END IF
    IF gl_lib.gl_winQuestion(% "Confirm", % "Insert new customer?", "No", "Yes|No", "question")
            = "No"
        THEN
      RETURN FALSE
    END IF
  END IF

  BEGIN WORK
  LET l_stmt = gl_db.gldb_genInsert(TABNAME2Q, base.typeInfo.create(m_rec2), TRUE)
  TRY
    PREPARE pre_ins2 FROM l_stmt
  CATCH
    IF NOT gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt) THEN
      ROLLBACK WORK
      RETURN FALSE
    END IF
  END TRY
  IF m_rec3.rec_key IS NOT NULL THEN
    LET l_stmt = gl_db.gldb_genInsert(TABNAME2Q, base.typeInfo.create(m_rec3), TRUE)
    TRY
      PREPARE pre_ins3 FROM l_stmt
    CATCH
      IF NOT gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt) THEN
        ROLLBACK WORK
        RETURN FALSE
      END IF
    END TRY
  END IF

  TRY
    EXECUTE pre_ins2
    LET m_rec2.rec_key = SQLCA.sqlerrd[2]
    MESSAGE % "Row Inserted!"
  CATCH
    IF NOT gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt) THEN
      ROLLBACK WORK
      RETURN FALSE
    END IF
  END TRY
  IF m_rec3.rec_key IS NOT NULL THEN
    TRY
      EXECUTE pre_ins3
      LET m_rec3.rec_key = SQLCA.sqlerrd[2]
      MESSAGE % "Row Inserted!"
    CATCH
      IF NOT gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt) THEN
        ROLLBACK WORK
        RETURN FALSE
      END IF
    END TRY
  ELSE
    LET m_rec3.rec_key = m_rec2.rec_key -- default to del_addr
  END IF

  LET m_rec.del_addr = m_rec2.rec_key
  LET m_rec.inv_addr = m_rec3.rec_key

  IF l_ad_only THEN
    --UPDATE customer SET (del_addr, inv_addr )= (m_rec2.rec_key,m_rec3.rec_key)
    --	WHERE customer.customer_code = m_rec.customer_code
  ELSE
    LET l_stmt = gl_db.gldb_genInsert(TABNAMEQ, base.typeInfo.create(m_rec), TRUE)
    TRY
      PREPARE pre_ins FROM l_stmt
    CATCH
      IF NOT gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt) THEN
        ROLLBACK WORK
        RETURN FALSE
      END IF
    END TRY
    TRY
      EXECUTE pre_ins
      MESSAGE % "Row Inserted!"
    CATCH
      IF NOT gl_db.gldb_sqlStatus(__LINE__, __FILE__, l_stmt) THEN
        ROLLBACK WORK
        RETURN FALSE
      END IF
    END TRY
  END IF

  COMMIT WORK
  RETURN TRUE
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION rpt1()
  DEFINE l_rec RECORD LIKE RECNAME
  DEFINE l_rec2 RECORD LIKE RECNAME2
  DEFINE l_row INTEGER

  IF m_wher IS NULL OR m_wher.getLength() < 1 THEN
    LET m_wher = "1=1"
  END IF
  PREPARE r_pre
      FROM "SELECT * FROM "
          || TABNAMEQ
          || ","
          || TABNAME2Q
          || " WHERE "
          || m_wher
          || " AND "
          || JOIN1Q
          || " ORDER BY "
          || KEYFLDQ
  DECLARE r_cur CURSOR FOR r_pre
  LET l_row = 0
  FOREACH r_cur INTO l_rec.*, l_rec2.*
    IF l_row = 0 THEN
      START REPORT trad_rpt TO SCREEN
    END IF
    LET l_row = l_row + 1
    OUTPUT TO REPORT trad_rpt(l_row, l_rec.*, l_rec2.*)
  END FOREACH
  IF l_row > 0 THEN
    FINISH REPORT trad_rpt
  END IF
END FUNCTION
--------------------------------------------------------------------------------
REPORT trad_rpt(l_row, l_rec, l_rec2)
  DEFINE
    l_row INTEGER,
    l_rec RECORD LIKE RECNAME,
    l_rec2 RECORD LIKE RECNAME2
  DEFINE l_print_date DATE
  DEFINE l_rpt_user, l_head1, l_head2 STRING
  DEFINE x SMALLINT

  ORDER EXTERNAL BY l_rec.customer_code

  FORMAT
    FIRST PAGE HEADER
      LET l_rpt_user = gl_userName
      LET l_print_date = TODAY
      LET l_head2 = SFMT(% "Printed: %! By:%2", l_print_date, l_rpt_user.trim())
      LET x = 132 - length(l_head2)
      LET l_head1 = % "Customer Listing"
      PRINT l_head1, COLUMN x, l_head2
      PRINT "--------------------------------------------";
      PRINT "--------------------------------------------";
      PRINT "-------------------------------------------"

      PRINT "Code     Name";
      PRINT COLUMN 40, "Contact";
      PRINT COLUMN 72, "Address";
      PRINT COLUMN 114, "Post Code"

    ON EVERY ROW
      PRINT l_rec.customer_code, " ";
      PRINT l_rec.customer_name, " ";
      PRINT COLUMN 40, l_rec.contact_name, " ";
      PRINT COLUMN 72, l_rec2.line1, " ";
      PRINT COLUMN 114, l_rec2.postal_code
END REPORT
