--------------------------------------------------------------------------------
-- Program to view a file using a DISPLAY ARRAY

DEFINE m_filename STRING
DEFINE line STRING
DEFINE ret SMALLINT
DEFINE chl base.channel
DEFINE fnd STRING
DEFINE fnd_cnt SMALLINT
DEFINE text DYNAMIC ARRAY OF STRING
DEFINE cols DYNAMIC ARRAY OF STRING
DEFINE lnes DYNAMIC ARRAY OF SMALLINT
MAIN
	DEFINE lne_cnt INTEGER
	DEFINE tog,x SMALLINT

	IF base.Application.getArgumentCount() < 1 THEN
		DISPLAY "No args!"
		EXIT PROGRAM
	END IF
	LET m_filename = base.application.getArgument(1)
	LET fnd = base.application.getArgument(2)

	LET chl = base.channel.create()

	TRY
		CALL chl.openFile( m_filename,"r")
	CATCH
		CALL gl_winMessage("Error", SFMT( "Failed to open '%1'!",m_filename.trim()),"exclamation")
		EXIT PROGRAM
	END TRY
	CALL chl.setDelimiter("")

	LET tog = FALSE
	LET ret = 1
	LET lne_cnt = 0
	LET fnd_cnt = 0
	DISPLAY "Reading '"||m_filename||"' ..."
	WHILE ret = 1
		LET ret = chl.read( line )
		IF ret = 1 THEN
			LET lne_cnt = lne_cnt + 1
			LET text[lne_cnt] = line
--		 IF tog THEN
--			 LET cols[lne_cnt] = "blue"
--		 ELSE
				LET cols[lne_cnt] = "darkblue"
--		 END IF
			IF line.substring(1,2) = "--" THEN
			 LET cols[lne_cnt] = "green"
			END IF
			IF fnd IS NOT NULL AND strstr(line,fnd) THEN
				LET fnd_cnt = fnd_cnt + 1
				LET lnes[fnd_cnt] = lne_cnt
				LET cols[lne_cnt] = "darkred"
			END IF
			LET tog = NOT tog
		END IF
	END WHILE
	CALL chl.close()
	DISPLAY "Readed "||text.getLength()||" Lines"
	CALL do_form()

	LET x = 1
	DISPLAY ARRAY text TO source.* ATTRIBUTE(COUNT=lne_cnt)
		BEFORE DISPLAY
			CALL dialog.setCellAttributes(cols)
			CALL fgl_dialog_setcurrline(0,lnes[x])
		ON ACTION fndnxt
			LET x = x + 1
			IF x > fnd_cnt THEN LET x = 1 END IF
			CALL fgl_dialog_setcurrline(0,lnes[x])
		ON ACTION fndprv
			LET x = x - 1
			IF x = 0 THEN LET x = fnd_cnt END IF
			CALL fgl_dialog_setcurrline(0,lnes[x])
	END DISPLAY

END MAIN
--------------------------------------------------------------------------------
-- Dynamically create the form
FUNCTION do_form()
	DEFINE win ui.Window
	DEFINE winnode, frm, tab, grd, but, tabc, edit	om.DomNode
	DEFINE x,y SMALLINT
	DEFINE frm_obj ui.Form
	DEFINE titl STRING

	LET x = 100
	LET y = 30
	LET titl = "File: "||m_filename.trim()||"  Lines: "||(text.getLength() USING "<<,<<<,<<<")

	CURRENT WINDOW IS SCREEN
	LET win = ui.Window.GetCurrent()
	LET winnode = win.getNode()
	CALL winnode.setAttribute("style","naked")
	CALL winnode.setAttribute("width",x)
	CALL winnode.setAttribute("height",y)
	LET frm_obj = win.CreateForm("EditFile")
	LET frm = frm_obj.getNode()
--	CALL frm.setAttribute("text","File: "||m_filename.trim())
	CALL winnode.setAttribute("text",titl)

	LET frm = frm.createChild('VBox')
	LET grd = frm.createChild('Grid')
	LET but = grd.createChild('Button')
	CALL but.setAttribute("name","accept")
	CALL but.setAttribute("text","Close")
	CALL but.setAttribute("posX","1")
	LET but = grd.createChild('Button')
	CALL but.setAttribute("name","fndprv")
	CALL but.setAttribute("image","gorev")
	CALL but.setAttribute("posX","10")
	LET but = grd.createChild('Button')
	CALL but.setAttribute("name","fndnxt")
	CALL but.setAttribute("image","goforw")
	CALL but.setAttribute("posX","20")
	LET but = grd.createChild('Label')
	CALL but.setAttribute("text","Found "||fnd_cnt||" matches for '"||fnd||"'")
	CALL but.setAttribute("posX","30")
	LET tab = frm.createChild('Table')
	CALL tab.setAttribute("tabName","source")
	CALL tab.setAttribute("style","list")
	CALL tab.setAttribute("height","20")
	CALL tab.setAttribute("pageSize","20")
	CALL tab.setAttribute("size","20")
	CALL tab.setAttribute("unsortableColumns","1")
	CALL tab.setAttribute("fontPitch","fixed")

	LET tabc = tab.createChild('TableColumn')
	CALL tabc.setAttribute("colName","source")
	CALL tabc.setAttribute("name","formonly.source")
	CALL tabc.setAttribute("text",titl)

	LET edit = tabc.createChild('Edit')
	CALL edit.setAttribute("width",x)

END FUNCTION
--------------------------------------------------------------------------------
-- Search for a string within a string
FUNCTION strstr(str,fnd)
	DEFINE str,fnd STRING
	DEFINE x,y SMALLINT

	LET y = fnd.getLength() - 1
	FOR x = 1 TO ( str.getLength() - y)
		IF str.substring(x,x+y) = fnd THEN
			RETURN TRUE
		END IF
	END FOR
	RETURN FALSE
END FUNCTION
