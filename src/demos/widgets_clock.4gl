IMPORT util

DEFINE tim CHAR(8)
DEFINE dsp CHAR(2)
DEFINE scrw, w SMALLINT
DEFINE x, y SMALLINT
DEFINE r, a SMALLINT
DEFINE pi DECIMAL(12, 11)
DEFINE d DECIMAL(12, 5)
DEFINE h, m, s SMALLINT
DEFINE ret INTEGER

--------------------------------------------------------------------------------
-- Draw a clock using Canvas
FUNCTION clock2(l_aniyn BOOLEAN)

  CALL drawselect("canv")
  CALL drawlinewidth(2)

  IF l_aniyn THEN
    CALL clock_face()
    RETURN
  END IF

-- format is x,y,h,w ( NOTE x,y is from bottom left of canvas area )

  CALL cls()
  DISPLAY "Y" TO chk1
--	CALL ui.interface.refresh()

-- DRAW A PALE BLUE RECTANGLE
  CALL drawfillcolor("#C6DEF4")
  CALL drawrectangle(51, 1, 900, 1000) RETURNING ret
  DISPLAY "Y" TO chk2
--	CALL ui.interface.refresh()
--	DRAW AN OVAL
  CALL drawfillcolor("#093B73")
  CALL drawoval(51, 1, 900, 1000) RETURNING ret
  DISPLAY "Y" TO chk3
--	CALL ui.interface.refresh()

  CALL time(1)

END FUNCTION
--------------------------------------------------------------------------------
-- Reset the clock face and display to checkboxes
FUNCTION cls()
  DEFINE c, s om.DomNode
  DEFINE win ui.Window

  DISPLAY "N" TO chk1
  DISPLAY "N" TO chk2
  DISPLAY "N" TO chk3
  DISPLAY "N" TO chk4
  DISPLAY "N" TO chk5
  DISPLAY "N" TO chk6

  LET win = ui.Window.getCurrent()
  LET c = win.findnode("Canvas", "canv")
  IF c IS NOT NULL THEN
    LET s = c.getFirstChild()
    WHILE s IS NOT NULL
      CALL c.removeChild(s)
      LET s = c.getFirstChild()
    END WHILE
  END IF

  CALL drawfillcolor("black")
  CALL drawrectangle(1, 1, 1000, 1000) RETURNING ret

END FUNCTION
--------------------------------------------------------------------------------
FUNCTION time(l_seconds INTEGER)
  DEFINE l_loop SMALLINT

  LET pi = 3.14159265358
  LET scrw = 33

  CALL drawanchor("n")
  CALL drawlinewidth(2)

  -- DRAW A SMALLER YELLOW CIRCLE
  CALL drawfillcolor("#CFB57D")
  CALL drawcircle(941, 61, 880) RETURNING w
  DISPLAY "Y" TO chk4
--	CALL ui.interface.refresh()

  -- WRITE THE NUMBER AROUND THE CLOCK FACE
  LET r = 400
  LET h = 0
  FOR a = 30 TO 360 STEP 30
    LET h = h + 1
    LET d = (pi / 180) * a
    LET y = r * (util.math.sin(d))
    LET x = r * (util.math.cos(d))
    LET dsp = h
    CALL drawfillcolor("black")
    CALL drawtext(520 + x, 500 + y, dsp) RETURNING w
  END FOR
  DISPLAY "Y" TO chk5
--	SLEEP 1
--	CALL ui.interface.refresh()
  -- DRAW INNER WHITE CIRCLE
  CALL drawfillcolor("#F5F8E4")
  CALL drawcircle(851, 151, 700) RETURNING w

  -- LOOP FOR seconds DRAWING THE CENTRAL WRITE FACE AND HANDS
  LET l_seconds = 1 -- Stopped the loop
  FOR l_loop = 1 TO l_seconds
    CALL clock_face()
    DISPLAY "Y" TO chk6
    CALL ui.interface.refresh()
--		SLEEP 1
  END FOR

END FUNCTION
--------------------------------------------------------------------------------
-- Draw the clock face
FUNCTION clock_face()
  DEFINE c, n om.DomNode
  DEFINE win ui.Window
  DEFINE ll om.NodeList
  DEFINE x SMALLINT

  LET tim = TIME

-- Remove Hands
  LET win = ui.Window.getCurrent()
  LET c = win.findnode("Canvas", "canv")
  LET ll = c.selectByPath("//CanvasLine")
  FOR x = 1 TO ll.getLength()
    LET n = ll.item(x)
    CALL c.removeChild(n)
  END FOR

  LET h = tim[1, 2]
  LET m = tim[4, 5]
  LET s = tim[7, 8]

  -- CALCULATE THE XY OF HOUR HAND AND DRAW IT
  LET r = 300
  LET a = (360 / 12) * h
  LET a = a + ((30 / 60) * m)
  LET d = (pi / 180) * a
  LET y = r * (util.math.sin(d))
  LET x = r * (util.math.cos(d))
  CALL drawlinewidth(4)
  CALL drawfillcolor("red")
  CALL drawline(501, 501, x, y) RETURNING w

  -- CALCULATE THE XY OF MINUTE HAND AND DRAW IT
  LET r = 350
  LET a = (360 / 60) * m
  LET d = (pi / 180) * a
  LET y = r * (util.math.sin(d))
  LET x = r * (util.math.cos(d))
  CALL drawfillcolor("blue")
  CALL drawlinewidth(2)
  CALL drawline(501, 501, x, y) RETURNING w

  -- CALCULATE THE XY OF SECOND HAND AND DRAW IT
  LET r = 350
  LET a = (360 / 60) * s
  LET d = (pi / 180) * a
  LET y = r * (util.math.sin(d))
  LET x = r * (util.math.cos(d))
  CALL drawlinewidth(1)
  CALL drawfillcolor("black")
  CALL drawline(501, 501, x, y) RETURNING w

END FUNCTION
