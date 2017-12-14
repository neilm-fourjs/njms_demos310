
function change_music( filename ) {
	var audioSource = document.getElementById('mp3file');
	document.getElementById('debug1').innerHTML="Was:"+audioSource.src;
	audioSource.src = filename;
	var audioObj = document.getElementById('myaudio');
	audioObj.load();
	document.getElementById('debug2').innerHTML="Now:"+audioSource.src;
}

function onICHostReady(version) {
	if ( version != 1.0 ) {
		alert('Invalid API version');
		return;
	}

	gICAPI.currentStyleToApply = "fill:#000000;";
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
			}
		} else {
			//alert("DEBUG:onData:ignored!");
		}
	}

	gICAPI.onProperty = function(props) {
		if (props != gICAPI.memorizedProps) {
			gICAPI.memorizedProps = props;
			change_music( eval('(' + props + ')').mp3file );

			document.getElementById('name').innerHTML= "<B>"+eval('(' + props + ')').name+"</B>";

			if (! gICAPI.redrawRequested) {
				gICAPI.redrawRequested = true;
			}
		}
	}

	gICAPI.onFocus = function(polarity) {
		if ( polarity ) {
			document.getElementById('player').style.border = '1px solid blue';
		} else {
			document.getElementById('player').style.border = '1px solid grey';
		}
	}
}
