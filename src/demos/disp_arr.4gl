#+ Demo 2.40 Display Array Features.
#+
#+ 1) Table total line
#+ 2) find row by key press
#+ 3) find row by search - control-f
#+ 4) insert / append / update / delete row
#+ 5) IIF used for message.

IMPORT util -- used for rand function for testdata
IMPORT FGL gl_lib
&include "genero_lib.inc"
CONSTANT C_VER = "3.1"
CONSTANT C_PRGDESC = "Display Array Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"

DEFINE m_arr DYNAMIC ARRAY OF RECORD
  key INTEGER,
  desc STRING,
  pri DECIMAL(10, 2),
  qty SMALLINT,
  tot DECIMAL(10, 2),
  chkd STRING,
  seld STRING
END RECORD

MAIN

  CALL gl_lib.gl_setInfo(C_VER, NULL, NULL, C_PRGDESC, C_PRGDESC, C_PRGAUTH)
  CALL gl_lib.gl_init(arg_val(1), NULL, TRUE)
  CALL ui.Interface.setText(gl_progdesc)

  OPEN FORM f FROM "disp_arr"
  DISPLAY FORM f

  WHILE NOT int_flag
    CALL poparr()
    MENU "Choice" ATTRIBUTES(STYLE = "dialog", COMMENT = "Display Array Demo", IMAGE = "question")
      COMMAND "Multiple Row Select #1"
        CALL disp_arr1()
        LET int_flag = FALSE

      COMMAND "Multiple Row Select #2"
        CALL disp_arr2()
        LET int_flag = FALSE

      COMMAND "Quit"
        LET int_flag = TRUE
    END MENU

  END WHILE

END MAIN
-------------------------------------------------------------------------------
-- Multi Row Selection - Method 1
FUNCTION disp_arr1()
  DISPLAY ARRAY m_arr TO arr.* ATTRIBUTES(UNBUFFERED)
    BEFORE DISPLAY
      CALL DIALOG.setSelectionMode("arr", TRUE)
      CALL DIALOG.getForm().setElementHidden("formonly.chkd", TRUE)
      CALL DIALOG.getForm().setElementHidden("formonly.seld", FALSE)

    ON SELECTION CHANGE
      CALL totals(DIALOG, "SELC")

    ON ACTION tot
      CALL totals(DIALOG, "ACT ")

-- Popualtte or clear the array
    ON ACTION poparr
      CALL poparr()
    ON ACTION clrarr
      CALL m_arr.clear()
      MESSAGE "Rows:", m_arr.getLength()

-- Maintenance Triggers
    ON APPEND
      CALL editRow(FALSE)
    ON INSERT
      CALL editRow(FALSE)
    ON UPDATE
      CALL editRow(TRUE)
    ON DELETE
      IF gl_lib.gl_winQuestion(
                  "Confirm",
                  "Delete this row?\n" || m_arr[arr_curr()].desc,
                  "No",
                  "Yes|No",
                  "questions")
              = "No"
          THEN
        LET int_flag = TRUE
      END IF

-- Default actions to leave the statement
    ON ACTION close
      EXIT DISPLAY
    ON ACTION quit
      EXIT DISPLAY
  END DISPLAY
END FUNCTION
-------------------------------------------------------------------------------
-- Multi Row Selection - Method 2
FUNCTION disp_arr2()
  DISPLAY ARRAY m_arr TO arr.* ATTRIBUTES(UNBUFFERED, FOCUSONFIELD)
    BEFORE DISPLAY
      CALL DIALOG.getForm().setElementHidden("formonly.chkd", FALSE)
      CALL DIALOG.getForm().setElementHidden("formonly.seld", TRUE)
      --CALL DIALOG.setActionActive( "dialogtouched", TRUE )
      CALL totals(DIALOG, "BD ")

    BEFORE FIELD chkd
      IF m_arr[arr_curr()].chkd = "fa-check-square-o" THEN
        LET m_arr[arr_curr()].chkd = "fa-square-o"
      ELSE
        LET m_arr[arr_curr()].chkd = "fa-check-square-o"
      END IF
      CALL totals(DIALOG, "BF ")
      NEXT FIELD seld

    ON ACTION tot
      CALL totals(DIALOG, "ACT ")
      --ON ACTION DIALOGTOUCHED
      --	CALL totals( DIALOG, "DT  " )

