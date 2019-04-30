-- This program is for testing basic GBC UI look-n-feel customizations.
-- By: Neil J Martin ( neilm@4js.com )

IMPORT os
IMPORT FGL g2_lib
IMPORT FGL g2_about
IMPORT FGL g2_appInfo

CONSTANT C_PRGDESC = "Material Design Test"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_PRGVER = "3.2"
CONSTANT C_PRGICON = "njm_demo_icon"
CONSTANT C_IMG = "smiley"

CONSTANT PG_MAX = 1000

DEFINE m_forms DYNAMIC ARRAY OF STRING

MAIN
  DEFINE l_rec RECORD
    fld1 CHAR(10),
    fld2 DATE,
    fld3 STRING,
    fld4 STRING,
    fld5 STRING,
    fld6 STRING,
    fld7 STRING,
    fld8 STRING,
    okay BOOLEAN
  END RECORD
  DEFINE l_arr DYNAMIC ARRAY OF RECORD
    col1 STRING,
    col2 SMALLINT,
    img STRING
  END RECORD
  DEFINE l_listview DYNAMIC ARRAY OF RECORD
    col1 STRING,
    col2 STRING,
    img STRING
  END RECORD
  DEFINE x SMALLINT
  DEFINE l_appInfo g2_appInfo.appInfo

  CALL l_appInfo.progInfo(C_PRGDESC, C_PRGAUTH, C_PRGVER, C_PRGICON)
  CALL g2_lib.g2_init(ARG_VAL(1), "default")

  FOR X = 1 TO 15
    LET l_arr[x].col1 = "Row " || x
    LET l_arr[x].col2 = x
    LET l_arr[x].img = C_IMG
    LET l_listView[x].col1 = "This is row " || x
    LET l_listView[x].col2 = "this is a like an information line"
    LET l_listView[x].img = C_IMG
  END FOR
  LET l_rec.fld1 = "Active"
  LET l_rec.fld2 = TODAY
  LET l_rec.fld3 = "Red"
  LET l_rec.fld4 = "Inactive"
  LET l_rec.fld5 = "Active"
  LET l_rec.fld6 = "Inactive"
  LET l_rec.fld7 = "Active"
  LET l_rec.fld8 = "Inactive"

  OPEN FORM f FROM "matDesTest"
  DISPLAY FORM f

  DISPLAY fgl_getEnv("FGLIMAGEPATH") TO imgpath
  DISPLAY getAUIAttrVal("StyleList", "fileName") TO stylefile

  DIALOG ATTRIBUTE(UNBUFFERED)
    INPUT BY NAME l_rec.* ATTRIBUTES(WITHOUT DEFAULTS)
    END INPUT
    DISPLAY ARRAY l_arr TO arr1.*
    END DISPLAY
    DISPLAY ARRAY l_listView TO arr2.*
      BEFORE ROW
        DISPLAY SFMT("On row %1 of %2", DIALOG.getCurrentRow("arr2"), l_listView.getLength())
            TO tab2info
    END DISPLAY
    DISPLAY ARRAY l_listView TO arr3.*
      BEFORE ROW
        DISPLAY SFMT("On row %1 of %2", DIALOG.getCurrentRow("arr3"), l_listView.getLength())
            TO tab3info
    END DISPLAY
    ON ACTION msg
      MESSAGE "Hello Message"
    ON ACTION err
      ERROR "Error Message"
    ON ACTION win
      CALL win()
    ON ACTION arr2
      CALL DIALOG.nextField("lvcol1")
    ON ACTION arr3
      CALL DIALOG.nextField("a3col1")
    ON ACTION wintitle
      CALL fgl_setTitle("My Window Title")
    ON ACTION dyntext
      CALL gbc_replaceHTML("dyntext", "Dynamic Text:" || CURRENT)
    ON ACTION darklogo
      CALL gbc_replaceHTML("logocell", "<img src='./resources/img/logo_dark.png'/>")
    ON ACTION lightlogo
      CALL gbc_replaceHTML("logocell", "<img src='./resources/img/logo_light.png'/>")
    ON ACTION uitext
      CALL ui.Interface.setText("My UI Text")
    ON ACTION pg
      CALL pg(DIALOG.getForm(), 0)
    ON ACTION pg50
      CALL pg(DIALOG.getForm(), (PG_MAX / 2))
    ON ACTION showform
      CALL showForm()
    ON ACTION inactive
      CALL dummy()
    ON ACTION about
      CALL g2_about.g2_about(l_appInfo)
    ON ACTION close
      EXIT DIALOG
    ON ACTION quit
      EXIT DIALOG
    BEFORE DIALOG
      CALL pg(DIALOG.getForm(), (PG_MAX / 2))
      IF ui.Interface.getFrontEndName() != "GBC" THEN
        CALL DIALOG.setActionActive("darklogo", FALSE)
        CALL DIALOG.setActionActive("lightlogo", FALSE)
        CALL DIALOG.setActionActive("dyntext", FALSE)
      END IF
  END DIALOG
