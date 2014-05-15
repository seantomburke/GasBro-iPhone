<?php
session_start();
error_reporting(1);
ini_set('display_errors', 'On');
include 'Venmo.class.php';

$venmo = new Venmo($_GET['access_token']);

?>

<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <title>Gas Bro</title>
        <meta name="description" content="Easliy split the cost of gas with friends">
        <meta name="viewport" content="width=device-width">
        <meta property="og:title" content="Gas Bro" />
        <meta property="og:type" content="website" />
        <meta property="og:site_name" content="http://wwww.gasbro.com/" />
        <meta property="og:image" content="/img/bro.png" />
        <meta property="og:description" content="Easily split the cost of gas with your friends!" />
        <meta property="og:url" content="http://wwww.gasbro.com/" />
        <meta name="apple-itunes-app" content="app-id=798634160">
        <link rel="stylesheet" href="css/bootstrap.min.css">
        <link rel="stylesheet" href="css/select2.css?version=1.0">
        <link rel="stylesheet" href="css/select2-bootstrap.css?version=1.0">
        <link rel="stylesheet" href="css/slider.css?version=1.0">
        <link rel="stylesheet" href="css/bootstrap-responsive.min.css">
        <link rel="stylesheet" href="css/main.css?version=1.0">
        <link href='//fonts.googleapis.com/css?family=Lato:100,300,400' rel='stylesheet' type='text/css'>
    </head>
    <body data-spy="scroll" data-target="#navbar">
    <div id="fb-root"></div>
            <!--[if lt IE 7]>
            <p class="chromeframe">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">activate Google Chrome Frame</a> to improve your experience.</p>
        <![endif]-->
        <div id="navbar" class="navbar navbar-inverse hidden-phone">
            <div class="navbar-inner">
                <div class="container">
                    <a class="brand" href="#">Share</a>
                        <div class="addthis_toolbox addthis_default_style hidden-phone">
                        <a class="addthis_button_facebook_like" fb:like:layout="button_count"></a>
                        <a class="addthis_button_tweet"></a>
                        <a class="addthis_counter addthis_pill_style"></a>
                        </div>
                    <div class="pull-right">
                    <?php 
                    if($venmo->loggedin)
                    {
                     echo  '
                     <div class="nav">
                         <li class="dropdown">
		                        <a href="#" class="dropdown-toggle" data-toggle="dropdown">'.$venmo->me->display_name.'<b class="caret"></b></a>
		                        <ul class="dropdown-menu">
		                        	<li class="nav-header">Balance</li>
		                        	<li><a href="#">$'.$venmo->me->balance.'</a></li>
		                            <li class="divider"></li>
		                            <li class="nav-header">Completed</li>
		                            <li><a href="/index.php?logout=true">Logout</a></li>
		                        </ul>
		                    </li>
		            </div>';
                    }
                    else
                    {
                    echo '<form action="login.php" method="GET"><input class="logintripid" type="hidden" name="id" />
                    <input type="submit" class="btn btn-info pull-right hidden-phone" value="Login with Venmo"/>
                    <!--<fb:login-button show-faces="false" class="pull-right" width="200" max-rows="1">Login with Facebook</fb:login-button>-->
                    </form>';
                     
                    }
                    
                    ?>
                    </div>
                </div>
            </div>
        </div>
        <header class="jumbotron subhead">
            <div class="media">
              <a class="pull-left" href="http://www.gasbro.com/">
                <img class="media-object img-rounded" src="/img/gasbro75.png" width="75">
              </a>
              <a class="pull-right hidden-phone" href="http://www.appstore.com/gasbro" target="itunes_store"style="display:inline-block;overflow:hidden;background:url(https://linkmaker.itunes.apple.com/htmlResources/assets/en_us//images/web/linkmaker/badge_appstore-lrg.png) no-repeat;width:135px;height:40px;@media only screen{background-image:url(https://linkmaker.itunes.apple.com/htmlResources/assets/en_us//images/web/linkmaker/badge_appstore-lrg.svg);}"></a>
              <div class="media-body">
                <h1 class="media-heading">Gas Bro</h1>
                <p class="lead">Easliy split the cost of gas with friends</p>
              </div>
            </div>
        </header>
        
        
        <!-- Modal -->
        <div id="shareModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="modal" aria-hidden="true">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            <h3 id="shareModalHeader">Gas Bro</h3>
          </div>
          <div class="modal-body">
            <div class="row-fluid">
              <div id="prices2" style="display:none" class="row-fluid">
                <div class="span3">
                    <div class="controls">
                        <span>Number of People:</span>
                        <h1 id="num_people" class=""></h1>
                    </div>
                </div>
                  <div class="span3">
                      <div class="controls">
                          <span>Gas in <span id="gas_span2"></span>:</span>
                          <h1 id="gas2" class=""></h1>
                      </div>
                  </div>
                  <div class="span3">
                      <div class="controls">
                          <span>Per Person:</span>
                          <h1 id="cost2" class=""></h1>
                      </div>
                  </div>
                  <div class="span3">
                      <div class="controls">
                          <span>Total:</span>
                          <h1 id="total2" class=""></h1>
                      </div>
                  </div>
              </div>
           </div>
            <div class="row-fluid">
              <?php 
                if(!$venmo->loggedin)
                {
                echo '<form action="login.php" method="GET"><input class="logintripid" type="hidden" name="id" /><input type="submit" class="btn btn-info pull-right" value="Login with Venmo"/></form>';
                }
                else{
                echo '
                <div class="span6">
                    <span>Select your friends:</span>
                    <input type="hidden" id="venmo-friends"/>
                    <input type="text" id="note" />
                </div>';
                }
            ?>
            </div>
            
           </div>
          <div class="modal-footer">
            <div class="row">
            <?php 
                if($venmo->loggedin)
                {
                echo '
                <input id="charge_friends" class="btn" type="submit" value="Charge" />';
                }
                else{
                echo '
                <div class="input-append">
              <input id="url" type="text">
              <button id="facebook" class="btn btn-primary" type="button" href="#" 
                onclick="
                  window.open(
                    "https://www.facebook.com/sharer/sharer.php?u="+encodeURIComponent(location.href), 
                    "facebook-share-dialog", 
                    "height=450, width=550, top="+($(window).height()/2 - 225) +", left="+$(window).width()/2 +", toolbar=0, location=0, menubar=0, directories=0, scrollbars=0"); 
                  return false;">
                Facebook
              </button>
              <button id="tweet" class="btn btn-info" type="button" href="#" 
                onclick="
                  window.open(
                  "http://twitter.com/share?url=" + encodeURIComponent(location.href) + "&text=" + document.title + "&", "twitterwindow", "height=450, width=550, top="+($(window).height()/2 - 225) +", left="+$(window).width()/2 +", toolbar=0, location=0, menubar=0, directories=0, scrollbars=0");
                  return false;">
                Tweet
              </button>
              </div>';
                }
            ?>
            
            </div>
          </div>
        </div>
        
        <div id="iosModal" class="modal hide fade">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h3>Download the iOS App Today!</h3>
          </div>
          <div class="modal-body">
            <iframe src="https://app.io/uD8TI0?orientation=portrait&device=iphone5" height="607px" width="291px" frameborder="0" allowtransparency="true" scrolling="no"></iframe>
            
            
          </div>
          <div class="modal-footer">
            <a href="#" data-dismiss="modal" class="btn">Close</a>
          </div>
        </div>
        
        
        
        
        <div class="container">
            <div class="row  hidden-phone">
                
                <div class="span4">
                    <div id="map-frame" class="hidden-phone" style="height:607px;">
                        <div id="map-canvas" style="height:100%;"></div>
                    </div>
                </div>
               <div class="span4" >
                    <form class="form" id="main-form">
                        <div class="controls">
                            <span for="start-location">Start Location</span>
                            <br>
                            <div class="input-append">
                              <input id="start" type="text" name="start-location" placeholder="Start Location" required/>
                              <button id="current-location" class="btn" type="button" data-trigger"hover" data-toggle="popover" data-content="Click for current Location" data-placement="right"
                                data-loading-text="<i class='icon-refresh'></i>">
                                    <i class="icon-map-marker"></i>
                              </button>
                            </div>
                        </div>

                        <div class="controls">
                            <span for="end-location">End Destination</span>
                            <br>
                            <input id="end" type="text" name="end-location" placeholder="Destination" required/>
                        </div>
                        
                        <div class="controls">
                            <span for="gas-radio">Gas Type</span>
                            <br>
                            <input id="gas-type" type="hidden" />
                            <div id="gas-radio" class="btn-group" data-toggle="buttons-radio">
                              <button type="button" value="0" class="btn btn-primary">Reg</button>
                              <button type="button" value="1" class="btn btn-primary">Mid</button>
                              <button type="button" value="2" class="btn btn-primary">Pre</button>
                              <button type="button" value="3" class="btn btn-primary">Diesel</button>
                            </div>
                        </div>

                        <div class="controls">
                            <span for="people">Number of People</span>
                            <br>
                            <input class="slider" id="people" placeholder="Number of People" 
                            type="text" name="people" value="1" data-slider-min="1" 
                            data-slider-max="10" data-slider-step="1" 
                            data-slider-value="1" required />
                        </div>

                        <div class="controls">
                            <span for="mpg">Miles Per Gallon</span>
                            <br>
                            <input class="slider" id="mpg" placeholder="MPG" type="text" name="mpg"
                            value="25" data-slider-min="1" 
                            data-slider-max="100" data-slider-step="1" 
                            data-slider-value="25" required />
                        </div>

                        <div class="controls">
                            <label class="checkbox">
                                <input id="roundtrip" type="checkbox" name="roundtrip"><span>Roundtrip?</span>
                            </label>
                        </div>

                        <div class="controls">
                            <button id="calculate" class="btn btn-large btn-primary">Share</button>
                        </div>
                   </form>
                   
                    <div id="prices" class="well">
                            <div class="controls">
                                <span>Cost of gas in <span id="gas_span"></span>:</span>
                                <h1 id="gas" class=""></h1>
                            </div>
                            <div class="controls">
                                <span>Cost per Person:</span>
                                <h1 id="cost" class=""></h1>
                            </div>
                            <div class="controls">
                                <span>Total Cost:</span>
                                <h1 id="total" class=""></h1>
                            </div>
                    </div>
                </div>
                
                <div class="span4 hidden-tablet">
                    <p class="text-center"><iframe src="https://app.io/K0ODaK?orientation=portrait&device=iphone5" height="607px" width="291px" frameborder="0" allowtransparency="true" scrolling="no"></iframe>
                    <a href="http://www.appstore.com/gasbro" target="itunes_store"style="display:inline-block;overflow:hidden;background:url(https://linkmaker.itunes.apple.com/htmlResources/assets/en_us//images/web/linkmaker/badge_appstore-lrg.png) no-repeat;width:135px;height:40px;@media only screen{background-image:url(https://linkmaker.itunes.apple.com/htmlResources/assets/en_us//images/web/linkmaker/badge_appstore-lrg.svg);}"></a></p>
              
                </div>
                
                
            </div>
            
            <div class="row visible-phone">
                <div class="media">
                <div class="text-center">
                    <a class="text-center" href="http://www.appstore.com/gasbro" target="itunes_store"style="display:inline-block;overflow:hidden;background:url(https://linkmaker.itunes.apple.com/htmlResources/assets/en_us//images/web/linkmaker/badge_appstore-lrg.png) no-repeat;width:135px;height:40px;@media only screen{background-image:url(https://linkmaker.itunes.apple.com/htmlResources/assets/en_us//images/web/linkmaker/badge_appstore-lrg.svg);}">
                    <a href="http://www.appstore.com/gasbro" target="itunes_store"><img class="text-center" src="img/iPhone.png" /></a>
                </div>
                </div>
            </div>
            </div>
            
        <hr>
        <footer>
            <p class="text-center"> Developed by <a href="http://www.seantburke.com/?r=GasBro">Sean Thomas Burke</a> &copy; Nyquist Labs <?php echo date('Y');?></p>
        </footer>
        
        </div> <!-- /container -->
        
        
        
        
        <script type="text/javascript" src="//www.parsecdn.com/js/parse-1.2.8.min.js"></script>
        <script type="text/javascript" src="//maps.googleapis.com/maps/api/js?v=3.exp&sensor=true"></script>
        <script type="text/javascript" src="js/vendor/modernizr-2.6.2-respond-1.1.0.min.js"></script>
        <script type="text/javascript" src="//code.jquery.com/jquery-1.10.1.min.js"></script>
        <script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-502407f64d3ce404"></script>
        <script type="text/javascript" src="js/vendor/bootstrap.min.js"></script>
        <script type="text/javascript" src="js/plugins.js"></script>
        <script type="text/javascript" src="js/bootstrap-slider.js"></script>
        <!--<script>if ( typeof window.JSON === 'undefined' ) { document.write('<script src="js/json2.js"><\/script>'); }</script>-->
        <script type="text/javascript" src="js/jquery.history.js"></script>
        <script type="text/javascript" src="js/select2.min.js"></script>
        <script type="text/javascript" src="js/select2.js"></script>
        <script type="text/javascript" src="js/main.js?v=1"></script>
        <script>
          (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
          (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
          m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
          })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
        
          ga('create', 'UA-42611920-1', 'gasbro.com');
          ga('send', 'pageview');
        
        </script>
        <!-- AddThis Welcome BEGIN -->
