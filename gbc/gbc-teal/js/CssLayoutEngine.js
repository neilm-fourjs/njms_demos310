/// FOURJS_START_COPYRIGHT(D,2014)
/// Property of Four Js*
/// (c) Copyright Four Js 2014, 2016. All Rights Reserved.
/// * Trademark of Four Js Development Tools Europe Ltd
///   in the United States and elsewhere
///
/// This file can be modified by licensees according to the
/// product manual.
/// FOURJS_END_COPYRIGHT

"use strict";

modulum('CssLayoutEngine', ['LeafLayoutEngine'],
  /**
   * @param {gbc} context
   * @param {classes} cls
   */
  function(context, cls) {
    /**
     * @class classes.CssLayoutEngine
     * @extends classes.LeafLayoutEngine
     */
    cls.CssLayoutEngine = context.oo.Class(cls.LeafLayoutEngine, function($super) {
      /** @lends classes.CssLayoutEngine.prototype */
      return {
        __name: "CssLayoutEngine",
        getRenderableChildren: function() {
          return this._widget && this._widget.getChildren && this._widget.getChildren() || [];
        },
        prepareMeasure: function() {},
        measure: function() {
          var layoutInfo = this._widget.getLayoutInformation();
          layoutInfo.setMinimal(cls.Size.undef, cls.Size.undef);
          layoutInfo.setMaximal(cls.Size.undef, cls.Size.undef);
          layoutInfo.setMeasured(cls.Size.undef, cls.Size.undef);
          layoutInfo.setAllocated(cls.Size.undef, cls.Size.undef);
          layoutInfo.setAvailable(cls.Size.undef, cls.Size.undef);
        }
      };
    });
  });
