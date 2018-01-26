
MAIN
	CALL ui.Interface.loadStyles("container") --"||UPSHIFT(ui.interface.getFrontEndName()))

	CALL ui.Interface.setType("container")
	CALL ui.Interface.setName("mycontain")

--	CALL ui.Interface.loadToolBar("container")
	CALL ui.Interface.loadStartMenu("container") -- required for GBC!!!

	CALL ui.Interface.setText("Container 1.2")
	OPEN FORM f FROM "container"
	DISPLAY FORM f

	MENU
		COMMAND "menu"
			RUN "fglrun menu.42r C" WITHOUT WAITING
		COMMAND "matdestest"
			RUN "fglrun materialDesignTest.42r C" WITHOUT WAITING
		COMMAND "Exit" EXIT MENU
	END MENU
END MAIN