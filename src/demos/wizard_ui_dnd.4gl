GLOBALS "wizard_glob.inc"
DEFINE drag_source STRING
DEFINE dnd ui.DragDrop
FUNCTION wizard_ui_dnd()
  DIALOG ATTRIBUTE(UNBUFFERED)
    INPUT BY NAME currtable ATTRIBUTE(WITHOUT DEFAULTS)
      ON CHANGE currtable
        CALL on_change_currtable()
    END INPUT
    DISPLAY ARRAY lfields TO l.*
      ON ACTION right
        CALL right(DIALOG)
      ON ACTION allright
        CALL allright()
      ON DRAG_START(dnd)
        LET drag_source = "left"
      ON DRAG_ENTER(dnd)
        CALL drop_validate("right")
      ON DROP(dnd)
        CALL left(DIALOG)
      ON DRAG_FINISHED(dnd)
        INITIALIZE drag_source TO NULL
    END DISPLAY
    DISPLAY ARRAY rfields TO r.*
      ON ACTION left
        CALL left(DIALOG)
      ON ACTION allleft
        CALL allleft()
      ON DRAG_START(dnd)
        LET drag_source = "right"
      ON DRAG_ENTER(dnd)
        CALL drop_validate("left")
      ON DROP(dnd)
        CALL right(DIALOG)
      ON DRAG_FINISHED(dnd)
        INITIALIZE drag_source TO NULL
    END DISPLAY
    BEFORE DIALOG
      CALL DIALOG.setSelectionMode("l", TRUE)
      CALL DIALOG.setSelectionMode("r", TRUE)
    ON ACTION canlwiz
      EXIT DIALOG
    ON ACTION finiwiz
      ACCEPT DIALOG
  END DIALOG
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION drop_validate(target)
  DEFINE target STRING
  IF drag_source = target THEN
    CALL dnd.setOperation("move")
    CALL dnd.setFeedback("insert")
  ELSE
    CALL dnd.setOperation(NULL)
  END IF
END FUNCTION