-- Popualtte or clear the array
    ON ACTION poparr
      CALL poparr()
    ON ACTION clrarr
      CALL m_arr.clear()
      MESSAGE "Rows:", m_arr.getLength()

-- Maintenance Triggers
    ON APPEND
      CALL editRow(FALSE)
    ON INSERT
      CALL editRow(FALSE)
    ON UPDATE
      CALL editRow(TRUE)
    ON DELETE
      IF gl_lib.gl_winQuestion(
                  "Confirm",
                  "Delete this row?\n" || m_arr[arr_curr()].desc,
                  "No",
                  "Yes|No",
                  "questions")
              = "No"
          THEN
        LET int_flag = TRUE
      END IF

-- Default actions to leave the statement
    ON ACTION close
      EXIT DISPLAY
    ON ACTION quit
      EXIT DISPLAY

  END DISPLAY
END FUNCTION
-------------------------------------------------------------------------------
#+ Edit / Enter row details
#+
#+ @param l_edit True=Edit False=New
FUNCTION editRow(l_edit BOOLEAN)
  INPUT m_arr[arr_curr()].* FROM arr[scr_line()].* ATTRIBUTES(UNBUFFERED, WITHOUT DEFAULTS = l_edit)
    BEFORE INPUT
      IF NOT l_edit THEN
        LET m_arr[arr_curr()].key = m_arr.getLength()
        LET m_arr[arr_curr()].desc = "Row " || m_arr.getLength()
      END IF
    AFTER FIELD pri
      IF m_arr[arr_curr()].pri < 0.01 THEN
        ERROR "Price must be greater than zero!"
        NEXT FIELD pri
      END IF
      LET m_arr[arr_curr()].tot = (m_arr[arr_curr()].pri * m_arr[arr_curr()].qty)
    AFTER FIELD qty
      IF m_arr[arr_curr()].qty = 0 THEN
        ERROR "Quantity can not be zero!"
        NEXT FIELD qty
      END IF
      LET m_arr[arr_curr()].tot = (m_arr[arr_curr()].pri * m_arr[arr_curr()].qty)
  END INPUT
END FUNCTION
-------------------------------------------------------------------------------
#+ handle totals for selected rows.
#+
#+ @param d ui.Dialog the Dialog Object
#+ @param l_when Used for debug out
FUNCTION totals(d ui.Dialog, l_when STRING)
  DEFINE x, t SMALLINT
  DEFINE stot DECIMAL(10, 2)

  LET stot = 0
  LET t = 0
  FOR x = 1 TO m_arr.getLength()
    DISPLAY x, " isRowSelected:", d.isRowSelected("arr", x), ":", m_arr[x].chkd
    IF d.isRowSelected("arr", x)
            --	OR d.getCurrentRow("arr") = x
            OR m_arr[x].chkd = "fa-check-square-o"
        THEN
      LET stot = stot + m_arr[x].tot
      LET m_arr[x].seld = "fa-check-square-o"
      LET t = t + 1
    ELSE
      LET m_arr[x].seld = "fa-square-o"
    END IF
  END FOR
  DISPLAY BY NAME stot, t
  DISPLAY l_when,
      " Curr Row:",
      d.getCurrentRow("arr"),
      " Selected:",
      t,
      " isRowSelected:",
      d.isRowSelected("arr", x)
END FUNCTION
-------------------------------------------------------------------------------
#+ Populate the array with test data
FUNCTION poparr()
  DEFINE l_chr CHAR(1)
  DEFINE x SMALLINT
  CALL util.math.srand()
  CALL m_arr.clear()
  FOR x = 1 TO 12
    LET l_chr = ASCII (65 + util.math.rand(26))
    LET m_arr[x].desc = l_chr || downshift(l_chr) || " test data " || l_chr
    LET m_arr[x].key = m_arr.getLength()
    LET m_arr[x].qty = util.math.rand(10) + 1
    LET m_arr[x].pri = util.math.rand(10) + 1 + (util.math.rand(99) / 100)
    LET m_arr[x].tot = (m_arr[x].pri * m_arr[x].qty)
    LET m_arr[x].chkd = "fa-square-o"
    LET m_arr[x].seld = "fa-square-o"
  END FOR
  FOR x = 1 TO m_arr.getLength()
    DISPLAY m_arr[x].*
  END FOR
  MESSAGE "Rows:", m_arr.getLength()
END FUNCTION
-------------------------------------------------------------------------------
