-- Multi Dialog Wizard Demo with Multi Row Select & Drag-n-Drop
IMPORT FGL wizard_ui_dnd
IMPORT FGL wizard_common
GLOBALS "wizard_glob.inc"
MAIN
  CALL wizard_common.init_prog("wizard_md", "WizardDnD", "Wizard - Drag-n-Drop")
  CALL wizard_ui_dnd.wizard_ui_dnd()
END MAIN
