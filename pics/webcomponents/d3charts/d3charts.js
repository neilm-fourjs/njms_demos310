
var chart;
var myProps
var has_focus=false;
var clicked=false;

// This function is called by the Genero Client Container
// so the web component can initialize itself and initialize
// the gICAPI handlers
onICHostReady = function(version) {

	if ( version != 1.0 ) {
		alert('Invalid API version');
		return;
	}

	gICAPI.onFocus = function( polarity ) {
		if ( polarity && clicked ) {
			//alert('onFocus');
			clicked = false;
		}
		has_focus = polarity;
	}

	gICAPI.onProperty = function(props) {
		myProps = eval("(" + props + ")");
	}

	gICAPI.onData = function( data ) {
		chartData = eval("(" + data + ")");
		//document.getElementById("data2").innerHTML=data;
		clicked = true;
		gICAPI.SetFocus();
		doChart();
	}
}

// Charting function
function doChart() {
	var data = chartData.data;
	var height = chartData.heigth;
	var width = chartData.width;
	var max = chartData.max_value;

	margin = ({top: 25, right: 0, bottom: 25, left: 40})

// >
	x = d3.scaleBand()
		.domain(data.map(d => d.name))
		.range([margin.left, width - margin.right])
		.padding(0.1)

// ^
	y = d3.scaleLinear()
		.domain([0, max]) // d3.max(data, d => d.value)]).nice()  Fails!!!
		.range([height - margin.bottom, margin.top])

	xAxis = g => g
		.attr("transform", `translate(0,${height - margin.bottom})`)
		.call(d3.axisBottom(x)
				.tickSizeOuter(0))

	yAxis = g => g
		.attr("transform", `translate(${margin.left},0)`)
		.call(d3.axisLeft(y))
		.call(g => g.select(".domain").remove())

	var svg = d3.select(".chart")
								.attr("height", height)
								.attr("width", width);

	svg.selectAll("*").remove()
	svg.append("g")
		.selectAll("rect").data(data).enter().append("rect")
			.attr("class", "bar")
			.attr("fill", d => d.fill)
			.attr("x", d => x(d.name))
			.attr("y", d => y(d.value))
			.attr("height", d => y(0) - y(d.value))
			.attr("width", x.bandwidth())
			.on("click", function(d, i) {
				gICAPI.Action( d.action );
			} );

	svg.append("g")
		.call(xAxis);
	
	svg.append("g")
		.call(yAxis);
}
