<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <title>RoadTripr</title>
        <meta name="description" content="Easliy split the cost of gas with friends">
        <meta name="viewport" content="width=device-width">

        <link rel="stylesheet" href="css/bootstrap.min.css">
        <style>
            body {
                padding-top: 60px;
                padding-bottom: 40px;
            }
        </style>
        <link rel="stylesheet" href="css/bootstrap-responsive.min.css">
        <link rel="stylesheet" href="css/main.css?<?php echo time() ?>">
        <link href='http://fonts.googleapis.com/css?family=Lato:100,300,400' rel='stylesheet' type='text/css'>
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
        <script type="text/javascript" src="http://www.parsecdn.com/js/parse-1.2.8.min.js"></script>

        <script src="js/vendor/modernizr-2.6.2-respond-1.1.0.min.js"></script>
    </head>
    <body data-spy="scroll" data-target="#navbar">
        <!--[if lt IE 7]>
            <p class="chromeframe">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">activate Google Chrome Frame</a> to improve your experience.</p>
        <![endif]-->
		<!--
        <div id="navbar" class="navbar navbar-inverse navbar-fixed-top">
            <div class="navbar-inner">
                <div class="container">
                    <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </a>
                    <a class="brand" href="#">RoadTripr</a>
                    <div class="nav-collapse collapse">
                        <form class="navbar-form pull-right">
                            <input class="span2" type="text" placeholder="Email">
                            <input class="span2" type="password" placeholder="Password">
                            <button type="submit" class="btn">Sign in</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
        -->
        <header class="jumbotron subhead">
        

            <!-- Main hero unit for a primary marketing message or call to action -->
            <div class="container">
                <h1>Roadtripr</h1>
                <p class="lead">Easliy split the cost of gas with friends</p>
            </div>
        </header>
        
        
        <!-- Modal -->
        <div id="shareModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="modal" aria-hidden="true">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            <h3 id="shareModalHeader">RoadTripr</h3>
          </div>
          <div class="modal-body">
          	<div class="row-fluid">
          		<div id="prices2" style="display:none" class="row-fluid">
	          		<div class="span3">
	          		    <div class="controls">
	          		        <span># of People:</span>
	          		        <h1 id="num_people" class=""></h1>
	          		    </div>
	          		</div>
          		    <div class="span3">
          		        <div class="controls">
          		            <span>Cost of gas in <pre> id="gas_span2"></pre>:</span>
          		            <h1 id="gas2" class=""></h1>
          		        </div>
          		    </div>
          		    <div class="span3">
          		        <div class="controls">
          		            <span>Cost per Person:</span>
          		            <h1 id="cost2" class=""></h1>
          		        </div>
          		    </div>
          		    <div class="span3">
          		        <div class="controls">
          		            <span>Total Cost:</span>
          		            <h1 id="total2" class=""></h1>
          		        </div>
          		    </div>
          		</div>
          		
	            <div class="input-append">
	              <input id="url" class="span12" type="text">
	              <button id="share" class="btn btn-info" type="button">Share</button>
	            </div>
	            
	         </div>
	         <div id="addThis" class="row-fluid">
	         	<!-- AddThis Button BEGIN -->
	         	<div class="addthis_toolbox addthis_default_style addthis_32x32_style">
	         	<a class="addthis_button_preferred_1"></a>
	         	<a class="addthis_button_preferred_2"></a>
	         	<a class="addthis_button_preferred_3"></a>
	         	<a class="addthis_button_preferred_4"></a>
	         	<a class="addthis_button_compact"></a>
	         	<a class="addthis_counter addthis_bubble_style"></a>
	         	</div>
	         	<script type="text/javascript">var addthis_config = {"data_track_addressbar":true};</script>
	         	<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-502407f64d3ce404"></script>
	         	<!-- AddThis Button END -->
	         </div>
           </div>
          <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
            <button class="btn btn-primary">Share</button>
          </div>
        </div>
        
        
        <div class="container">
            <!-- Example row of columns -->
            <div class="row">
               <div class="span4 sidebar" >
                    <form class="form">
                        <div class="controls">
                            <span for="start-location">Start Location</span>
                            <div class="input-append">
                              <input id="start" type="text" name="start-location" placeholder="Start Location">
                              <button id="current-location" class="btn" type="button" data-trigger"hover" data-toggle="popover" data-content="Click for current Location" data-placement="right"
                                data-loading-text="<i class='icon-refresh'></i>">
                                    <i class="icon-map-marker"></i>
                              </button>
                            </div>
                        </div>

                        <div class="controls">
                            <span for="end-location">End Destination</span>
                            <input type="text" id="end" name="end-location" placeholder="Destination" >
                        </div>

                        <div class="controls">
                            <span for="people">Number of People</span>
                            <input id="people" placeholder="Number of People" type="number" name="people"/>
                        </div>

                        <div class="controls">
                            <span for="mpg">Miles Per Gallon</span>
                            <input id="mpg" placeholder="MPG" type="number" name="mpg"/>
                        </div>

                        <div class="controls">
                            <label class="checkbox">
                                <input id="roundtrip" type="checkbox" name="roundtrip"> Roundtrip?
                            </label>
                        </div>

                        <div class="controls">
                            <button id="calculate" class="btn btn-large btn-primary">Calculate</button>
                        </div>
                   </form>
                </div>
                <div class="span8">
                    <div id="map-frame" class="hidden-phone" style="height:320px;">
                        <div id="map-canvas" style="height:100%;"></div>
                    </div>
                </div>
            </div>
            <div id="prices" class="row">
            	<div class="span3">
            	    <div class="controls">
            	        # of People:
            	        <h1 id="num_people" class=""></h1>
            	    </div>
            	</div>
                <div class="span3">
                    <div class="controls">
                        Cost of gas in <span id="gas_span"></span>:
                        <h1 id="gas" class=""></h1>
                    </div>
                </div>
                <div class="span3">
                    <div class="controls">
                        <span>Cost per Person:</span>
                        <h1 id="cost" class=""></h1>
                    </div>
                </div>
                <div class="span3">
                    <div class="controls">
                        <span>Total Cost:</span>
                        <h1 id="total" class=""></h1>
                    </div>
                </div>
            </div>
            <hr>
            <footer>
                <p>Developed by <a href="http://www.seantburke.com/?r=roadtripr">Sean Thomas Burke</a> &copy;RoadTripr 2013</p>
            </footer>

        </div> <!-- /container -->

        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
        <script>window.jQuery || document.write('<script src="js/vendor/jquery-1.9.1.min.js"><\/script>')</script>

        <script src="js/vendor/bootstrap.min.js"></script>
        <script src="js/plugins.js"></script>
        <script src="js/main.js"></script>
        <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&sensor=true"></script>
        <script>if ( typeof window.JSON === 'undefined' ) { document.write('<script src="js/json2.js"><\/script>'); }</script>
        <script src="js/jquery.history.js"></script>
        <script>
        
        var id;
        var map; 
        var start_lat;
        var start_lng;
        var end_lat;
        var end_lng;
        var city;
        
        var start_location;
        var end_location;
                
        var miles;
        var people;
        var price;
        var mpg;
        var roundtrip = 1;
        var cost_per;
        var cost_total;
        
        
        $(document).ready(function(){
        	$("#prices").hide();
        	$("#prices2").hide();
        	$("#addThis").hide();
        	id = getURLParameter("id");
        	if(id != "null")
        	{
	        	console.log(id);
	        	loadTrip(id);
	        }
        })
        
        function initialize() {
        
        directionsService = new google.maps.DirectionsService();
        directionsDisplay = new google.maps.DirectionsRenderer();
        directionsDisplay.setMap(map);
        
        geocoder = new google.maps.Geocoder();
        
          var mapOptions = {
            zoom: 8,
            center: new google.maps.LatLng(37.714242, -121.744868),
            mapTypeId: google.maps.MapTypeId.ROADMAP
          };
          map = new google.maps.Map(document.getElementById('map-canvas'),
              mapOptions);
        }
        
        google.maps.event.addDomListener(window, 'load', initialize);
        
        function mapCurrentLocation() {
          var mapOptions = {
            zoom: 6,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          };
          
          map.setOptions(mapOptions);
        
          // Try HTML5 geolocation
          if(navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(location){
                getCurrentLocation(location, function(){
                        start_lat = location.coords.latitude;
                        start_lng = location.coords.longitude;
                        console.log("resetting button");
                        $("#current-location").button("reset");
                        getAddress(location, function(result){
                            $("input[name='start-location']").val(result);
                        });
                        $("input[name='start-location']").addClass("input-primary");
                        $("#current-location-group").addClass("info");
                        $("#current-location").addClass("btn-primary");
                        $("#current-location i").addClass("icon-white");
                        calculateGasPrice(start_lat, start_lng);
                        calcRoute();
                });
            }, function(){
                handleNoGeolocation(true)}
            );
            console.log("Getting current location: lat:" + position.coords.latitude + "long:" +
                                             position.coords.longitude);
          } else {
            // Browser doesn't support Geolocation
            handleNoGeolocation(false);
          }
        }
        
        function getCurrentLocation(position, callback){
            var pos = new google.maps.LatLng(position.coords.latitude,
                                           position.coords.longitude);
            console.log("position.coords.latitude:"+position.coords.latitude);
            console.log("position.coords.longitude:"+position.coords.longitude);                             
            icon = new google.maps.Marker();
            var marker = new google.maps.Marker({
                map:map,
                position: pos,
                icon: 'http://maps.google.com/mapfiles/ms/icons/green-dot.png'
            });
            
            console.log("Getting current location: lat:" + position.coords.latitude + "long:" +
                                         position.coords.longitude);
            map.setCenter(pos);
            
            callback();
        };
        
        function handleNoGeolocation(errorFlag) {
          if (errorFlag) {
            var content = 'Error: The Geolocation service failed.';
          } else {
            var content = 'Error: Your browser doesn\'t support geolocation.';
          }
        }
        
        $("input[name='start-location']").focusout(function(event){
            //event.preventDefault();
            setStart();
        });

        function setStart(){
            getGPS($(this).val(), function(location){
                console.log("location");
                console.log(location);
                start_lat = location.lat();
                start_lng = location.lng();
                calculateGasPrice(start_lat, start_lng);
                calcRoute();
                var marker = new google.maps.Marker({
                  map:map,
                  position: location,
                  icon: 'http://maps.google.com/mapfiles/ms/icons/green-dot.png'
                  });
                  
                  map.setCenter(location);
                });
        }
        
        $("input[name='end-location']").focusout(function(event){
            //event.preventDefault();
            calcRoute(function(){
                calculateGasPrice(start_lat, start_lng);
            });
        });
        
        $("#share").click(function(event){
            //event.preventDefault();
            $("#addThis").slideDown();
        });
        
        
        
        $("input[name='people']").change(function(event){
            //event.preventDefault();
            people = $(this).val();
            if($("input[name='mpg']").val())
            {
                calculateCost();
            }
        });
        
        $("input[name='mpg']").change(function(event){
            //event.preventDefault();
            mpg = $(this).val();
            if($("input[name='people']").val())
            {
                calculateCost();
            }
        });
        
        $("#calculate").click(function(event){
            event.preventDefault();
            console.log(start_lat);
            console.log(start_lng);
            console.log(end_lat);
            console.log(end_lng);
            
            console.log(start_location);
            console.log(end_location);
                    
            console.log(miles);
            console.log(city);
            console.log(people);
            console.log(price);
            console.log(mpg);
            console.log(roundtrip);
            updateAll()
			
        });
        
        function updateAll()
        {
        	$('#shareModal').modal('show');
        	$('#shareModalHeader').html('Roadtripr: ' + city + ' to ' + end_location);
        	calcRoute(function(){
        	    calculateGasPrice(start_lat, start_lng, function(){
        	        calculateCost(function(){
        	        	updateHistory();
        	        });
        	    })              
        	    
        	});
        }
        
       
         
        $("input[name='roundtrip']").on('click', function(event){
            //event.preventDefault();
            if($("input[name='roundtrip']:checked").length == 1)
            {
                roundtrip = 2;
            }
            else
            {
                roundtrip = 1;
            }
            calculateCost();
        });
        
        
        $("#current-location").popover({trigger: 'hover', delay: { show: 900, hide: 10 }});
        $("#current-location").click(function (){
            $("#current-location").button("loading");
            google.maps.event.addDomListener(window, 'load', mapCurrentLocation());
        });
             
        function getGPS(address, output){
            geocoder.geocode( { 'address': address}, function(results, status) 
                {
                  if (status == google.maps.GeocoderStatus.OK) 
                  {
                    
                    output(results[0].geometry.location);
                  }
                  else 
                  {
                      console.log(status);
                  }
                }
            );
        }
        
        function getAddress(location, output){
            var lat = location.coords.latitude;
            var lng = location.coords.longitude;
            geocoder.geocode( { 'address': lat +"," + lng }, function(results, status)
                {
                  if (status == google.maps.GeocoderStatus.OK)
                  {
                        output(results[0].formatted_address);
                  }
                  else
                  {
                        console.log(status);
                  }
                }
            );
        }
        
        function calcRoute(callback) {
          start_location = $("input[name='start-location']").val();
          end_location = $("input[name='end-location']").val();
          var request = {
            origin: start_location,
            destination: end_location,
            travelMode: google.maps.TravelMode.DRIVING
          };
          directionsService.route(request, function(response, status) {
            console.log("Directions response");
            console.log(response);
            miles = metersToMiles(response.routes[0].legs[0].distance.value);
            if(response.routes)
            {
                start_lat = response.routes[0].legs[0].start_location.lat();
                start_lng = response.routes[0].legs[0].start_location.lng();
                end_lat = response.routes[0].legs[0].end_location.lat();
                end_lng = response.routes[0].legs[0].end_location.lng();
            }
            
            
            if (status == google.maps.DirectionsStatus.OK) {
              directionsDisplay.setDirections(response);
            }
            
          callback();
          });
          
          directionsDisplay.setMap(map);
        }
             
             
        function metersToMiles(input)
        {
        output = input/1613.84193424;
        return output;
        }
        
        function calculateCost(success)
        {
            var errors = 1;
            if(!$("input[name='mpg']").val())
            {
                errors++;
                console.log("Error: mpgs empty");
            }
            if(!$("input[name='people']").val())
            {
                errors++;
                console.log("Error: people empty");
            }
            if(!$("input[name='start-location']").val())
            {
                errors++;
                console.log("Error: start-location empty");
            }
            if(!$("input[name='end-location']").val())
            {
                errors++;
                console.log("Error: end-location empty");
            }
            if(!price)
            {
                errors++;
                console.log("Error: price empty");
            }
            if(errors == 1)
            {
                //setURLParameter('people',people);
                //setURLParameter('start-location',start_location);
                //setURLParameter('end-location',end_location);
                //setURLParameter('price',price);
                //setURLParameter('miles',miles);
                //setURLParameter('roundtrip',roundtrip);
                console.log(History);
                compute();
                if(success)
                {
                	success();
                }
            }
        }
        
        function compute()
        {
        	cost_per = ((((miles/mpg)*price)*roundtrip)/people).toFixed(2);
        	cost_total = (((miles/mpg)*price)*roundtrip).toFixed(2);
        	$("#cost").html("$" + cost_per);
        	$("#total").html("$" + cost_total);
        	$("#cost2").html("$" + cost_per);
        	$("#total2").html("$" + cost_total);
        	
        	$("#prices").slideDown();
        	$("#prices2").slideDown();
        }
        
        function calculateGasPrice(lat, lng, callback)
        {
            var errors = 1
            if(!lat)
            {
                errors++;
                console.log("error: lat empty");
            }
            if(!lng)
            {
                errors++;
                console.log("error: lng empty");
            }
            
            if(errors === 1)
            {
                $.ajax({
                    type: 'GET',
                    url: 'gas.php',
                    dataType: "json",
                    data: {
                    latitude: lat,
                    longitude: lng,
                    gas_type: 'reg',
                    sort_by: 'price'
                     
                    }, 
                    success: function(data, status, response){
                    
                    city = data.stations[0].city
                        if(data.status.error == "YES")
                        {
                            $("#gas").html("$" + "ERROR");
                            $("#gas2").html("$" + "ERROR");
                        }
                        else
                        {
                        	
                            price = data.stations[0].price;
                            $("#gas_span").html(city);
                            $("#gas_span2").html(city);
                            $("#gas").html("$" + price);
                            $("#gas2").html("$" + price);
                            $("#prices").slideDown();
                            $("#prices2").slideDown();
                        }
                        callback();
                    },
                    error: function(data){
                        console.log(data);
                        $("#gas_span").html(city);
                        $("#gas_span2").html(city);
                        $("#gas").html("$" + "ERROR");
                        $("#gas2").html("$" + "ERROR");
                        callback();
                    }
                });
            }
        }
        
        function getURLParameter(name) {
            return decodeURIComponent(
                (RegExp('[?|&]'+name + '=' + '(.+?)(&|$)').exec(location.search)||[null,null])[1]
            );
        }
        
        function setURLParameter(name,value){
            var search;
            if(getURLParameter(name)){
                search =location.search.replace(new RegExp('([?|&]'+name + '=)' + '(.+?)(&|$)'),"$1"+encodeURIComponent(value)+"$3"); 
            }else if(location.search.length){
                search = location.search +'&'+name + '=' +encodeURIComponent(value);
            }else{
                search = '?'+name + '=' +encodeURIComponent(value);
            }
            History.pushState({state:History.getStateId()+1},document.title,search);
        }
        
        Parse.initialize("XaOZLlEYM0Iu49oTedAm1gqQM895vkV66F8RNSL7", "mXOANydxMFw3AHN6k8nSP1AifftrStFyPBRYLXGJ");
        
        var Trip = Parse.Object.extend("Trip");
        var trip = new Trip();
                  
        function updateHistory(success)
        {   
        	var errors = 1; 
        	if(mpg == undefined)
        	{
        		
        		errors++;
        	}
        	if(people == undefined)
        	{
        		
        		errors++;
        	}
        	if(start_location == undefined)
        	{
        		
        		errors++;
        	}
        	if(end_location == undefined)
        	{
        		
        		errors++;
        	}
        	if(roundtrip == undefined)
        	{
        		
        		errors++;
        	}
        	if(cost_total == undefined)
        	{
        		
        		errors++;
        	}
        	if(cost_per == undefined)
        	{
        		
        		errors++;
        	}
        	if(start_lat == undefined)
        	{
        		
        		errors++;
        	}
        	if(start_lng == undefined)
        	{
        		
        		errors++;
        	}
        	if(end_lat == undefined)
        	{
        		
        		errors++;
        	}
        	if(end_lng == undefined)
        	{
        		
        		errors++;
        	}
        	if(miles == undefined)
        	{
        		
        		errors++;
        	}
        	if(price == undefined)
        	{
        		
        		errors++;
        	}
        	if(errors == 1)
        	{	
	              trip.save(
		          	{
		          		mpg: mpg,
		          		people: people,
		          		start_location:start_location,
		          		end_location:end_location,
		          		roundtrip:roundtrip,
		          		cost_total:cost_total,
		          		cost_per:cost_per,
		          		start_lat:start_lat,
		          		start_lng:start_lng,
		          		end_lat:end_lat,
		          		end_lng:end_lng,
		          		miles:miles,
		          		price:price,
		          		city:city
		          	}, 
	              {
	              success: function(result) 
	              {
	                History.pushState({id:result.id}, document.title + ": " + city + " to " + end_location ,'?id='+result.id);
	                $("#url").val(document.URL);
	              },
	              error: function(model, error) 
	              {
	                $(".error").show();
	              }
	            });
	            if(success)
	            {
	            	success();
	            }
            }
        }
        
        function loadTrip(id)
        {
        	var query = new Parse.Query(Trip);
        	query.get(id, {
        	  success: function(result) {
        	    // object is an instance of Parse.Object.
        	    
        	    $("#mpg").val(result.get("mpg"));
        	    $("#people").val(result.get("people"));
        	    $("#start").val(result.get("start_location"));
        	    $("#end").val(result.get("end_location"));
        	    $("#cost").html("$" + result.get("cost_per"));
        	    $("#total").html("$" + result.get("cost_total"));
        	    $("#gas").html("$" + result.get("price"));
        	    $("#gas_span").html(result.get("city"));
        	    
        	    $("#cost2").html("$" + result.get("cost_per"));
        	    $("#total2").html("$" + result.get("cost_total"));
        	    $("#gas2").html("$" + result.get("price"));
        	    $("#gas_span2").html(result.get("city"));
        	    
        	    $('#shareModal').modal('show');
        	    $('#shareModalHeader').html('Roadtripr: ' + result.get("city") + ' to ' + result.get("end_location"));
        	    $("#prices").slideDown();
        	    $("#prices2").slideDown();
        	    $("#url").val(document.URL);
        	    
        	    if(result.get("roundtrip") == "2")
        	    {
        	    	$('#roundtrip').prop('checked', true);
        	    }
        	    else
        	    {	
        	    	$('#roundtrip').prop('checked', false);
        	    }
        	    
        	    
        	    cost_total = result.get("cost_total");
        	    cost_per = result.get("cost_per");
        	    mpg = result.get("mpg");
        	    miles = result.get("miles");
        	    people = result.get("people");
        	    start_location = result.get("start_location");
        	    start_lat = result.get("start_lat");
        	    start_lng = result.get("start_lng");
        	    city	  = result.get("city");
        	    end_location = result.get("end_location");
        	    end_lat = result.get("end_lat");
        	    end_lng = result.get("end_lng");
        	    price = result.get("price");
        	    roundtrip = result.get("roundtrip");
        	    calcRoute();
        	    History.pushState({id:id}, document.title + ": " + city + " to " + end_location ,'?id='+id);
        	    
        	  },
        	
        	  error: function(object, error) {
        	    // error is an instance of Parse.Error.
        	    console.log("error occurred");
        	  }
        	  
        	});
        }
        
        
        </script>

        <script>
            var _gaq=[['_setAccount','UA-42611920-1'],['_trackPageview']];
            (function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
            g.src=('https:'==location.protocol?'//ssl':'//www')+'.google-analytics.com/ga.js';
            s.parentNode.insertBefore(g,s)}(document,'script'));
        </script>
    </body>
</html>
