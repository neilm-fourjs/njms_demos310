
IMPORT os
IMPORT util

&include "genero_lib.inc"

--------------------------------------------------------------------------------
#+ Add a Field to a grid/group
#+
#+ @param f Node of the Grid or Group
#+ @param x X position
#+ @param y Y Position
#+ @param wgt Widget: Edit, ButtonEdit, ComboBox, DateEdit etc
#+ @param fld Text for label
#+ @param w Width
#+ @param com NULL or Comment
#+ @param j Justify : NULL, center or right
#+ @param s Style.
#+ @return nothing
FUNCTION gl_addField(
		f om.DomNode,
		x SMALLINT,
		y SMALLINT,
		wgt STRING,
		fld STRING,
		w SMALLINT,
		com STRING,
		j STRING,
		s STRING ) --{{{
	DEFINE n om.domNode
	DEFINE h SMALLINT

	LET f = f.createChild("FormField")
	CALL f.setAttribute("name",fld)
	CALL f.setAttribute("colName",fld)
	LET n = f.createChild(wgt)
	CALL n.setAttribute("posX",x)
	CALL n.setAttribute("posY",y)
	IF w > 80 THEN 
		LET h = w / 80 
		LET w = 80
		CALL n.setAttribute("height",h)
	END IF
	CALL n.setAttribute("width",w)
	IF com IS NOT NULL THEN
		CALL n.setAttribute("comment",com)
	END IF
	IF j IS NOT NULL THEN
		CALL n.setAttribute("justify",j)
	END IF
	IF s IS NOT NULL THEN
		CALL n.setAttribute("style",s)
	END IF

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Add a label to a grid/group
#+
#+ @param l Node of the Grid or Group
#+ @param x X position
#+ @param y Y Position
#+ @param txt Text for label
#+ @param j Justify : NULL, center or right
#+ @param s Style.
#+ @return nothing
FUNCTION gl_addLabel(
	l om.DomNode,
	x SMALLINT,
	y SMALLINT,
	txt STRING,
	j STRING,
	s STRING) --{{{

	LET l = l.createChild("Label")
	CALL l.setAttribute("posX",x)
	CALL l.setAttribute("posY",y)
	CALL l.setAttribute("text",txt)
	IF j IS NOT NULL THEN
		CALL l.setAttribute("justify",j)
	END IF
	IF s IS NOT NULL THEN
		CALL l.setAttribute("style",s)
	END IF

END FUNCTION --}}}