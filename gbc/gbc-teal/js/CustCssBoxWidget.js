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

modulum('CustCssBoxWidget', ['WidgetGroupBase', 'WidgetFactory'],
  /**
   * @param {gbc} context
   * @param {classes} cls
   */
  function(context, cls) {

    /**
     * @class CustCssBoxWidget
     * @extends classes.WidgetGroupBase
     */
    var CustCssBoxWidget = context.oo.Class(cls.WidgetGroupBase, function($super) {
      /** @lends CustCssBoxWidget.prototype */
      return {
        __name: "CustCssBoxWidget",

        constructor: function() {
          $super.constructor.call(this);
        },
        _initLayout: function() {
          $super._initLayout.call(this);
          this._layoutEngine = new cls.CssLayoutEngine(this);
          this._layoutInformation._stretched.setDefaultX(true);
          this._layoutInformation._stretched.setDefaultY(true);
        },

      };
    });

    cls.WidgetFactory.register('HBox', 'cssLayout', CustCssBoxWidget);
    cls.WidgetFactory.register('VBox', 'cssLayout', CustCssBoxWidget);
    cls.WidgetFactory.register('Grid', 'cssLayout', CustCssBoxWidget);
  }
);
