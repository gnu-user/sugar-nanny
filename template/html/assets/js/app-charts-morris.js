var App = (function () {
	'use strict';

	App.chartsMorris = function( ){

		// data stolen from http://howmanyleft.co.uk/vehicle/jaguar_'e'_type

		$.ajax({
		url: "demo_test.txt",
		success: function(result){
			$("#div1").html(result);
		}
	});
	  var tax_data = [
	       {"Time": "2015", "mmol/L": 400},
	       {"Time": "2010", "mmol/L": 200},
	       {"Time": "2005", "mmol/L": 200},

	  ];

	  //Line Chart
	  function line_chart(){
	  	var color1 = App.color.primary;
	  	var color2 = tinycolor( App.color.primary ).lighten( 15 ).toString();

	  	new Morris.Line({
		    element: 'line-chart',
		    data: tax_data,
		    xkey: 'Time',
		    ykeys: ['mmol/L'],
		    labels: ['Blood Sugar'],
		    lineColors: [color1],
		    hideHover: 'auto'
		  });
	  }

	  //Bar chart
	  function bar_chart(){
			var color1 = tinycolor( App.color.alt3 ).lighten( 10 ).toString();

	  	Morris.Bar({
			  element: 'bar-chart',
			  data: [
			    {Time: '09:00', Carbohydrates: 136, test:1},
			    {Time: '12:00', Carbohydrates: 137, test:1},
			    {Time: '3:00', Carbohydrates: 275, test:2},
			    {Time: '6:00', Carbohydrates: 380, test:1},
			    {Time: '9:00', Carbohydrates: 655, test:3},
			    {Time: '12:00', Carbohydrates: 1571, test:1}
			  ],
			  xkey: 'Time',
			  ykeys: ['Carbohydrates'],
			  labels: ['Carbohydrates','time'],
			  barColors: [color1],
			  barRatio: 0.4,
			  hideHover: 'auto'
			});
	  }
		function bar_chart_2(){
			var color1 = tinycolor("#C1EF65").lighten( 10 ).toString();

			Morris.Bar({
				element: 'bar-chart-2',
				data: [
					{Time: '09:00', Carbohydrates: 136, test:1},
					{Time: '12:00', Carbohydrates: 137, test:2},
					{Time: '3:00', Carbohydrates: 275, test:2},
					{Time: '6:00', Carbohydrates: 380, test:1},
					{Time: '9:00', Carbohydrates: 655, test:3},
					{Time: '12:00', Carbohydrates: 1571, test:1}
				],
				xkey: 'Time',
				ykeys: ['Carbohydrates'],
				labels: ['Carbohydrates', 'time'],
				barColors: [color1],
				barRatio: 0.4,
				hideHover: 'auto'
			});
		}

	  //Donut Chart
	  function donut_chart(){
	  	var color1 = App.color.alt2;
      var color2 = App.color.alt4;
      var color3 = App.color.alt3;
      var color4 = App.color.alt1;
      var color5 = tinycolor( App.color.primary ).lighten( 5 ).toString();

  	  Morris.Donut({
		    element: 'donut-chart',
		    data: [
		      {label: 'Facebook', value: 25 },
		      {label: 'Google', value: 40 },
		      {label: 'Twitter', value: 25 },
		      {label: 'Pinterest', value: 10 }
		    ],
		    colors:[color1, color5, color3, color4],
		    formatter: function (y) { return y + "%" }
		  });
	  }

	  //Area chart
	  function area_chart(){
	  	var color1 = App.color.alt2;
      var color2 = App.color.alt4;
      var color3 = App.color.alt3;
      var color4 = App.color.alt1;
      var color5 = tinycolor( App.color.primary ).lighten( 5 ).toString();

	  	Morris.Area({
		    element: 'area-chart',
		    data: [
		      {period: '2010 Q1', iphone: 2666, ipad: null, itouch: 2647},
		      {period: '2010 Q2', iphone: 2778, ipad: 2294, itouch: 2441},
		      {period: '2010 Q3', iphone: 4912, ipad: 1969, itouch: 2501},
		      {period: '2010 Q4', iphone: 3767, ipad: 3597, itouch: 5689},
		      {period: '2011 Q1', iphone: 6810, ipad: 1914, itouch: 2293},
		      {period: '2011 Q2', iphone: 5670, ipad: 4293, itouch: 1881},
		      {period: '2011 Q3', iphone: 4820, ipad: 3795, itouch: 1588},
		      {period: '2011 Q4', iphone: 15073, ipad: 5967, itouch: 5175},
		      {period: '2012 Q1', iphone: 10687, ipad: 4460, itouch: 2028},
		      {period: '2012 Q2', iphone: 8432, ipad: 5713, itouch: 1791}
		    ],
		    xkey: 'period',
		    ykeys: ['iphone', 'ipad', 'itouch'],
		    labels: ['iPhone', 'iPad', 'iPod Touch'],
		    lineColors: [color5, color4, color1],
		    pointSize: 2,
		    hideHover: 'auto'
		  });
	  }

	  line_chart();
	  bar_chart();
	  bar_chart_2();
	  //donut_chart();
	  //area_chart();
	};

	return App;
})(App || {});
