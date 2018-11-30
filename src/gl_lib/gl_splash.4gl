&include "genero_lib.inc"
--------------------------------------------------------------------------------
#+ Splash screen
#+
#+ @param l_dur > 0 for sleep then close, 0=just open window, -1=close window
#+ @return Nothing.
FUNCTION gl_splash(l_dur SMALLINT) --{{{
	DEFINE f,g,n om.DomNode

	IF gl_fe_typ = "GBC" THEN RETURN END IF
	IF gl_splashImage.getLength() < 2 THEN RETURN END IF

	IF l_dur = -1 THEN
		CLOSE WINDOW splash
		RETURN
	END IF

	GL_DBGMSG(4,"Doing splash.")
	OPEN WINDOW splash AT 1,1 WITH 1 ROWS,1 COLUMNS ATTRIBUTE(STYLE="default noborder dialog2 bg_white")
	LET f = gl_genForm("splash")
	LET g = f.createChild("Grid")
	LET n = g.createChild("Image")
	CALL n.setAttribute("name","logo" )
	CALL n.setAttribute("style","noborder" )
	CALL n.setAttribute("width","36" )
	CALL n.setAttribute("height","8" )
	CALL n.setAttribute("image",gl_splashImage )
	CALL n.setAttribute("posY","0" )
	CALL n.setAttribute("posX","0" )
	CALL n.setAttribute("gridWidth","40" )
	CALL n.setAttribute("gridHeight","8")
	CALL n.setAttribute("height","200px" )
	CALL n.setAttribute("width", "570px" )
	CALL n.setAttribute("stretch","both" )
	CALL n.setAttribute("autoScale","1" )
	CALL ui.interface.refresh()

	IF l_dur > 0 THEN
		SLEEP l_dur
		CLOSE WINDOW splash
	END IF
	GL_DBGMSG(4,"Done splash.")
END FUNCTION --}}}