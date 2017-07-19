/// FOURJS_START_COPYRIGHT(D,2015)
/// Property of Four Js*
/// (c) Copyright Four Js 2015, 2016. All Rights Reserved.
/// * Trademark of Four Js Development Tools Europe Ltd
///   in the United States and elsewhere
/// 
/// This file can be modified by licensees according to the
/// product manual.
/// FOURJS_END_COPYRIGHT

"use strict";

modulum('MyLabelWidget_stat', ['LabelWidget', 'WidgetFactory'],
  function(context, cls) {
    /**
     * My Label widget.
     * @class classes.MyLabelWidget_stat
     * @extends classes.LabelWidget
     */
    cls.MyLabelWidget_stat = context.oo.Class(cls.LabelWidget, function($super) {
      /** @lends classes.MyLabelWidget_stat.prototype */
      return {
        __name: "MyLabelWidget_stat",
				// using default LabelWidget template!
				__templateName: "LabelWidget",

        /**
         * @param {string} value sets the value to display
         */
        setValue: function(value) {
          // your code here
            
          // Call the parent class setValue function.
          $super.setValue.call(this,value);
            
          // Set the text in the ApplicationHost bar.
          //context.HostService.getApplicationHostWidget().getMenu().setText( value );
        
          // Get the modelHelper.
          var modelhelper=new cls.ModelHelper( this );
          // Use the modelHelper to get the ToolBar node by first getting the Window Anchor node, then the form, then the toolbar
          var toolbarnode = modelhelper.getAnchorNode().getAncestor("Window").getFirstChild("Form").getFirstChild("ToolBar");

          // Get the tag attribute of the AUI object for this Label;
          var tag = modelhelper.getAnchorNode().getFirstChild("Label").attribute("tag");
          if ( tag == "user") {
            // now we get the controller for the toolbar node, then it's widget, then we can call our custom function.
            toolbarnode.getController().getWidget().setWebOEUser( value );
          };
          if ( tag == "status") {
            // now we get the controller for the toolbar node, then it's widget, then we can call our custom function.
            toolbarnode.getController().getWidget().setWebOEStat( value );
          };
        }

      };
    });
    cls.WidgetFactory.register('Label', 'gbc_status', cls.MyLabelWidget_stat);
  });
