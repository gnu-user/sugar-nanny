var App = (function () {
	'use strict';

	App.chartsMorris = function(){


	  //Line Chart
	  function line_chart(){

	  	var tax_data = []

		$.ajax({
		url: "http://api.sugarnanny.tech/stats/blood_sugar/1",
		success: function(result){
			
			tax_data = result.data
			console.log(result.data)

	  	var color1 = App.color.primary; 

	  	console.log("data:")
	  	console.log(tax_data)
	  	new Morris.Line({
		    element: 'line-chart',
		    data: tax_data,
		    xkey: 'timestamp',
		    ykeys: ['reading'],
		    ymax: 8,
		    labels: ['Blood Sugar'],
		    lineColors: [color1],
		    hideHover: 'auto'
		  });
		}
		});

	  }

	  //Bar chart
	  function bar_chart(){
	  	var carbs_data = []
	  	$.ajax({
		url: "http://api.sugarnanny.tech/stats/meals/1",
		success: function(result){
			
			carbs_data = result.data
			console.log("carbs:")
			console.log(result.data)


		var color1 = tinycolor( App.color.alt3 ).lighten( 10 ).toString();

	  		Morris.Bar({
			  element: 'bar-chart',
			  data: carbs_data,
			  xkey: 'timestamp',
			  ykeys: ['carbs'],
			  labels: ['Carbohydrates','Time'],
			  barColors: [color1],
			  barRatio: 0.4,
			  hideHover: 'auto'
			});
		}
		});

	  }
		function bar_chart_2(){

	  	var insulin_data = []
	  	$.ajax({
		url: "http://api.sugarnanny.tech/stats/insulin/1",
		success: function(result){
			
			insulin_data = result.data
			console.log("insulin:")
			console.log(result.data)


		var color1 = tinycolor("#C1EF65").lighten( 10 ).toString();

	  		Morris.Bar({
			  element: 'bar-chart-2',
			  data: insulin_data,
			  xkey: 'timestamp',
			  ykeys: ['dose_units'],
			  labels: ['Insulin Units','Time'],
			  barColors: [color1],
			  barRatio: 0.4,
			  hideHover: 'auto'
			});
		}
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
