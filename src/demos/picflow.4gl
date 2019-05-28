IMPORT os

IMPORT FGL g2_lib
IMPORT FGL g2_about
IMPORT FGL g2_appInfo

CONSTANT C_PRGVER = "3.1"
CONSTANT C_PRGDESC = "picFlow Demo"
CONSTANT C_PRGAUTH = "Neil J.Martin"
CONSTANT C_PRGICON = "logo_dark"

DEFINE max_images SMALLINT

DEFINE m_pics DYNAMIC ARRAY OF RECORD
  pic STRING
END RECORD
DEFINE m_pics_info DYNAMIC ARRAY OF RECORD
  pth STRING,
  nam STRING,
  mod STRING,
  siz STRING,
  typ STRING,
  rwx STRING
END RECORD
DEFINE d, c INTEGER
DEFINE m_base, path, html_start, html_end STRING
DEFINE m_appInfo g2_appInfo.appInfo
MAIN
  DEFINE frm ui.Form
  DEFINE n om.domNode

  CALL m_appInfo.progInfo(C_PRGDESC, C_PRGAUTH, C_PRGVER, C_PRGICON)
  CALL g2_lib.g2_init(ARG_VAL(1), "picflow")


  DISPLAY "FGLSERVER:", fgl_getenv("FGLSERVER")
  DISPLAY "FGLIMAGEPATH:", fgl_getenv("FGLIMAGEPATH")
  DISPLAY "PWD:", os.path.pwd()

  OPEN FORM picf FROM "picflow"
  DISPLAY FORM picf

  LET max_images = 50

  LET m_base = arg_val(3)
  DISPLAY "Base:" || m_base

  CALL getImages("svg", "png")

  DISPLAY "Image Found:", m_pics.getLength()

  LET html_start = "<P ALIGN=\"CENTER\">"
  LET html_end = "<\P>"

  LET c = 1
  DIALOG ATTRIBUTE(UNBUFFERED)
    DISPLAY ARRAY m_pics TO arr.*
      BEFORE ROW
        LET c = arr_curr()
        CALL refresh(c)
--		ON IDLE 5
--			LET c = c + 1
--			IF c > m_pics.getLength() THEN LET c = 1 END IF
--			CALL DIALOG.setCurrentRow( "pics", c )
    END DISPLAY

    INPUT BY NAME c
      ON CHANGE c
        CALL DIALOG.setCurrentRow("pics", c)
        CALL refresh(c)
    END INPUT

    BEFORE DIALOG
      LET frm = DIALOG.getForm()
      LET n = frm.findNode("FormField", "formonly.c")
      LET n = n.getFirstChild()
      CALL n.setAttribute("valueMax", m_pics.getLength())

    ON ACTION quit
      EXIT DIALOG

    ON ACTION firstrow
      LET c = 1
      CALL DIALOG.setCurrentRow("pics", c)
      CALL refresh(c)
    ON ACTION lastrow
      LET c = m_pics.getLength()
      CALL DIALOG.setCurrentRow("pics", c)
      CALL refresh(c)
    ON ACTION nextrow
      IF c < m_pics.getLength() THEN
        CALL DIALOG.setCurrentRow("pics", (c + 1))
        CALL refresh(c + 1)
      END IF
    ON ACTION prevrow
      IF c > 1 THEN
        CALL DIALOG.setCurrentRow("pics", (c - 1))
        CALL refresh(c - 1)
      END IF
		ON ACTION about
			CALL g2_about.g2_about(m_appInfo)

    ON ACTION close
      EXIT DIALOG
  END DIALOG
  CALL g2_lib.g2_exitProgram(0, % "Program Finished")
END MAIN
--------------------------------------------------------------------------------
FUNCTION refresh(l_c STRING)
  LET c = l_c
  IF c < 1 THEN
    RETURN
  END IF
  DISPLAY html_start || m_pics_info[c].nam || html_end TO nam
  DISPLAY "Arr:", c, ":", m_pics[c].pic
  DISPLAY c TO cur
  DISPLAY m_pics.getLength() TO max
  DISPLAY m_pics[c].pic TO img
  IF os.path.exists( m_pics[c].pic ) THEN
    DISPLAY "Found:", m_pics[c].pic
  ELSE
    DISPLAY "Not Found:", m_pics[c].pic
  END IF
  DISPLAY m_pics_info[c].nam TO d1
  DISPLAY m_pics_info[c].typ TO d2
  DISPLAY m_pics_info[c].pth TO d3
  DISPLAY m_pics_info[c].siz TO d4
  DISPLAY m_pics_info[c].mod TO d5
  DISPLAY m_pics_info[c].rwx TO d6

  CALL ui.interface.refresh()
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION getImages(p_ext STRING, p_ext2 STRING)
  DEFINE l_ext STRING

  CALL os.Path.dirSort("name", 1)
  LET d = os.Path.dirOpen(m_base)
  IF d > 0 THEN
    WHILE TRUE
      LET path = os.Path.dirNext(d)
      IF path IS NULL THEN
        EXIT WHILE
      END IF

      IF os.path.isDirectory(path) THEN
        --DISPLAY "Dir:",path
        CONTINUE WHILE
      ELSE
        --DISPLAY "Fil:",path
      END IF

      LET l_ext = os.path.extension(path)
      IF l_ext IS NULL OR (p_ext != l_ext AND p_ext2 != l_ext) THEN
        CONTINUE WHILE
      END IF

      IF path.subString(1, 6) = "banner" THEN
        CONTINUE WHILE
      END IF
      IF path.subString(1, 6) = "FourJs" THEN
        CONTINUE WHILE
      END IF
      IF path.subString(1, 6) = "Genero" THEN
        CONTINUE WHILE
      END IF
      IF path.subString(2, 2) = "_" THEN
        CONTINUE WHILE
      END IF
      IF path.subString(3, 3) = "_" THEN
        CONTINUE WHILE
      END IF
      IF path.subString(3, 3) = "." THEN
        CONTINUE WHILE
      END IF

      LET m_pics[ m_pics.getLength() + 1 ].pic = path
      LET m_pics_info[ m_pics.getLength() ].nam = os.Path.rootName(path)
      LET m_pics_info[ m_pics.getLength() ].pth = m_base
      LET m_pics_info[ m_pics.getLength() ].mod = os.Path.mtime( m_pics[ m_pics.getLength()].pic )
      LET c = os.Path.size(m_base || path)
      LET m_pics_info[ m_pics.getLength() ].siz = c USING "<<,<<<,<<<"
      LET m_pics_info[ m_pics.getLength() ].pth = m_base
      LET m_pics_info[ m_pics.getLength() ].typ = l_ext
      LET m_pics_info[ m_pics.getLength() ].rwx = os.Path.rwx(m_base || path)
      --DISPLAY m_pics.getLength(),": File:",path," Ext:",l_ext
      IF m_pics.getLength() = max_images THEN
        EXIT WHILE
      END IF
    END WHILE
  END IF

END FUNCTION
--------------------------------------------------------------------------------