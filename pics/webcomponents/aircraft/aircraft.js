
function selectObject(evt) {
	if (gICAPI.svgDoc == null) {
		return;
	}
	var id = evt.target.getAttribute("id");
	gICAPI.memorizedData = id;
	gICAPI.SetFocus();
	gICAPI.SetData(gICAPI.memorizedData);
	gICAPI.Action("selobj");
}
////////////////////////////////////////////////////////////////////////////////
function onICHostReady(version) {
	if ( version != 1.0 ) {
		alert('Invalid API version');
		return;
	}

	gICAPI.memorizedProps = "";
	gICAPI.memorizedData = "";
	gICAPI.redrawRequested = false;

	gICAPI.onData = function(data) {
		if (data == "") {
			var props = gICAPI.memorizedProps;
			gICAPI.memorizedProps = "";
			gICAPI.memorizedData = "";
			gICAPI.onProperty(props);
		} else if (data != gICAPI.memorizedData) {
			gICAPI.memorizedData = data;
			if (! gICAPI.redrawRequested) {
				gICAPI.redrawRequested = true;
				setTimeout(gICAPI.redrawDesign,10);
			}
		} else {
			//alert("DEBUG:onData:ignored!");
		}
	}

	gICAPI.onProperty = function(props) {
		if (props != gICAPI.memorizedProps) {
			gICAPI.memorizedProps = props;
			document.getElementById('svg_area').innerHTML=
			 "<embed id='embed' src='"+eval('(' + props + ')').design+".svg' type='image/svg+xml' />";
//			 "<embed id='embed' src='"+eval('(' + props + ')').design+".svg' width='600px' height='400px' type='image/svg+xml' pluginspage='http://www.adobe.com/svg/viewer/install/'/>";
			if (! gICAPI.redrawRequested) {
				gICAPI.redrawRequested = true;
				setTimeout(gICAPI.redrawDesign,10);
			}
		}
	}

	gICAPI.onFocus = function(polarity) {
		if ( polarity ) {
			document.getElementById('svg_area').style.border = '1px solid blue';
		} else {
			document.getElementById('svg_area').style.border = '1px solid red';
		}
	}

	gICAPI.redrawDesign = function() {
		gICAPI.redrawRequested = false;
		
		if (gICAPI.svgDoc == null) {
			var embed=document.getElementById("embed");
			gICAPI.svgDoc=embed != null ? embed.getSVGDocument() : null;
			if (gICAPI.svgDoc == null) {
				if (! gICAPI.redrawRequested) {
					gICAPI.redrawRequested = true;
					setTimeout(gICAPI.redrawDesign,10);
				}
				return;
			}
		}
	}
}