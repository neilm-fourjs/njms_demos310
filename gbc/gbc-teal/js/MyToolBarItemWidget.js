
"use strict";

// Declare the dependency to inheritedWidget (here ToolBarItemWidget) module
modulum('MyToolBarItemWidget', ['ToolBarItemWidget', 'WidgetFactory'],
  function(context, cls) {
    cls.MyToolBarItemWidget = context.oo.Class(cls.ToolBarItemWidget, function($super) {
      return {
        __name: "MyToolBarItemWidget",
        // using default ToolBarItemWidget template!
        __templateName: "ToolBarItemWidget",
      };
    });
    cls.WidgetFactory.register('ToolBarItem','gbc_weboe', cls.MyToolBarItemWidget);
  });
