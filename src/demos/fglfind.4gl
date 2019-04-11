# Property of Four Js*
# (c) Copyright Four Js 1995, 2011. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere

PUBLIC DEFINE columns DYNAMIC ARRAY OF RECORD
  fieldId INT,
  name STRING
END RECORD

FUNCTION fglfind(r, _notfound)
  DEFINE r RECORD
    pattern STRING,
    ignoreCase BOOLEAN,
    wrapAround BOOLEAN,
    fieldId INT
  END RECORD

  DEFINE i INT
  DEFINE x ui.ComboBox
  DEFINE _notfound BOOLEAN -- clashes WITH NOTFOUND
  DEFINE d ui.Dialog
  DEFINE f ui.Form
  DEFINE p, n, n1, n2 om.DomNode
  DEFINE nl om.NodeList
  LET d = ui.Dialog.getCurrent()
  LET f = d.getForm()
  LET n = f.getNode()
  LET nl = n.selectByPath("//Table[@active='1']")
  LET n = nl.item(1)
  LET p = n.getParent()
  LET n = p.createChild("Grid")
  CALL n.setAttribute("posY", 1000)
  LET n1 = n.createChild("Label")
  CALL n1.setAttribute("text", "Find:")

  LET n1 = n.createChild("FormField")
  CALL n1.setAttribute("colName", "pattern")
  CALL n1.setAttribute("fieldId", "1")
  CALL n1.setAttribute("name", "formonly.pattern")
  LET n2 = n1.createChild("Edit")
  CALL n2.setAttribute("posX", 6)
  CALL n2.setAttribute("gridWidth", 21)
  CALL n2.setAttribute("width", 21)

  LET n1 = n.createChild("FormField")
  CALL n1.setAttribute("colName", "ignorecase")
  CALL n1.setAttribute("fieldId", "2")
  CALL n1.setAttribute("name", "formonly.ignorecase")
  CALL n1.setAttribute("notNull", 1)
  LET n2 = n1.createChild("CheckBox")
  CALL n2.setAttribute("posX", 40)
  CALL n2.setAttribute("valueChecked", 1)
  CALL n2.setAttribute("valueUnchecked", 0)
  CALL n2.setAttribute("text", "Ignore Case")

  LET n1 = n.createChild("FormField")
  CALL n1.setAttribute("colName", "wraparound")
  CALL n1.setAttribute("fieldId", "3")
  CALL n1.setAttribute("name", "formonly.wraparound")
  CALL n1.setAttribute("notNull", 1)
  LET n2 = n1.createChild("CheckBox")
  CALL n2.setAttribute("posX", 50)
  CALL n2.setAttribute("valueChecked", 1)
  CALL n2.setAttribute("valueUnchecked", 0)
  CALL n2.setAttribute("hidden", 1)

  LET n1 = n.createChild("FormField")
  CALL n1.setAttribute("colName", "fieldid")
  CALL n1.setAttribute("fieldId", "4")
  CALL n1.setAttribute("name", "formonly.fieldid")
  CALL n1.setAttribute("notNull", 1)
  LET n2 = n1.createChild("ComboBox")
  CALL n2.setAttribute("posX", 60)

  LET x = ui.ComboBox.forName("fieldid")
  CALL x.clear()
  CALL x.addItem(0, "---")
  FOR i = 1 TO columns.getLength()
    CALL x.addItem(columns[i].fieldId, columns[i].name)
  END FOR

  {IF _notfound THEN
  		DISPLAY "Not found" TO NOTFOUND
  	END IF}
  DISPLAY "Input:", columns.getLength()
  IF columns.getLength() > 1 THEN
    INPUT BY NAME r.* ATTRIBUTE(WITHOUT DEFAULTS) --, FIELD ORDER FORM);
  ELSE
    LET r.fieldId = 0
    INPUT BY NAME r.pattern, r.ignoreCase, r.wrapAround
        ATTRIBUTE(WITHOUT DEFAULTS, FIELD ORDER FORM);
  END IF
  CALL p.removeChild(n)
  RETURN r.*
END FUNCTION