END MAIN
--------------------------------------------------------------------------------
-- Function just to cause everything to go inactive
FUNCTION dummy()
  MENU "dummy"
    BEFORE MENU
      CALL DIALOG.getForm().setElementText("inactive", "Active")
      CALL DIALOG.getForm().setElementImage("inactive", "fa-eye")
    ON ACTION inactive
      CALL DIALOG.getForm().setElementText("inactive", "Inactive")
      CALL DIALOG.getForm().setElementImage("inactive", "fa-eye-slash")
      EXIT MENU
  END MENU
END FUNCTION
--------------------------------------------------------------------------------
-- ProgressBar tests
FUNCTION pg(l_f ui.Form, l_just_set INTEGER)
  DEFINE x SMALLINT
  DEFINE l_dn om.DomNode
  LET l_dn = l_f.findNode("FormField", "formonly.pg")
  LET l_dn = l_dn.getFirstChild()
  CALL l_dn.setAttribute("valueMax", PG_MAX)
  IF l_just_set > 0 THEN
    DISPLAY l_just_set TO pg
    CALL ui.Interface.refresh()
  ELSE
    FOR x = 1 TO PG_MAX
      DISPLAY x TO pg
      CALL ui.Interface.refresh()
    END FOR
  END IF
END FUNCTION
--------------------------------------------------------------------------------
-- GBC ONLY - Dynamically replace HTML code
FUNCTION gbc_replaceHTML(l_obj STRING, l_txt STRING)
  DEFINE l_ret STRING
  IF ui.interface.getFrontEndName() = "GBC" THEN
    CALL ui.Interface.frontCall("mymodule", "replace_html", [l_obj, l_txt], l_ret)
  ELSE
    CALL g2_winMessage("Error", "GBC Test only!", "exclamation")
  END IF
  DISPLAY "l_ret:", l_ret
END FUNCTION
--------------------------------------------------------------------------------
-- Show a list .42f files in a Window and allow them to be viewed
FUNCTION showForm()
  DEFINE l_path, l_file STRING
  DEFINE l_handle INTEGER
  IF m_forms.getLength() = 0 THEN
    LET l_path = os.Path.pwd()
    CALL os.Path.dirSort("name", 1)
    LET l_handle = os.Path.dirOpen(l_path)
    WHILE l_handle > 0
      LET l_file = os.Path.dirNext(l_handle)
      IF l_file IS NULL THEN
        EXIT WHILE
      END IF
      IF os.path.extension(l_file) = "42f" THEN
        LET m_forms[m_forms.getLength() + 1] = l_file
      END IF
    END WHILE
    CALL os.Path.dirClose(l_handle)
  END IF
  OPEN WINDOW matDesTest_forms WITH FORM "matDesTest_forms"
  DISPLAY ARRAY m_forms TO arr.*
    ON ACTION accept
      CALL showForm2(m_forms[arr_curr()])
    ON ACTION win
      CALL win()
  END DISPLAY
  CLOSE WINDOW matDesTest_forms
END FUNCTION
--------------------------------------------------------------------------------
-- Open a window with the pass form name
FUNCTION showForm2(l_formName STRING)
  OPEN WINDOW aform WITH FORM l_formName
  MENU
    ON ACTION close
      EXIT MENU
    ON ACTION cancel
      EXIT MENU
    ON ACTION quit
      EXIT MENU
  END MENU
  CLOSE WINDOW aform
END FUNCTION
--------------------------------------------------------------------------------
-- A simple modal window
FUNCTION win()
  OPEN WINDOW win WITH FORM "matDesTest_modal"
  MENU
    ON ACTION close
      EXIT MENU
    ON ACTION cancel
      EXIT MENU
  END MENU
  CLOSE WINDOW win
END FUNCTION
--------------------------------------------------------------------------------
-- A value of aui node
FUNCTION getAUIAttrVal(l_nodeName STRING, l_attName STRING) RETURNS STRING
  DEFINE l_ret STRING
  DEFINE l_nl om.NodeList
  LET l_nl = ui.Interface.getRootNode().selectByTagName(l_nodeName)
  IF l_nl.getLength() = 0 THEN
    RETURN NULL
  END IF
  LET l_ret = l_nl.item(1).getAttribute(l_attName)
  RETURN l_ret
END FUNCTION
