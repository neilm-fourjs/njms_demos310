
IMPORT os
IMPORT util

&include "genero_lib.inc"

DEFINE m_styleList om.DomNode

--------------------------------------------------------------------------------
#+ Dynamically change a comment(tooltip), for the named item.
#+
#+ @param dia ui.dialog for the current dialog - can be NULL
#+ @param frm ui.form for the current form - can be NULL - defaults to current
#+ @param nam Name of form element to be affected.
#+ @param com New comment value for the named element.
#+ @return Node.
FUNCTION gl_chgComment(dia,frm,nam,com) --{{{
	DEFINE dia ui.dialog
	DEFINE frm ui.Form
	DEFINE nam,com STRING
	DEFINE nl om.NodeList
	DEFINE n om.DomNode

	IF dia IS NOT NULL THEN
		LET frm = dia.getForm()
	END IF
	IF frm IS NULL THEN
		LET n = gl_getFormN( NULL )
	ELSE
		LET n = frm.getNode()
	END IF
	LET nl = n.selectbypath("//*[@name=\""||nam CLIPPED||"\"]")
	IF nl.getLength() > 0 THEN
		LET n = nl.item(1)
		IF n.getTagName() = "FormField" THEN
			LET n = n.getFirstChild()
		END IF
		CALL n.setAttribute("comment",com)
	ELSE
		CALL gl_errMsg(__FILE__,__LINE__,"gl_chgComment: name '"||nam.trim()||"' not found.")
	END IF

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Hides a toolbar item.
#+
#+ @param nam Name of item
#+ @param hid TRUE/FALSE hide/unhide
#+ @return none
FUNCTION gl_hideToolBarItem(nam,hid) --{{{
	DEFINE nam STRING
	DEFINE hid SMALLINT
	DEFINE nl om.nodeList
	DEFINE n om.domNode

	LET n = ui.interface.getRootNode()
	LET nl = n.selectByPath("//ToolBarItem[@name=\""||nam||"\"]")
	IF nl.getLength() > 0 THEN
		LET n = nl.item(1)
		GL_DBGMSG(1, "gl_hideToolBarItem: Setting Hidden on '"||nam||"'")
		CALL n.setAttribute("hidden",hid)
	ELSE
		GL_DBGMSG(1, "gl_hideToolBarItem: didn't find '"||nam||"'!")
	END IF

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Append a node(+it's children) from a different DomDocument to a node.
#+
#+ @param cur = Node:			node to append to
#+ @param new = Node:			node to append from
#+ @param lev = Smallint:	0 - Used by this function for recursive calls.
#+ @return Nothing.
FUNCTION gl_appendNode( cur, new, lev ) --{{{
	DEFINE cur, new, tmp, cld om.DomNode
	DEFINE x,lev SMALLINT

	WHILE new IS NOT NULL
		IF new.getTagName() = "LStr" THEN RETURN END IF
		LET tmp = cur.createChild( new.getTagName() )
		FOR x = 1 TO new.getAttributesCount()
			CALL tmp.setAttribute( new.getAttributeName(x), new.getAttributeValue(x) )
		END FOR
		LET cld = new.getFirstChild()
		IF cld IS NOT NULL THEN
			CALL gl_appendNode( tmp, cld, lev+1 )
		END IF
		IF lev = 0 THEN EXIT WHILE END IF
		LET new = new.getNext()
	END WHILE

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Dynamically add a form as a snippet to the passed node
#+
#+ @param cont node of Containt to add snippet to.
#+ @param fname name of the .42f to load ( without the extension )
#+ @return Nothing.
FUNCTION gl_addSnippet( cont, fname ) --{{{
	DEFINE frm, cont om.DomNode
	DEFINE fname, addname STRING
	DEFINE tabn,coln STRING
	DEFINE new, tmp, tmp2 om.DomNode
	DEFINE newfrm om.DomDocument
	DEFINE nl,nl2 om.NodeList
	DEFINE x,x2,fldn SMALLINT

	GL_DBGMSG(1, "gl_addSnippet: fname='"||fname||"'")

-- Get the node for current form. Needed to add record views.
	LET frm = gl_getFormN( NULL )

-- Load the .42f and find the 1st child of the Form element.
	LET addname = fname.append(".42f")
	LET newfrm = om.DomDocument.createFromXMLFile(addname)
	IF newfrm IS NULL THEN
		GL_DBGMSG(1, SFMT("Faied to open %1",addname) ) -- "Failed to open ''."
		CALL gl_winMessage("Error",SFMT("Faied to open %1",addname),"exclamation")
		RETURN NULL
	END IF
	LET new = newfrm.getDocumentElement()
	LET nl = new.selectByPath("//Form")
	GL_DBGMSG(1, "gl_addSnippet: New Form Found:"||nl.getLength())
	LET tmp = nl.item(1)
	LET tmp = tmp.getFirstChild()
	WHILE TRUE
		IF tmp.getTagName() != "ActionDefaultList"
		AND tmp.getTagName() != "TopMenu"
		AND tmp.getTagName() != "ToolBar" THEN EXIT WHILE END IF
		LET tmp = tmp.getNext()
	END WHILE

-- Re-number the fieldIdRef's so record views can be done.
	LET nl2 = tmp.selectByPath("//FormField")
	FOR x2 = 1 TO nl2.getLength()
		LET tmp2 = nl2.item(x2)
		LET fldn = tmp2.getAttribute("fieldId")
		CALL tmp2.setAttribute("fieldId",fldn+4000 )
	END FOR

-- Append the new form to the 'cont' node.
	CALL gl_appendNode( cont, tmp, 0 )

-- Dynamically add any record views + re-number the fieldIdRefs
	LET nl = new.selectByPath("//RecordView")
	FOR x = 1 TO nl.getLength()
		LET tmp = nl.item(x)
		LET tabn = tmp.getAttribute("tabName")
		IF tabn != "formonly" THEN
			LET nl2 = tmp.selectByPath("//Link")
			FOR x2 = 1 TO nl2.getLength()
				LET tmp2 = nl2.item(x2)
				LET coln = tmp2.getAttribute("colName")
				LET fldn = tmp2.getAttribute("fieldIdRef")
				CALL tmp2.setAttribute("fieldIdRef",fldn+4000 )
			END FOR
			CALL gl_appendNode( frm, tmp, 0 )
		END IF
	END FOR

	RETURN cont.getFirstChild()

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Dynamically remove snippet form from passed node
#+
#+ @param cont node to remove.
#+ @return Nothing.
FUNCTION gl_removeSnippet( cont ) --{{{
	DEFINE frm, cont, part om.DomNode
	DEFINE tmp, tmp2 om.DomNode
	DEFINE nl,nl2 om.NodeList
	DEFINE x,x2,fldn SMALLINT

	GL_DBGMSG(1, "gl_removeSnippet")

	LET part = cont.getParent()
	CALL part.removeChild( cont )

-- Get the node for current form. Needed to add record views.
	LET frm = gl_getFormN( NULL )

-- Dynamically remove re-numbered fieldIdRefs
	LET nl = frm.selectByPath("//RecordView")
	FOR x = 1 TO nl.getLength()
		LET tmp = nl.item(x)
		LET nl2 = tmp.selectByPath("//Link")
		FOR x2 = 1 TO nl2.getLength()
			LET tmp2 = nl2.item(x2)
			LET fldn = tmp2.getAttribute("fieldIdRef")
			IF fldn > 4000 THEN
				CALL tmp.removeChild( tmp2 )
			END IF
		END FOR
	END FOR

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Dynamically add folder
#+
#+ @param nam Node of the folder, can be NULL
#+ @return Folder node
FUNCTION gl_addFolder(nam) --{{{
	DEFINE nam STRING
	DEFINE win ui.window
	DEFINE n om.domNode
	DEFINE nl om.nodeList

	LET win = ui.window.getCurrent()

	LET n = win.getNode()
	LET nl = n.selectByPath("//VBox")
	IF nl.getLength() < 1 THEN
		RETURN NULL
	END IF
	LET n = nl.item(1)

	LET n = n.createChild("Folder")
	CALL n.setAttribute("name",nam)

	RETURN n

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Dynamically add a form as a page to the passed folder tab
#+
#+ @param fld node of Folder to add pages to.
#+ @param pgno number of the page, ie 1,2,3 etc
#+ @param fname name of the .42f to load ( without the extension )
#+ @param pgnam Title of the Page. - If NULL using text from LAYOUT
#+ @return Nothing.
FUNCTION gl_addPage( fld, pgno, fname, pgnam ) --{{{
	DEFINE frm, fld, pg om.DomNode
	DEFINE pgnam, fname, addname STRING
	DEFINE tabn,coln STRING
	DEFINE new, tmp, tmp2, tmp3, tmp4 om.DomNode
	DEFINE newfrm om.DomDocument
	DEFINE nl,nl2 om.NodeList
	DEFINE pgno, x, x2, x3,fldn SMALLINT

	GL_DBGMSG(1, "gl_addPage: fname='"||fname||"' pgnam='"||pgnam||"'")

-- Get the node for current form. Needed to add record views.
	LET frm = gl_getFormN( NULL )

-- Load the .42f and find the 1st child of the Form element.
	LET addname = fname.append(".42f")
	LET newfrm = om.DomDocument.createFromXMLFile(addname)
	IF newfrm IS NULL THEN
		GL_DBGMSG(1, SFMT(%"lib.addpage.error",addname) ) -- "Failed to open ''."
		CALL gl_winMessage("Error",SFMT(%"lib.addpage.error",addname),"exclamation")
		RETURN
	END IF
	LET new = newfrm.getDocumentElement()
	LET nl = new.selectByPath("//Form")
	GL_DBGMSG(1, "gl_addPage: New Form Found:"||nl.getLength())
	LET tmp = nl.item(1)
	IF pgnam IS NULL THEN LET pgnam = tmp.getAttribute( "text" ) END IF
	LET tmp = tmp.getFirstChild()
	WHILE TRUE
		IF tmp.getTagName() != "ActionDefaultList"
		AND tmp.getTagName() != "TopMenu"
		AND tmp.getTagName() != "ToolBar" THEN EXIT WHILE END IF
		LET tmp = tmp.getNext()
	END WHILE

-- Re-number the fieldIdRef's so record views can be done.
	LET nl2 = tmp.selectByPath("//FormField")
	FOR x2 = 1 TO nl2.getLength()
		LET tmp2 = nl2.item(x2)
		LET fldn = tmp2.getAttribute("fieldId")
		CALL tmp2.setAttribute("fieldId",fldn+(pgno*100) )
	END FOR
	LET nl2 = tmp.selectByPath("//PhantomColumn")
	FOR x2 = 1 TO nl2.getLength()
		LET tmp2 = nl2.item(x2)
		LET fldn = tmp2.getAttribute("fieldId")
		CALL tmp2.setAttribute("fieldId",fldn+(pgno*100) )
	END FOR

-- Create new page in the folder and add the form to it
	LET pg = fld.createChild("Page")
-- Check to see if fname has path info
	FOR x	= fname.getLength() TO 1 STEP -1
		IF fname.getCharAt(x) = "/" THEN
			LET fname = fname.subString(x+1, fname.getLength() )
			EXIT FOR
		END IF	
	END FOR
	CALL pg.setAttribute("name",fname)
	CALL pg.setAttribute("text",pgnam)
	CALL pg.setAttribute("action","page"||pgno) -- default action.
	CALL gl_appendNode( pg, tmp, 0 )

	LET nl = pg.selectByPath("//Table")
	FOR x = 1 TO nl.getLength()
		LET tmp = nl.item(x)
		LET x2 = tmp.getAttribute("pageSize")
		--DISPLAY "TABLE:", tmp.getAttribute("isTree"),":",x2
		IF tmp.getAttribute("isTree") = "1" THEN
			--DISPLAY "TREE!!!!"
			LET tmp3 = tmp.getFirstChild()
			LET tmp2 = tmp.createChild("TreeInfo")
			CALL tmp.insertBefore(tmp2,tmp3)
			LET nl2 = tmp.selectByPath("//PhantomColumn")
			FOR fldn = 1 TO nl2.getLength()
				LET tmp3 = nl2.item(fldn)
				LET tmp3 = tmp3.createChild("ValueList")
			END FOR
			LET nl2 = tmp.selectByPath("//TableColumn")
			FOR fldn = 1 TO nl2.getLength()
				LET tmp3 = nl2.item(fldn)
				LET tmp3 = tmp3.createChild("ValueList")
				FOR x3 = 1 TO x2 
					LET tmp4 = tmp3.createChild("Value")
					CALL tmp4.setAttribute("value","")
				END FOR
			END FOR
		END IF
	END FOR

	--DISPLAY "ADDING RECORDVIEW"
-- Dynamically add any record views + re-number the fieldIdRefs
	LET nl = new.selectByPath("//RecordView")
	FOR x = 1 TO nl.getLength()
		LET tmp = nl.item(x)
		LET tabn = tmp.getAttribute("tabName")
		--DISPLAY "tabname:",tabn
		IF tabn != "formonly" THEN
			LET nl2 = tmp.selectByPath("//Link")
			FOR x2 = 1 TO nl2.getLength()
				LET tmp2 = nl2.item(x2)
				LET coln = tmp2.getAttribute("colName")
				--DISPLAY "colname:",coln
				LET fldn = tmp2.getAttribute("fieldIdRef")
				CALL tmp2.setAttribute("fieldIdRef",fldn+(pgno*100) )
			END FOR
			CALL gl_appendNode( frm, tmp, 0 )
		END IF
	END FOR

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Dynamically find a folder
#+
#+ @param nam Node of the folder, can be NULL
#+ @return Folder node
FUNCTION gl_findFolder(nam) --{{{
	DEFINE nam STRING
	DEFINE win ui.window
	DEFINE n om.domNode
	DEFINE nl om.nodeList

	LET win = ui.window.getCurrent()
	LET n = win.getNode()
	IF nam IS NOT NULL THEN
		LET nl = n.selectByPath("//Folder[@name='"||nam||"']")
	ELSE
		LET nl = n.selectByPath("//Folder")
	END IF
	IF nl.getLength() < 1 THEN
		RETURN NULL
	END IF
	RETURN nl.item(1)
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Find a folder page.
#+ NOTE: fld or fname need to be supplied, both can't be NULL!
#+
#+ @param folder node of Folder to add pages to. Can be NULL
#+ @param fname name of the Folder ( if fld is NULL )
#+ @param page name of the Page to find
#+ @return Node of page
FUNCTION gl_findPage( folder,fname, page ) --{{{
	DEFINE folder om.DomNode
	DEFINE frm ui.Form
	DEFINE fname, page STRING
	DEFINE nl om.NodeList

	IF folder IS NULL THEN
		LET frm = gl_getForm(NULL)
		LET folder = frm.findNode("Folder",fname.trim())
		IF folder IS NULL THEN
			CALL gl_errMsg(__FILE__,__LINE__,"gl_findPage: Not found Folder '"||fname.trim()||"'!")
			RETURN NULL
		END IF
	END IF

	LET nl = folder.selectByPath("//Page[@name=\""||page.trim()||"\"]")
	IF nl.getLength() != 1 THEN -- not found or too many!!
		CALL gl_errMsg(__FILE__,__LINE__,"gl_findPage: Not found Page '"||page.trim()||"'!")
		RETURN NULL
	END IF

	RETURN nl.item(1)

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Dynamically change title of a page
#+
#+ @param folder Node of the folder, can be NULL
#+ @param fname	Name of the folder, can be NULL only if folder is passed.
#+ @param page	 Name of the page to affected.
#+ @param title	New title for the page.
#+ @return Nothing.
FUNCTION gl_titlePage( folder,fname, page, title) --{{{
	DEFINE folder,n om.DomNode
	DEFINE fname, page, title STRING

	LET n = gl_findPage( folder, fname, page )
	IF n IS NOT NULL THEN
		CALL n.setAttribute("text",title)
	END IF

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Dynamically hide/unhide a page
#+
#+ @param folder Node of the folder, can be NULL
#+ @param fname	Name of the folder, can be NULL only if folder is passed.
#+ @param page	 Name of the page to hide/unhide
#+ @param hide	 TRUE/FALSE = Hide/Unhide
#+ @return Nothing.
FUNCTION gl_hidePage( folder, fname, page, hide) --{{{
	DEFINE folder,n om.DomNode
	DEFINE fname, page STRING
	DEFINE hide SMALLINT

	LET n = gl_findPage( folder, fname, page )
	IF n IS NOT NULL THEN
		CALL n.setAttribute("hidden",hide)
	END IF

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Test to see an action exists at this point in time.
#+
#+ @param nam = Action name
#+ @return true/false.
FUNCTION gl_actionExists( nam ) --{{{
	DEFINE nam STRING
	DEFINE w ui.Window
	DEFINE wn, dn om.domNode
	DEFINE dl om.nodeList
	DEFINE nl om.nodeList
	DEFINE x SMALLINT

	LET w = ui.window.getCurrent()
	LET wn = w.getNode()

	LET dl = wn.selectByPath("//Dialog[@active=\"1\"]")	
	FOR x = 1 TO dl.getLength()
		LET dn = dl.item(x)
		LET nl = dn.selectByPath("//Action[@name=\""||nam.trim()||"\"]")	
		IF nl.getLength() > 0 THEN RETURN TRUE END IF
	END FOR
	LET dl = wn.selectByPath("//Menu[@active=\"1\"]")	
	FOR x = 1 TO dl.getLength()
		LET dn = dl.item(x)
		LET nl = dn.selectByPath("//MenuAction[@name=\""||nam.trim()||"\"]")	
		IF nl.getLength() > 0 THEN RETURN TRUE END IF
	END FOR
	RETURN FALSE
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Dynamically define a live actions properties.
#+
#+ @code 
#+	BEFORE INPUT
#+ 		CALL add_action("D","special","Special","A Special Action","wizard", "F9")
#+
#+ @param typ = CHAR(1): D=dialog / M=MenuAction.
#+ @param nam = String: Name of Action.
#+ @param txt = String: Text for Action - If NULL then action view is hidden - if '*' unhidden.
#+ @param com = String: Comment/Tooltip for Action.
#+ @param img = String: Image for Action.
#+ @param acc = String: acceleratorName.
#+ @return Nothing.
FUNCTION gl_defAction( typ, nam, txt, com, img, acc ) --{{{
	DEFINE typ CHAR(1)
	DEFINE nam, txt, com, img, acc STRING
	DEFINE ret SMALLINT

	IF typ = "D" THEN
		CALL gl_setAttr("Action", nam.trim(), txt.trim(), com.trim(), img.trim(), acc.trim() ) RETURNING ret
	ELSE
		CALL gl_setAttr("MenuAction", nam.trim(), txt.trim(), com.trim(), img.trim(), acc.trim() ) RETURNING ret
	END IF
	IF NOT ret THEN
		GL_DBGMSG(1, "gl_defAction: failed to find '"||nam.trim()||"'!")
	END IF

	CALL gl_setAttr("ToolBarItem", nam.trim(), txt.trim(), com.trim(), img.trim(), NULL ) RETURNING ret
	CALL gl_setAttr("TopMenuCommand", nam.trim(), txt.trim(), com.trim(), img.trim(), NULL ) RETURNING ret
	CALL gl_setAttr("Button", nam.trim(), txt.trim(), com.trim(), img.trim(), NULL ) RETURNING ret

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Set Attributes for a node.
#+
#+ @param typ ToolBarItem / TopMenuCommand / Button / MenuAction / Action
#+ @param nam Name of Action.
#+ @param txt Text for Action - If NULL then action view is hidden - if '*' unhidden.
#+ @param com Comment/Tooltip for Action.
#+ @param img Image for Action.
#+ @param acc acceleratorName.
#+ @return Number of nodes changes.
FUNCTION gl_setAttr( typ, nam, txt, com, img, acc ) --{{{
	DEFINE typ ,nam, txt, com, img, acc STRING
	DEFINE r,n om.DomNode
	DEFINE nl om.nodeList
	DEFINE x SMALLINT

	LET r = ui.interface.getRootNode()
	LET nl = r.selectByPath("//"||typ||"[@name=\""||nam||"\"]")
	IF nl.getLength() < 1 THEN
		GL_DBGMSG(1, "gl_setAttr: not found "||typ||" '"||nam.trim()||"'!")
		RETURN 0
	END IF
	FOR x = 1 TO nl.getLength()
		LET n = nl.item(x)
		GL_DBGMSG(1, "gl_setAttr: found "||typ||" '"||nam.trim()||"'")
		IF txt.trim() IS NULL OR txt = " " THEN
			CALL n.setAttribute("hidden",1)
		ELSE
			IF txt.trim() = "*" THEN
				CALL n.setAttribute("hidden",0)
			ELSE
				CALL n.setAttribute("hidden",0)
				CALL n.setAttribute("text",txt)
			END IF
			IF com IS NOT NULL THEN
				CALL n.setAttribute("comment",com)
			END IF
			IF img IS NOT NULL THEN
				CALL n.setAttribute("image",img)
			END IF
		END IF
		IF acc IS NOT NULL THEN
			CALL n.setAttribute("acceleratorName",acc)
		END IF
	END FOR
	RETURN nl.getLength()

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Find a Node and set an attribute to a value.
#+
#+ @param par			 = Parent Node Tag
#+ @param par_nam	 = Parent Node Name
#+ @param child		 = Child Node Tag
#+ @param child_nam = Child Node Name
#+ @param attr			= Attribute to set
#+ @param val			 = Value to set attribute to
FUNCTION gl_setNodeAtt( par, par_nam, child, child_nam, attr, val ) --{{{
	DEFINE par, par_nam, child, child_nam, attr, val STRING
	DEFINE nl om.NodeList
	DEFINE ui_r, n om.domNode

	LET ui_r = ui.interface.getRootNode()
	LET nl = ui_r.selectByPath("//"||par.trim()||"[@name=\""||par_nam.trim()||"\"]")
	IF nl.getLength() > 0 THEN
		LET n = nl.item(1)
	ELSE
		GL_DBGMSG(1, "gl_setNodeAtt: failed to find parent '"||par.trim()||"' with name '"||par_nam.trim()||"'!")
	END IF
	IF child IS NOT NULL THEN
		LET nl = n.selectByPath("//"||child||"[@name=\""||child_nam.trim()||"\"]")
		LET n = NULL
		IF nl.getLength() > 0 THEN
			LET n = nl.item(1)
		ELSE
			GL_DBGMSG(1, "gl_setNodeAtt: failed to find child'"||child.trim()||"' with name '"||child_nam.trim()||"'!")
		END IF
	END IF

	IF n IS NOT NULL THEN
		CALL n.setAttribute( attr, val )
	END IF
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Set the min and max values for a progress bar.
#+
#+ @param fld = String: tag property on the ProgressBar element.
#+ @param mn	= Integer: Min value
#+ @param mx	= Integer: Max value
#+ @return Nothing.
FUNCTION gl_setProgMinMax( fld, mn, mx ) --{{{
	DEFINE fld STRING
	DEFINE mn, mx INTEGER
	DEFINE nl om.nodeList
	DEFINE n om.DomNode

	LET n = gl_getWinNode( NULL )
	LET nl = n.selectByPath("//ProgressBar[@tag=\""||fld.trim()||"\"]")
	IF nl.getLength() > 0 THEN
		LET n = nl.item(1)
		CALL n.setAttribute("valueMax",mx)
		CALL n.setAttribute("valueMin",mn)
	ELSE
		GL_DBGMSG(1, "gl_setProgMinMax: failed to find '"||fld.trim()||"'!")
	END IF
END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Set the stlye attribute on an element of current form.
#+
#+ @param ele	= String: Elements name attribute.
#+ @param styl = String: Style to set.
#+ @return Nothing.
FUNCTION gl_setElementStyle( ele, styl ) --{{{
	DEFINE ele, styl STRING
	DEFINE frm ui.Form
	DEFINE n om.DomNode
	DEFINE nl om.NodeList

	LET frm = gl_getForm(NULL)
	LET n = frm.getNode()

	LET nl = n.selectByPath("//*[@name=\""||ele||"\"]")
	IF nl.getLength() < 1 THEN
		CALL gl_errMsg(__FILE__,__LINE__,"Failed to setElementStyle for '"||ele||"'!")
		RETURN
	END IF

	LET n = nl.item(1)
	IF n.getTagName() = "FormField" THEN
		LET n = n.getFirstChild()
	END IF
	CALL n.setAttribute("style",styl)

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Populate the named combobox,
#+
#+ @param nam The name of the combobox.
#+ @param val The Value to add - NULL=clear combo ASK!=allow editting of values
#+ @param txt Text value for the item.
#+ @param win Open window you use gl_lookup2 ( not included with dbquery )
#+ @return True / False: Worked / Failed
FUNCTION gl_popCombo(nam, val, txt, win) --{{{
	DEFINE nam,txt,val STRING
	DEFINE win SMALLINT
	DEFINE cb ui.ComboBox
	DEFINE hb,wfrm,frm,g,ff,w,tabl,tabc om.DomNode
	DEFINE x,val_w,txt_w SMALLINT
	DEFINE org,arr DYNAMIC ARRAY OF RECORD
		txt STRING,
		val STRING
	END RECORD

	LET cb = ui.ComboBox.forName(nam)
	IF cb IS NULL THEN
		CALL gl_errMsg(__FILE__,__LINE__,"Failed to find combobox '"||nam||"'!")
		RETURN FALSE
	END IF
	IF val IS NULL THEN
		CALL cb.clear()
		RETURN TRUE
	END IF

	LET int_flag = FALSE
	IF val = "ASK!" THEN
		FOR x = 1 TO cb.getItemCount()
			LET arr[x].val = cb.getItemName(x)
			LET arr[x].txt = cb.getItemText(x)
			LET org[x].val = cb.getItemName(x)
			LET org[x].txt = cb.getItemText(x)
			IF arr[x].val.getLength() > val_w THEN LET val_w = arr[x].val.getLength() END IF
			IF arr[x].val.getLength() > txt_w THEN LET txt_w = arr[x].txt.getLength() END IF
		END FOR
		IF win THEN
			OPEN WINDOW popcombo WITH 1 ROWS,1 COLUMNS ATTRIBUTES(TEXT="New ComboBox Item", STYLE="dialog")
-- Get window object and create a form
			LET wfrm = gl_genForm("popcombo")
		ELSE
&ifdef FULLLIBRARY
			LET wfrm = gl_lookup2_open()
&endif
		END IF
-- create the grid, label, formfield and edit nodes.
		LET frm = wfrm.createChild('VBox')
		LET g = frm.createChild('Grid')
		CALL g.setAttribute("height","4")
		CALL g.setAttribute("width","50")
		CALL gl_addLabel(g, 1,2,"Display Value:",NULL,NULL)
		LET ff = g.createChild('FormField')
		CALL ff.setAttribute("colName","txt")
		LET w = ff.createChild("Edit")
		CALL w.setAttribute("width",20)
		CALL w.setAttribute("posX","20")
		CALL w.setAttribute("posY",2)

		CALL gl_addLabel(g, 1,3,"Return Value:",NULL,NULL)
		LET ff = g.createChild('FormField')
		CALL ff.setAttribute("colName","val")
		LET w = ff.createChild("Edit")
		CALL w.setAttribute("width",20)
		CALL w.setAttribute("posX",20)
		CALL w.setAttribute("posY",3)

		LET hb = frm.createChild('HBox')
		LET g = hb.createChild('Grid')
		LET tabl = g.createChild("Table")
		CALL tabl.setAttribute("tabName","comboarr")
		CALL tabl.setAttribute("height",arr.getLength()+1)
		CALL tabl.setAttribute("pageSize",arr.getLength()+1)
		CALL tabl.setAttribute("posX",1)
		CALL tabl.setAttribute("posY",6)
		LET tabc = tabl.createChild('TableColumn')
		CALL tabc.setAttribute("colName","txt")
		CALL tabc.setAttribute("text","Text")
		LET w = tabc.createChild('Edit')
		CALL w.setAttribute("width",txt_w)
		LET tabc = tabl.createChild('TableColumn')
		CALL tabc.setAttribute("colName","val")
		CALL tabc.setAttribute("text","Value")
		LET w = tabc.createChild('Edit')
		CALL w.setAttribute("width",val_w)

		LET g = hb.createChild('Grid')
		LET w = g.createChild("Button")
		CALL w.setAttribute("posX",10)
		CALL w.setAttribute("posY",7)
		CALL w.setAttribute("name","add")
		CALL w.setAttribute("text","Add")

		LET w = g.createChild("Button")
		CALL w.setAttribute("posX",10)
		CALL w.setAttribute("posY",8)
		CALL w.setAttribute("name","clear")
		CALL w.setAttribute("text","Clear Combobox")

		LET w = g.createChild("Button")
		CALL w.setAttribute("posX",10)
		CALL w.setAttribute("posY",9)
		CALL w.setAttribute("name","closewin")
		CALL w.setAttribute("text","Close Window")

		DISPLAY ARRAY arr TO comboarr.* ATTRIBUTE( COUNT=arr.getLength() )
			BEFORE DISPLAY EXIT DISPLAY
		END DISPLAY
		INPUT BY NAME txt,val ATTRIBUTES(UNBUFFERED)
			BEFORE INPUT
				CALL DIALOG.setActionHidden("cancel",1)
				CALL DIALOG.setActionHidden("accept",1)
				CALL DIALOG.setActionActive("accept",0)
			ON ACTION closewin
				EXIT INPUT
			ON ACTION add
				IF gl_addCombo( cb, val, txt) THEN
					LET arr[ arr.getLength() + 1 ].val = val
					LET arr[ arr.getLength() ].txt = txt
					CALL tabl.setAttribute("height",arr.getLength())
					CALL tabl.setAttribute("pageSize",arr.getLength())
					CALL ui.interface.refresh()
					DISPLAY ARRAY arr TO comboarr.* ATTRIBUTE( COUNT=arr.getLength() )
						BEFORE DISPLAY EXIT DISPLAY
					END DISPLAY
				END IF
			ON ACTION clear
				CALL cb.clear()
				CALL arr.clear()
				DISPLAY ARRAY arr TO comboarr.* ATTRIBUTE( COUNT=arr.getLength() )
					BEFORE DISPLAY EXIT DISPLAY
				END DISPLAY
			AFTER FIELD val
				NEXT FIELD txt
		END INPUT
		IF int_flag THEN -- restore combo.
			CALL cb.clear()
			FOR x = 1 TO org.getLength()
				IF gl_addCombo( cb, org[x].val, org[x].txt) THEN
				-- Shouldn't fail
				END IF
			END FOR
			IF win THEN 
				CLOSE WINDOW popcombo
			ELSE
&ifdef FULLLIBRARY
				CALL gl_lookup2_close(wfrm)
&endif
			END IF
			MESSAGE "Aborted."
			RETURN FALSE
		END IF
		IF win THEN 
			CLOSE WINDOW popcombo
		ELSE
&ifdef FULLLIBRARY
			CALL gl_lookup2_close(wfrm)
&endif
		END IF
	ELSE
		RETURN gl_addCombo(cb, val, txt )
	END IF
	RETURN TRUE

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Populate the named combo box - checks to see if item already exists.
#+
#+ @param cb The Combobox object
#+ @param val The value - ie return value for item.
#+ @param txt The Text - ie display text for the item.
#+ @return True / False: Worked / Failed
FUNCTION gl_addCombo(cb, val, txt) --{{{
	DEFINE txt,val STRING
	DEFINE cb ui.ComboBox
	DEFINE x SMALLINT

	IF cb IS NULL THEN RETURN FALSE END IF
	FOR x = 1 TO cb.getItemCount()
		IF val = cb.getItemName(x) THEN
			ERROR "Value already exists in combobox."
			RETURN FALSE
		END IF
		IF txt = cb.getItemText(x) THEN
			ERROR "Text already exists in combobox."
			RETURN FALSE
		END IF
	END FOR
	CALL cb.addItem( val.trim(), txt.trim() )
	RETURN TRUE

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Add a label to a grid/group with a name
#+
#+ @param g Node of the Grid or Group
#+ @param x X position
#+ @param y Y position
#+ @param txt Text for label
#+ @param nam Name for label.
#+ @param j Justify : NULL, center or right
#+ @param s Style.
#+ @return TRUE/FALSE.	Success / Failed
FUNCTION gl_addLabelN(g,x,y,txt,nam,j,s) --{{{
	DEFINE g,l om.domNode
	DEFINE txt,nam,j,s STRING
	DEFINE x,y SMALLINT

	LET l = g.createChild("Label")
	CALL l.setAttribute("posX",x)
	CALL l.setAttribute("posY",y)
	CALL l.setAttribute("text",txt)
	IF nam IS NOT NULL THEN
		CALL l.setAttribute("name",nam)
	END IF
	IF j IS NOT NULL THEN
		CALL l.setAttribute("justify",j)
	END IF
	IF s IS NOT NULL THEN
		CALL l.setAttribute("style",s)
	END IF

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Add a RadioGroup to the 'win' or and 'grid/group' passed
#+
#+ @param l_winnam = String: name of Window - NULL = Current
#+ @param l_grptyp = String: name of group or grid to add to
#+ @param l_grpnam = String: name of field - for input.
#+ @param l_com = String: Comment
#+ @param l_ori = char 1: H or V - "horizontal" or "vertical"
#+ @return Node of radiogroup
FUNCTION gl_newRadio( l_winnam, l_grptyp, l_grpnam, l_nam, l_com, l_ori ) --{{{
	DEFINE l_winnam, l_grptyp, l_grpnam, l_nam, l_com STRING
	DEFINE l_ori CHAR(1)
	DEFINE l_frm ui.Form
	DEFINE l_grp,l_ff,l_rad om.domNode
	DEFINE l_h SMALLINT

	LET l_frm = gl_getForm( l_winnam )
	LET l_grp = l_frm.findNode(l_grptyp,l_grpnam)
	IF l_grp IS NULL THEN
		CALL gl_errMsg(__FILE__,__LINE__,"Failed to find "||l_grptyp||" of name '"||l_grpnam||"'!")
		RETURN NULL
	END IF
	LET l_h = l_grp.getAttribute("gridHeight")
	IF l_h IS NULL THEN LET l_h = l_grp.getAttribute("height") END IF

	LET l_ff = l_grp.createChild("FormField")
	CALL l_ff.setAttribute("name","formonly."||l_nam)
	CALL l_ff.setAttribute("colName",l_nam)
	LET l_rad = l_ff.createChild("RadioGroup")
	CASE l_ori
		WHEN "H" CALL l_rad.setAttribute("orientation","horizontal")
		WHEN "V" CALL l_rad.setAttribute("orientation","vertical")
	END CASE
	CALL l_rad.setAttribute("posX","1")
	IF l_h IS NOT NULL THEN
		CALL l_rad.setAttribute("posY",l_h)
	END IF
	IF l_com IS NOT NULL THEN CALL l_rad.setAttribute("comment",l_com) END IF
	
	RETURN l_rad

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Repopulate a radio group item list.
#+
#+ @code gl_popRadio("formonly.print_dest","1|2|3|4","File|Screen|PDF|Print")
#+ @param fnam form name e.g. formonly.print_dest
#+ @param namval name attributes, pipe delimited.
#+ @param txtval text attributes, pipe delimited.
FUNCTION gl_popRadio(fnam,namval,txtval)
	DEFINE fnam, namval, txtval STRING
	DEFINE st,st1 base.StringTokenizer
	DEFINE w ui.Window
	DEFINE n ,n1 om.DomNode
	
	LET w = ui.Window.getCurrent()
	LET n1 = w.findNode("FormField",fnam)
	IF n1 IS NULL THEN
		CALL gl_winMessage("Error","gl_popRadio: Failed to find '"||fnam||"'","exclamation")
		RETURN
	END IF
	LET n = n1.getFirstChild() -- Get the RadioGroup widget.
	IF n.getTagName() != "RadioGroup" THEN
		CALL gl_winMessage("Error","gl_popRadio: '"||fnam||"' is not a RadioGroup","exclamation")
		RETURN
	END IF

-- Remove current Item list
	LET n1 = n.getFirstChild() -- get Item
	WHILE n1 IS NOT NULL
		CALL n.removeChild(n1)
		LET n1 = n.getFirstChild() -- get Item
	END WHILE

-- Create the new list of Items.
	LET st = base.StringTokenizer.create(namval,"|")
	LET st1 = base.StringTokenizer.create(txtval,"|")
	WHILE st.hasMoreTokens()
		LET n1 = n.createChild("Item")
		CALL n1.setAttribute("name",st.nextToken() )
		CALL n1.setAttribute("text",st1.nextToken() )
	END WHILE
	
END FUNCTION

--------------------------------------------------------------------------------
#+ Add defaults colours and fonts to stylelist
#+
#+ uses ../etc/colours.txt
FUNCTION gl_addStyles(	) --{{{
	DEFINE c Base.Channel
	DEFINE fname STRING
	DEFINE ret, x SMALLINT
	DEFINE colours DYNAMIC ARRAY OF RECORD
			def CHAR(1),
			colName STRING,
			colCode STRING,	
			colDesc STRING
		END RECORD
	DEFINE colourFile BOOLEAN

	LET c = base.Channel.create()
	LET fname = ".."||os.path.separator()||"etc"||os.path.separator()||"colours.txt"
	IF NOT os.path.exists(fname) THEN
		LET fname = "."||os.path.separator()||"etc"||os.path.separator()||"colours.txt"
	END IF
	TRY
		CALL c.openFile(fname,"r")
		LET colourFile = TRUE
	CATCH
		LET colourFile = FALSE
--		CALL gl_winMessage("Error","Failed to open 'colours.txt'","exclamation")
	END TRY

	IF colourFile THEN
		CALL c.setDelimiter("|")
		WHILE NOT c.isEof()
			LET ret = c.read( [colours[ colours.getLength() + 1 ].*] )
			LET x = colours.getLength()
			IF colours[x].colName IS NOT NULL THEN
				IF colours[x].def = 1 THEN
					CALL gl_addStyle2("."||colours[x].colName, "textColor",colours[x].colName)
					CALL gl_addStyle2(".bg_"||colours[x].colName, "backgroundColor",colours[x].colName)
				ELSE
					CALL gl_addStyle2("."||colours[x].colName, "textColor",colours[x].colCode)
					CALL gl_addStyle2(".bg_"||colours[x].colName, "backgroundColor",colours[x].colCode)
				END IF
			END IF
		END WHILE
		CALL c.close()
		GL_DBGMSG(1, "gl_addStyles: Add colours from colours.txt!")
	ELSE
		GL_DBGMSG(0, "gl_addStyles: No colours.txt!")
	END IF

	CALL gl_addStyle2(".defsettigns", "forceDefaultSettings","1")
	CALL gl_addStyle2("Image.browser", "imageContainerType","browser")
	CALL gl_addStyle2(".html", "textFormat","html")
	CALL gl_addStyle2(".noborder", "border","none")
	CALL gl_addStyle2(".bold", "fontWeight","bold")
	CALL gl_addStyle2(".notbold", "fontWeight","normal")
	CALL gl_addStyle2(".fixed", "fontFamily","'Courier New'")
	CALL gl_addStyle2(".font1em", "fontSize","1em")
	CALL gl_addStyle2(".font-1", "fontSize",".9em")
	CALL gl_addStyle2(".font-2", "fontSize",".8em")
	CALL gl_addStyle2(".font-3", "fontSize",".7em")
	CALL gl_addStyle2(".font-4", "fontSize",".6em")
	CALL gl_addStyle2(".font-5", "fontSize",".5em")
	CALL gl_addStyle2(".font-6", "fontSize",".4em")
	CALL gl_addStyle2(".font+1", "fontSize","1.1em")
	CALL gl_addStyle2(".font+2", "fontSize","1.2em")
	CALL gl_addStyle2(".font+3", "fontSize","1.3em")
	CALL gl_addStyle2(".font+4", "fontSize","1.4em")
	CALL gl_addStyle2(".font+5", "fontSize","1.5em")
	CALL gl_addStyle2(".font+6", "fontSize","1.6em")
END FUNCTION --}}}
--------------------------------------------------------------------------------
FUNCTION gl_addStyle2(nam,att,val)
	DEFINE nam, att, val STRING
	DEFINE l_aui, n_s, n_a om.DomNode
	DEFINE nl_s om.NodeList

	IF m_styleList IS NULL THEN
		LET l_aui = ui.interface.getRootNode()
		LET nl_s = l_aui.selectByTagName("StyleList")
		LET m_styleList = nl_s.item(1)
	END IF
	IF m_styleList IS NULL THEN
		CALL gl_winMessage("Error","No StyleList!!!","exclamation")
		RETURN
	END IF

	LET n_s = m_styleList.createChild("Style")
	CALL n_s.setAttribute("name",nam)
	LET n_a = n_s.createChild("StyleAttribute")
	CALL n_a.setAttribute("name",att)
	CALL n_a.setAttribute("value",val)
END FUNCTION
----------------------------------------------------------------------------------
#+ Dump the ui to a file
#+
#+ @param file File name to dump the ui to.
#+
#+ @return none
FUNCTION gl_dumpUI( l_file STRING ) --{{{
	DEFINE n om.domNode
	LET n = ui.interface.getRootNode()
	CALL n.writeXML( l_file )
END FUNCTION --}}}
----------------------------------------------------------------------------------
#+ Dump the styles to a file
#+
#+ @param file File name to dump the ui to.
#+
#+ @return none
FUNCTION gl_dumpStyles( l_file STRING ) --{{{
	DEFINE n om.domNode
	DEFINE nl om.NodeList
	LET n = ui.interface.getRootNode()
	LET nl = n.selectByTagName("StyleList")
	LET n = nl.item(1)
	CALL n.writeXML( l_file )
END FUNCTION --}}}
----------------------------------------------------------------------------------
#+ Change exec line of a start menu command ( use name="?" in the .4sm )
#+
#+ @param nam Name
#+ @param args New Args
FUNCTION gl_chgArgs(nam, args) --{{{
	DEFINE nam,args,ex STRING
	DEFINE sm om.domNode
	DEFINE nl om.nodeList

	LET sm = ui.interface.getRootNode()

	LET nl = sm.selectByPath("//StartMenuCommand[@name=\""||nam||"\"]")
	IF nl.getLength() < 1 THEN
		CALL gl_errMsg(__FILE__,__LINE__,"Failed to find the item '"||nam||"'!")
		RETURN
	END IF

	LET sm = nl.item(1)
	LET ex = sm.getAttribute("exec")
	CALL sm.setAttribute("exec",ex||" "||args)

END FUNCTION --}}}
----------------------------------------------------------------------------------
#+ Generate a Strings file for use with localized strings.
#+
#+ @param nam file name to output to.
FUNCTION gl_genStrs(nam) --{{{
	DEFINE nam STRING
	DEFINE fil base.Channel
	DEFINE add om.DomDocument
	DEFINE r, adl, n, act om.domNode
	DEFINE nl,nl2,nl3 om.nodeList
	DEFINE tg,nm,tx,cm STRING
	DEFINE x,x1,y SMALLINT

	LET fil = base.Channel.create()
	CALL fil.openFile(nam||".str","w")

	GL_DBGMSG(1, "gl_genStrs: Processing ActionDefaults")
	LET r = ui.interface.getRootNode()
	LET add = om.DomDocument.create("ActionDefaultList")
	LET adl = add.getDocumentElement()

	LET nl = r.selectByPath("//ActionDefault")
	FOR x = 1 TO nl.getLength()
		LET act = nl.item(x)
		LET nm = act.getAttribute("name")
		LET tx = act.getAttribute("text")
		LET cm = act.getAttribute("comment")
		IF tx IS NOT NULL THEN CALL fil.writeLine('"action.'||nm||'" = "'||tx||'"') END IF
		IF cm IS NOT NULL THEN CALL fil.writeLine('"comment.'||nm||'" = "'||cm||'"') END IF
		LET n = adl.createChild("ActionDefault")
		FOR y = 1 TO act.getAttributesCount()
			CALL n.setAttribute(act.getAttributeName(y),act.getAttributeValue(y))
		END FOR
		IF tx IS NOT NULL OR cm IS NOT NULL THEN
			LET n = n.createChild("LStr")
			IF tx IS NOT NULL THEN CALL n.setAttribute("text","action."||nm) END IF
			IF cm IS NOT NULL THEN CALL n.setAttribute("comment","comment."||nm) END IF
		END IF
	END FOR
	CALL adl.writeXml(nam||".4ad")

	GL_DBGMSG(1, "gl_genStrs: Processing TopMenus")
	LET nl = r.selectByPath("//TopMenu")
	FOR x = 1 TO nl.getLength()
		LET n = nl.item(x)
		GL_DBGMSG(1, "gl_genStrs: topmenu "||x)
		LET add = om.DomDocument.createFromXmlFile( n.getAttribute("fileName") )
		IF add IS NULL THEN CONTINUE FOR END IF
		LET adl = add.getDocumentElement()
		LET nl2 = adl.selectByPath("//TopMenuGroup")
		GL_DBGMSG(1, "gl_genStrs: topmenu items "||nl.getLength() )
		FOR x1 = 1 TO nl2.getLength()
			LET act = nl2.item(x1)
			LET nm = act.getAttribute("name")
			LET tx = act.getAttribute("text")
			IF nm IS NOT NULL AND tx IS NOT NULL THEN
				LET n = act.getFirstChild()
				IF n IS NULL THEN
					CALL fil.writeLine('"'||tg.toLowerCase()||'.'||nm||'" = "'||tx||'"')
					LET n = act.createChild("LStr")
					CALL n.setAttribute("text",tg.toLowerCase()||"."||nm)
				END IF
			END IF
		END FOR
		LET nl2 = adl.selectByPath("//TopMenuCommand")
		FOR x1 = 1 TO nl2.getLength()
			LET act = nl2.item(x1)
			LET tx = act.getAttribute("text")
			LET nm = act.getAttribute("name")
			LET nl3 = r.selectByPath("//ActionDefault[@name=\""||nm||"\"]")
			IF nl3.getLength() > 0 THEN
				IF tx IS NOT NULL THEN CALL act.removeAttribute("text") END IF
			ELSE
				GL_DBGMSG(0, "gl_genStrs: WARNING: Action '"||nm||"' not in .4ad")
			END IF
		END FOR
		CALL adl.writeXml("menu"||x||".4tm")
	END FOR

	CALL fil.close()

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Merge the default style file with a custom one.
#+
#+ @param l_nam Name of the custom style file to merge
#+
#+ @return Nothing
FUNCTION gl_mergeST( l_nam STRING ) --{{{
	DEFINE nam1,snam,anam,oval,nval STRING
	DEFINE x,y SMALLINT
	DEFINE d_ns om.domDocument
	DEFINE n_ns om.domNode
	DEFINE n_sa om.domNode
	DEFINE nl_ns om.nodeList
	DEFINE nl_sa om.nodeList
	DEFINE d_ns_aui om.domDocument
	DEFINE n_sl_aui om.domNode
	DEFINE n_sa_aui om.domNode
	DEFINE n_ns_aui om.domNode
	DEFINE nl_ns_aui om.nodeList
	DEFINE nl_sa_aui om.nodeList

	LET l_nam = l_nam.trim().append(".4st")
	LET d_ns = om.domDocument.createFromXMLFile(l_nam)
	IF d_ns IS NULL THEN
		CALL gl_winMessage("Error",SFMT(%"Failed to read '%1'.",l_nam),"exclamation")
		RETURN
	END IF

	LET d_ns_aui = ui.interface.getDocument()
	LET n_sl_aui = ui.interface.getRootNode()	
	LET nl_ns_aui = n_sl_aui.selectByTagName("StyleList")
	IF nl_ns_aui.getLength() < 1 THEN
		CALL gl_winMessage("Error",%"No default Styles found!","exclamation")
		RETURN
	END IF
	LET n_sl_aui = nl_ns_aui.item(1)
	LET nam1 = n_sl_aui.getAttribute("fileName")
	GL_DBGMSG(3,"Default Style: "||nam1||" New Styles:"||l_nam)

	LET n_ns = d_ns.getDocumentElement()
	LET nl_ns = n_ns.selectByTagName("Style")			
	IF nl_ns.getLength() < 1 THEN
		CALL gl_winMessage("Error",SFMT(%"No Styles in '%1'.",l_nam),"exclamation")
		RETURN
	END IF

	FOR x = 1 TO nl_ns.getLength()
		LET n_ns = nl_ns.item(x)
		LET snam = n_ns.getAttribute("name")
		LET nl_ns_aui = n_sl_aui.selectByPath("//Style[@name='"||snam||"']")
		IF nl_ns_aui.getLength() = 0 THEN
			GL_DBGMSG(3, "Added :"||snam)
			LET n_ns_aui = d_ns_aui.copy( n_ns, TRUE )
			CALL n_sl_aui.appendChild( n_ns_aui )
		ELSE
			-- Process StyleAttribute nodes
			LET n_ns_aui = nl_ns_aui.item(1)
			GL_DBGMSG(3, "Exists:"||snam)
			LET nl_sa = n_ns.selectByTagName("StyleAttribute")			
			FOR y = 1 TO nl_sa.getLength()
				LET n_sa = nl_sa.item(y)
				LET anam = n_sa.getAttribute("name")
				LET nval = n_sa.getAttribute("value")
				LET nl_sa_aui = n_ns_aui.selectByPath("//StyleAttribute[@name='"||anam||"']")
				IF nl_sa_aui.getLength() > 0 THEN
					LET n_sa_aui = nl_sa_aui.item(1)
					LET oval = n_sa_aui.getAttribute("value")
					IF nval != oval THEN
						GL_DBGMSG(3, "Update:"||snam||" : "||anam||" Updated Old:"||oval||" New:"||nval)
					ELSE
						GL_DBGMSG(3, "Okay	:"||snam||" : "||anam)
					END IF
				ELSE
					GL_DBGMSG(3, "Update:"||snam||" : "||anam||" Added New:"||nval)
					LET n_sa_aui = n_ns_aui.createChild("StyleAttribute")
				END IF
				CALL n_sa_aui.setAttribute("name",anam)				
				CALL n_sa_aui.setAttribute("value",nval)				
			END FOR
		END IF
	END FOR

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Merge the default Actiona file with a custom one.
#+
#+ @param l_nam Name of custom Actions file to merge
#+
#+ @return Nothing
FUNCTION gl_mergeAD( l_nam STRING ) --{{{
	DEFINE nam1,snam,anam,oval,nval STRING
	DEFINE x,y SMALLINT
	DEFINE d_na om.domDocument
	DEFINE n_na om.domNode
	DEFINE nl_na om.nodeList
	DEFINE d_na_aui om.domDocument
	DEFINE n_al_aui om.domNode
	DEFINE n_na_aui om.domNode
	DEFINE nl_na_aui om.nodeList

	LET l_nam = l_nam.trim().append(".4ad")
	LET d_na = om.domDocument.createFromXMLFile(l_nam)
	IF d_na IS NULL THEN
		CALL gl_winMessage("Error",SFMT(%"Failed to read '%1'.",l_nam),"exclamation")
		RETURN
	END IF

	LET d_na_aui = ui.interface.getDocument()
	LET n_al_aui = ui.interface.getRootNode()	
	LET nl_na_aui = n_al_aui.selectByTagName("ActionDefaultList")
	IF nl_na_aui.getLength() < 1 THEN
		CALL gl_winMessage("Error",%"No default Actions found!","exclamation")
		RETURN
	END IF
	LET n_al_aui = nl_na_aui.item(1)
	LET nam1 = n_al_aui.getAttribute("fileName")
	GL_DBGMSG(3, "Default Actions: "||nam1|| " New Actions:"||l_nam)

	LET n_na = d_na.getDocumentElement()
	LET nl_na = n_na.selectByTagName("ActionDefault")			
	IF nl_na.getLength() < 1 THEN
		CALL gl_winMessage("Error",SFMT(%"No ActionDefault in '%1'.",l_nam),"exclamation")
		RETURN
	END IF

	FOR x = 1 TO nl_na.getLength()
		LET n_na = nl_na.item(x)
		LET snam = n_na.getAttribute("name")
		LET nl_na_aui = n_al_aui.selectByPath("//ActionDefault[@name='"||snam||"']")
		IF nl_na_aui.getLength() = 0 THEN
			GL_DBGMSG(3, "Added :"||snam)
			LET n_na_aui = d_na_aui.copy( n_na, TRUE )
			CALL n_al_aui.appendChild( n_na_aui )
		ELSE
			LET n_na_aui = nl_na_aui.item(1)
			-- Process Attribute values
			FOR y = 1 TO n_na.getAttributesCount()
				LET anam = n_na.getAttributeName(y)
				IF anam = "name" THEN CONTINUE FOR END IF
				LET nval = n_na.getAttributeValue(y)
				LET oval = n_na_aui.getAttribute(anam)
				IF oval IS NOT NULL THEN
					IF nval != oval THEN
						GL_DBGMSG(3, "Update:"||snam||" : "||anam||" Updated Old:"||oval||" New:"||nval)
					ELSE
						GL_DBGMSG(3, "Okay	:"||snam||" : "||anam)
					END IF
				ELSE
					GL_DBGMSG(3, "Update:"||snam||" : "||anam||" Added New:"||nval)
				END IF
				CALL n_na_aui.setAttribute(anam,nval)				
			END FOR
		END IF
	END FOR

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Help Window -- NOT WRITTEN YET!!
#+
#+ @param msgno No of help message to display.
#+ @return Nothing.
FUNCTION gl_help( l_msgno SMALLINT ) --{{{
	DEFINE helptext CHAR(500)
	DEFINE helpstring STRING
	DEFINE winnode, frm, g, frmf, txte om.DomNode

-- NOTE: this is Informix Specific!!
	WHENEVER ERROR CONTINUE
	SELECT COUNT(*) FROM helptexts
	IF STATUS != 0 THEN
		CREATE TABLE helptexts (
			message_no SERIAL,
			help_text CHAR(500)
		)
	END IF
	WHENEVER ERROR STOP

	SELECT help_text INTO helptext FROM helptexts WHERE message_no = msgno
	IF STATUS = NOTFOUND THEN
		CALL gl_winMessage("Help","Sorry, help message "||l_msgno||" not found.","info")
		RETURN
	END IF

	OPEN WINDOW help WITH 1 ROWS, 1 COLUMNS
	LET winnode = gl_getWinNode(NULL)
	CALL winnode.setAttribute("style","naked")
	CALL winnode.setAttribute("width",80)
	CALL winnode.setAttribute("height",20)
	CALL winnode.setAttribute("text","Help Message - "||l_msgno)
	LET frm = gl_genForm("help")

	LET g = frm.createChild('Grid')
	CALL g.setAttribute("width",80)
	CALL g.setAttribute("height",20)

	LET frmf = g.createChild('FormField')
	CALL frmf.setAttribute("colName","helpstring")
	LET txte = frmf.createChild('TextEdit')
	CALL txte.setAttribute("gridWidth",80)
	CALL txte.setAttribute("gridHeight",20)

	CALL ui.interface.refresh()

	LET helpstring = helptext CLIPPED
	DISPLAY "Help:",helpstring.trim()
	DISPLAY BY NAME helpstring

	MENU COMMAND "close" EXIT MENU END MENU

	CLOSE WINDOW help

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ Help Window - Display help message from URL
#+ Needs the style to exist:
#+ @code	 <Style name="Image.browser">
#+ @code		<StyleAttribute name="imageContainerType" value="browser" />
#+ @code	</Style>
#+
#+ @param url url to display.
#+ @return Nothing.
FUNCTION gl_helpURL( l_url STRING ) --{{{
	DEFINE winnode, frm, g, frmf, txte om.DomNode

	OPEN WINDOW help WITH 1 ROWS, 1 COLUMNS
	LET winnode = gl_getWinNode(NULL)
	CALL winnode.setAttribute("style","naked")
	CALL winnode.setAttribute("width",80)
	CALL winnode.setAttribute("height",20)
	CALL winnode.setAttribute("text","Help Message - "||l_url)
	LET frm = gl_genForm("help")

	LET g = frm.createChild('Grid')
	CALL g.setAttribute("width",80)
	CALL g.setAttribute("height",20)

	LET frmf = g.createChild('FormField')
	CALL frmf.setAttribute("colName","l_url")
	LET txte = frmf.createChild('Image')
	CALL txte.setAttribute("gridWidth",80)
	CALL txte.setAttribute("gridHeight",20)
	CALL txte.setAttribute("style","browser")
	CALL ui.interface.refresh()

	DISPLAY BY NAME l_url

	MENU COMMAND "close" EXIT MENU END MENU

	CLOSE WINDOW help

END FUNCTION --}}}
--------------------------------------------------------------------------------
#+ A Simple Prompt function
#+
#+ @code LET tmp = gl_prompt("A Simple Prompt","Enter a value","C",5,NULL)
#+
#+ @param win_tit Window Title
#+ @param prmpt_txt Label text
#+ @param prmpt_typ Data type for prompt C=char D=date
#+ @param prmpt_sz Size of field for entry.
#+ @param prmpt_def Default value ( can be NULL )
#+ @return Char(50): Entered value.
FUNCTION gl_prompt(win_tit, prmpt_txt, prmpt_typ, prmpt_sz, prmpt_def) --{{{
	DEFINE win_tit, prmpt_txt,prmpt_def STRING
	DEFINE prmpt_typ CHAR(1)
	DEFINE prmpt_sz SMALLINT
	DEFINE frm,g om.DomNode
	DEFINE fldnam,wgt STRING
	DEFINE tmp CHAR(50)
	DEFINE tmp_date DATE

-- setup field name
	CASE prmpt_typ
		WHEN "D"
			LET tmp_date = prmpt_def
			LET fldnam = "tmp_date"
		OTHERWISE
			LET tmp = prmpt_def
			LET fldnam = "tmp"
	END CASE

	OPEN WINDOW myprompt WITH 1 ROWS,1 COLUMNS ATTRIBUTES(TEXT=win_tit, STYLE="dialog")

-- Get window object and create a form
	LET frm = gl_genForm("myprompt")

-- create the grid, label, formfield and edit/dateedit nodes.
	LET g = frm.createChild('Grid')
	CALL g.setAttribute("height","4")
	CALL g.setAttribute("width","50")
	IF prmpt_typ = "D" THEN
		LET wgt = "DateEdit"
	ELSE
		LET wgt = "Edit"
	END IF
	CALL gl_addLabel(g, 1,2,prmpt_txt,NULL,NULL)
	CALL gl_addField(g,20,2,wgt,fldnam,prmpt_sz,NULL,NULL,NULL)

-- do the input.
	CASE prmpt_typ
		WHEN "D"
			INPUT BY NAME tmp_date WITHOUT DEFAULTS
			LET tmp = tmp_date
		OTHERWISE
			INPUT BY NAME tmp WITHOUT DEFAULTS
	END CASE
	IF int_flag THEN LET tmp = NULL END IF

	CLOSE WINDOW myprompt
	RETURN tmp

END FUNCTION --}}}
