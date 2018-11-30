
IMPORT os
IMPORT FGL gl_lib_aui

&include "genero_lib.inc"

DEFINE m_user_agent STRING
--------------------------------------------------------------------------------
#+ Dynamic About Window
#+
#+ @param l_ver a version string
#+ @return Nothing.
FUNCTION gl_about(l_ver STRING) --{{{
	DEFINE f,n,g,w om.DomNode
	DEFINE nl om.nodeList
	DEFINE gver, servername, info, txt STRING
	DEFINE y SMALLINT

	IF os.Path.pathSeparator() = ";" THEN -- Windows
		LET servername = fgl_getEnv("COMPUTERNAME")
	ELSE -- Unix / Linux / Mac / Android
		LET servername = fgl_getEnv("HOSTNAME")
	END IF
	LET gver = "build ",fgl_getVersion()

	IF gl_cli_os = "?" THEN
		CALL ui.interface.frontcall("standard","feinfo",[ "ostype" ], [ gl_cli_os ] )
		CALL ui.interface.frontcall("standard","feinfo",[ "osversion" ], [ gl_cli_osver ] )
		CALL ui.interface.frontCall("standard","feinfo",[ "screenresolution" ], [ gl_cli_res ])
		CALL ui.interface.frontCall("standard","feinfo",[ "fepath" ], [ gl_cli_dir ])
	END IF

	IF gl_app_name IS NULL THEN CALL gl_setAppInfo( NULL, NULL ) END IF

	OPEN WINDOW about AT 1,1 WITH 1 ROWS, 1 COLUMNS ATTRIBUTE(STYLE="naked")
	LET n = gl_getWinNode(NULL)
	CALL n.setAttribute("text",gl_progdesc)
	LET f = gl_genForm("about")
	LET n = f.createChild("VBox")
	CALL n.setAttribute("posY","0" )
	CALL n.setAttribute("posX","0" )

	IF gl_splashImage IS NOT NULL AND gl_splashImage != " " THEN
		LET g = n.createChild("HBox")
		CALL g.setAttribute("posY",y)
		CALL g.setAttribute("gridWidth",36)
		LET w = g.createChild("SpacerItem")

		LET w = g.createChild("Image")
		CALL w.setAttribute("posY","0" )
		CALL w.setAttribute("posX","0" )
		CALL w.setAttribute("name","logo" )
		CALL w.setAttribute("style","noborder")
		CALL w.setAttribute("stretch","both" )
		CALL w.setAttribute("autoScale","1" )
		CALL w.setAttribute("gridWidth","12" )
		CALL w.setAttribute("image",gl_splashImage )
		CALL w.setAttribute("height","100px" )
		CALL w.setAttribute("width", "290px" )

		LET w = g.createChild("SpacerItem")
		LET y = 10
	ELSE
		LET y = 1
	END IF

	LET g = n.createChild("Group")
	CALL g.setAttribute("text","About")
	CALL g.setAttribute("posY","10" )
	CALL g.setAttribute("posX","0" )
	CALL g.setAttribute("style","about")

	IF gl_app_build IS NOT NULL THEN
		CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Application"),"right","black")
		CALL gl_lib_aui.gl_addLabel(g,10,y,gl_app_name||" - "||gl_app_build,NULL,NULL) LET y = y + 1
	END IF

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Program")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,gl_progname||" - "||l_ver,NULL,"black") LET y = y + 1

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Description")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,gl_progdesc,NULL,"black") LET y = y + 1

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Author")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,gl_progauth,NULL,"black") LET y = y + 1

	LET w = g.createChild("HLine")
	CALL w.setAttribute("posY",y) LET y = y + 1
	CALL w.setAttribute("posX",0)
	CALL w.setAttribute("gridWidth",25)

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Genero Runtime")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,gver,NULL,"black") LET y = y + 1

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Server OS")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,gl_os,NULL,"black") LET y = y + 1

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Server Name")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,servername,NULL,"black") LET y = y + 1

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("OS User")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,gl_userName,NULL,"black") LET y = y + 1

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Server Time:")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,TODAY||" "||TIME,NULL,"black") LET y = y + 1

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Database Name")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,fgl_getEnv("DBNAME"),NULL,NULL) LET y = y + 1

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Database Type")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,UPSHIFT( fgl_db_driver_type() ),NULL,"black") LET y = y + 1

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("DBDATE")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,fgl_getEnv("DBDATE"),NULL,"black") LET y = y + 1

	LET w = g.createChild("HLine")
	CALL w.setAttribute("posY",y) LET y = y + 1
	CALL w.setAttribute("posX",0)
	CALL w.setAttribute("gridWidth",25)

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Client OS")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,gl_cli_os||" / "||gl_cli_osver,NULL,"black") LET y = y + 1

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Clint OS User")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,gl_cli_un,NULL,"black") LET y = y + 1

	IF m_user_agent.getLength() > 1 THEN
		CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("User Agent")||":","right","black")
		CALL gl_lib_aui.gl_addLabel(g,10,y,m_user_agent,NULL,"black") LET y = y + 1
	END IF

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("FrontEnd Version")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,gl_fe_typ||" "||gl_fe_ver,NULL,"black") LET y = y + 1

	IF gl_cli_dir.getLength() > 1 THEN
		CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Client Directory")||":","right","black")
		CALL gl_lib_aui.gl_addLabel(g,10,y,gl_cli_dir,NULL,"black") LET y = y + 1
	END IF

	CALL gl_lib_aui.gl_addLabel(g, 0,y,LSTR("Client Resolution")||":","right","black")
	CALL gl_lib_aui.gl_addLabel(g,10,y,gl_cli_res,NULL,"black") LET y = y + 1

	LET g = g.createChild("HBox")
	CALL g.setAttribute("posY",y)
	CALL g.setAttribute("gridWidth",40)
	LET w = g.createChild("SpacerItem")
	LET w = g.createChild("Button")
	CALL w.setAttribute("posY",y)
	CALL w.setAttribute("text","Copy to Clipboard")
	CALL w.setAttribute("name","copyabout")
	LET w = g.createChild("Button")
	CALL w.setAttribute("posY",y)
	CALL w.setAttribute("text","Show Env")
	CALL w.setAttribute("name","showenv")
	LET w = g.createChild("Button")
	CALL w.setAttribute("posY",y)
	CALL w.setAttribute("text","Show License")
	CALL w.setAttribute("name","showlicence")
	LET w = g.createChild("Button")
	CALL w.setAttribute("posY",y)
	CALL w.setAttribute("text","ReadMe")
	CALL w.setAttribute("name","showreadme")
	LET w = g.createChild("Button")
	CALL w.setAttribute("posY",y)
	CALL w.setAttribute("text","Close")
	CALL w.setAttribute("name","closeabout")
	LET w = g.createChild("SpacerItem")

	LET nl = f.selectByTagName("Label")
	FOR y = 1 TO nl.getLength()
		LET w = nl.item( y )
		LET txt = w.getAttribute("text")
		IF txt IS NULL THEN LET txt = "(null)" END IF
		LET info = info.append( txt )
		IF NOT y MOD 2 THEN
			LET info = info.append( "\n" )
		END IF
	END FOR

	MENU "Options"
		ON ACTION close	EXIT MENU
		ON ACTION closeabout	EXIT MENU
		ON ACTION showenv CALL gl_lib_aui.gl_showEnv()
		ON ACTION showreadme CALL gl_lib_aui.gl_showReadMe()
		ON ACTION showlicence CALL gl_lib_aui.gl_showlicence()
		ON ACTION copyabout 
			CALL ui.interface.frontCall("standard","cbset",info,y )
	END MENU
	CLOSE WINDOW about

END FUNCTION --}}}