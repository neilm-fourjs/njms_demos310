-- Multi Dialog Wizard Demo with Multi Row Select
IMPORT FGL wizard_ui_mrs
IMPORT FGL wizard_common
GLOBALS "wizard_glob.inc"
MAIN
  CALL wizard_common.init_prog("wizard_md", "WizardMRS", "Wizard - Multi Row Select")
  CALL wizard_ui_mrs.wizard_ui_mrs()
END MAIN
