/// FOURJS_START_COPYRIGHT(D,2014)
/// Property of Four Js*
/// (c) Copyright Four Js 2014, 2016. All Rights Reserved.
/// * Trademark of Four Js Development Tools Europe Ltd
///	 in the United States and elsewhere
/// 
/// This file can be modified by licensees according to the
/// product manual.
/// FOURJS_END_COPYRIGHT

modulum('MyFormWidget', ['FormWidget', 'WidgetFactory'],
	function(context, cls) {
		cls.MyFormWidget = context.oo.Class(cls.FormWidget, function($super) {
			return {
				__name: "MyFormWidget"
			};
		});
		// register the class so only forms with a style of 'gbc_footer' use this widget.
		cls.WidgetFactory.register('Form', 'gbc_footer', cls.MyFormWidget);
});
