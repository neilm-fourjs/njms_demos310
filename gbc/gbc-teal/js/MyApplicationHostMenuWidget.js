/// FOURJS_START_COPYRIGHT(D,2015)
/// Property of Four Js*
/// (c) Copyright Four Js 2015, 2017. All Rights Reserved.
/// * Trademark of Four Js Development Tools Europe Ltd
///   in the United States and elsewhere
/// 
/// This file can be modified by licensees according to the
/// product manual.
/// FOURJS_END_COPYRIGHT

"use strict";

modulum('MyApplicationHostMenuWidget', ['ApplicationHostMenuWidget', 'WidgetFactory'],
  /**
   * @param {gbc} context
   * @param {classes} cls
   */
  function(context, cls) {

    /**
     * @class classes.MyApplicationHostMenuWidget
     * @extends classes.ApplicationHostMenuWidget
     */
    cls.MyApplicationHostMenuWidget = context.oo.Class(cls.ApplicationHostMenuWidget, function($super) {
      /** @lends classes.MyApplicationHostMenuWidget.prototype */
      return {
        __name: "MyApplicationHostMenuWidget",

        constructor: function() {
          $super.constructor.call(this);

          // Hide the about menu
          this._aboutMenu.setHidden(true);
        },

        setText: function(title) {
          // Customize title widget
          var titleElement = this._element.querySelector(".currentDisplayedWindow");
          if (title) {
            titleElement.textContent = " - " + title + " - ";
          } else {
            titleElement.textContent = " - " + this._defaultTitle + " - ";
          }
        }
      };
    });

    /*
     *  This is a sample widget that would replace the default one in GBC
     *  To activate it, please uncomment the line below. This will override
     *  the original widget registration to this one.
     */

    // cls.WidgetFactory.register('ApplicationHostMenu', cls.MyApplicationHostMenuWidget);
  });
