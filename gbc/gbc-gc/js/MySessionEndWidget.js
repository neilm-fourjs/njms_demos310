/// FOURJS_START_COPYRIGHT(D,2015)
/// Property of Four Js*
/// (c) Copyright Four Js 2015, 2018. All Rights Reserved.
/// * Trademark of Four Js Development Tools Europe Ltd
///   in the United States and elsewhere
/// 
/// This file can be modified by licensees according to the
/// product manual.
/// FOURJS_END_COPYRIGHT

"use strict";

modulum('MySessionEndWidget', ['WidgetBase', 'WidgetFactory'],
  function(context, cls) {

    /**
     * @class MySessionEndWidget
     * @memberOf classes
     * @extends classes.WidgetBase
     */
    cls.MySessionEndWidget = context.oo.Class(cls.SessionEndWidget, function($super) {
      return /** @lends classes.MySessionEndWidget.prototype */ {
        __name: "MySessionEndWidget",

        setHeader: function(message) {
          this._element.getElementsByClassName("myHeaderText")[0].innerHTML = message;
        },

        setSessionLinks: function(base, session) {
          $super.setSessionLinks.call(this, base, session);

          // update redirection link url of the template
          //var redirectionLink = this._element.getElementsByClassName("redirectionLink")[0];
          //redirectionLink.title = i18next.t("mycusto.session.redirectionText");
          //var url = "http://www.google.com";
          //redirectionLink.href = url;

          var modelHelper = new cls.ModelHelper(this);

          // launch the redirection after a delay of 10 seconds
          // to remove the delay, remove the setTimeout
          setTimeout(function () {
            // check if an application is running in the current session before reloading
            if(!modelHelper.getCurrentApplication()) {
              window.location = url;
            }
          }.bind(this), 10000); // 10000ms
        }
      };
    });

     cls.WidgetFactory.registerBuilder('SessionEnd', cls.MySessionEndWidget);
  });
