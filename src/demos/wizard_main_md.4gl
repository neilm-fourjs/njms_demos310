-- Multi Dialog Wizard Demo
IMPORT FGL wizard_ui_md
IMPORT FGL wizard_common
GLOBALS "wizard_glob.inc"
MAIN
	CALL init_prog("wizard_md","WizardMD","Wizard - Multi Dialog")
	CALL wizard_ui_md()
END MAIN