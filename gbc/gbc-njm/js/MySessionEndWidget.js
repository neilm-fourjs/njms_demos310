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

modulum('MySessionEndWidget', ['WidgetBase', 'WidgetFactory'],
  /**
   * @param {gbc} context
   * @param {classes} cls
   */
  function(context, cls) {

    /**
     * @class classes.MySessionEndWidget
     * @extends classes.WidgetBase
     */
    cls.MySessionEndWidget = context.oo.Class(cls.SessionEndWidget, function($super) {
      /** @lends classes.MySessionEndWidget.prototype */
      return {
        __name: "MySessionEndWidget",

        setHeader: function(message) {
          this._element.getElementsByClassName("myHeaderText")[0].innerHTML = message;
        },

        setSessionLinks: function(base, session) {
          $super.setSessionLinks.call(this, base, session);

					var appInfo = gbc.SessionService.getCurrent().info();
					var demoLinks = this._element.getElementsByClassName("demolink");
					var x;
					for (x = 0; x < demoLinks.length; x++) {
						var url = appInfo.customUA || appInfo.connector + "/" + appInfo.mode + "/r/" + demoLinks[x].title;
						demoLinks[x].href = url;
					}

        }
      };
    });

     cls.WidgetFactory.registerBuilder('SessionEnd', cls.MySessionEndWidget);
  });
