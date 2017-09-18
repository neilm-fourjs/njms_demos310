
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