<script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-502407f64d3ce404">
</script>
<script>

	addthis.bar.initialize({'default':{
		"backgroundColor": "#000000",
		"buttonColor": "#098DF4",
		"textColor": "#FFFFFF",
		"buttonTextColor": "#FFFFFF"
	},rules:[
		{
			"name": "AnyOther",
			"match": {},
			"message": "Like this app on Facebook!",
			"action": {
				"type": "button",
				"text": "Like",
				"verb": "follow",
				"service": "facebook",
				"id": "gasbroapp"
			}
		},
		{
			"name": "www.seantburke.com",
			"match": {
				"referrer": "www.seantburke.com"
			},
			"message": "Thanks for checking out my app! Contact me for a free Promo code!",
			"action": {
				"type": "button",
				"text": "Email Sean",
				"verb": "link",
				"url": "mailto:sean@seantburke.com"
			}
		}
	]});
	
	var addthis_config = {"data_track_addressbar":true};
    $(document).ready(function(){
    
        var session_id = '<?php echo $_SESSION['id'];?>';
        id = getURLParameter("id");
        if(id != "null")
        {
            //console.log(id);
            loadTrip(id);
        }
        else if(session_id != "null"){
            loadTrip(session_id);
        }
        var maxFriends = people - 1;
        getFriends(maxFriends);
        $("#prices").hide();
        $("#prices2").hide();
        setSliders();
    });  
    
    Parse.initialize("XaOZLlEYM0Iu49oTedAm1gqQM895vkV66F8RNSL7", "mXOANydxMFw3AHN6k8nSP1AifftrStFyPBRYLXGJ");
          
          window.fbAsyncInit = function() {
            // init the FB JS SDK
    
            Parse.FacebookUtils.init({
              appId      : '529283730470617',                        // App ID from the app dashboard
              channelUrl : '//www.gasbro.com/channel.php',
              status     : true,                                 // Check Facebook Login status
              xfbml      : true                                  // Look for social plugins on the page
            });
        
            // Additional initialization code such as adding Event Listeners goes here
          /*
          Parse.FacebookUtils.logIn("user_likes,email", {
              success: function(user) {
                if (!user.existed()) {
                  console.log("User signed up and logged in through Facebook!");
                } else {
                  console.log("User logged in through Facebook!");
                }
                
                if (!Parse.FacebookUtils.isLinked(user)) {
                  Parse.FacebookUtils.link(user, null, {
                    success: function(user) {
                      console.log("Woohoo, user logged in with Facebook!");
                    },
                    error: function(user, error) {
                      console.log("User cancelled the Facebook login or did not fully authorize.");
                    }
                  });
                }
              },
              error: function(user, error) {
                console.log("User cancelled the Facebook login or did not fully authorize.");
              }
            });
            
          */
          };
              (function(d, s, id){
             var js, fjs = d.getElementsByTagName(s)[0];
             if (d.getElementById(id)) {return;}
             js = d.createElement(s); js.id = id;
             js.src = "//connect.facebook.net/en_US/all.js";
             fjs.parentNode.insertBefore(js, fjs);
           }(document, 'script', 'facebook-jssdk'));
        
    
           
    
</script>
<!-- AddThis Welcome END -->
    </body>
</html>