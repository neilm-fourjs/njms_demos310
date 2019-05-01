-- This program is for basic GBC theme views
-- By: Neil J Martin ( neilm@4js.com )

IMPORT os
IMPORT util
IMPORT FGL g2_lib
IMPORT FGL g2_appInfo

CONSTANT C_PRGDESC = "GBC Themes"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_PRGICON = "njm_demo_icon"
CONSTANT C_PRGVER = "3.2"

DEFINE rec DYNAMIC ARRAY OF RECORD
  name STRING,
  title STRING,
  description STRING,
  type STRING,
  contents DYNAMIC ARRAY OF RECORD
    name STRING,
    title STRING,
    description STRING,
    type STRING,
    value STRING,
    defaultValue STRING,
    contents DYNAMIC ARRAY OF RECORD
      name STRING,
      title STRING,
      type STRING,
      defaultValue STRING,
      aliases DYNAMIC ARRAY OF STRING
    END RECORD
  END RECORD
END RECORD
MAIN
  DEFINE l_appInfo g2_appInfo.appInfo

  CALL l_appInfo.progInfo(C_PRGDESC, C_PRGAUTH, C_PRGVER, C_PRGICON)
  CALL g2_lib.g2_init(ARG_VAL(1), "default")
  CALL ui.Interface.setText(C_PRGDESC)

  OPEN FORM f FROM "gbc_theme"
  DISPLAY FORM f

--	IF NOT open_main_json( os.path.join( fgl_getEnv("GBCPROJDIR"), "src/theme/definitions/main-definition.json" ) ) THEN
  IF NOT open_main_json("../etc/main-definition.json") THEN
    EXIT PROGRAM
  END IF
END MAIN
--------------------------------------------------------------------------------
FUNCTION open_main_json(l_jsonFile STRING) RETURNS BOOLEAN
  DEFINE c base.Channel
  DEFINE l_jsonData STRING
  DEFINE x, y, z SMALLINT

  IF NOT os.path.exists(l_jsonFile) THEN
    CALL g2_lib.g2_winMessage("Error", SFMT("%1 doesn't exist!", l_jsonFile), "exclamation")
    RETURN FALSE
  END IF

  DISPLAY "Processing ", l_jsonFile
  LET c = base.Channel.create()
  CALL c.openFile(l_jsonFile, "r")
  WHILE NOT c.isEof()
    LET l_jsonData = l_jsonData.append(c.readLine() || "\n")
  END WHILE
  CALL c.close()
  DISPLAY l_jsonData
  CALL util.JSON.parse(l_jsonData, rec)

  FOR x = 1 TO rec.getLength()
    DISPLAY rec[x].title
    FOR y = 1 TO rec[x].contents.getLength()
      IF rec[x].contents[y].value IS NULL THEN
        LET rec[x].contents[y].value = rec[x].contents[y].defaultValue
      END IF
      DISPLAY "	", rec[x].contents[y].title, " Value:", rec[x].contents[y].value
      FOR z = 1 TO rec[x].contents[y].contents.getLength()
        DISPLAY "		",
            rec[x].contents[y].contents[z].name,
            " = ",
            rec[x].contents[y].contents[z].defaultValue
      END FOR
    END FOR
  END FOR

  RETURN TRUE
END FUNCTION
